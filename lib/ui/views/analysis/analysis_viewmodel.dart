import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:jar/app/app.locator.dart';
import 'package:jar/models/report_item.dart';
import 'package:jar/services/pallet_repository.dart';
import 'package:jar/l10n/app_localizations.dart';
import 'package:jar/services/pdf_report_builder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class AnalysisViewModel extends BaseViewModel {
  final _palletRepo = locator<PalletRepository>();
  final _dialogService = locator<DialogService>();
  final _navigationService = locator<NavigationService>();

  Map<String, int> _globalStats = {};
  Map<String, int> get globalStats => _globalStats;

  List<Map<String, dynamic>> _warehouseDistribution = [];
  List<Map<String, dynamic>> get warehouseDistribution =>
      _warehouseDistribution;

  List<Map<String, dynamic>> _topProducts = [];
  List<Map<String, dynamic>> get topProducts => _topProducts;

  List<Map<String, dynamic>> _movementStats = [];
  List<Map<String, dynamic>> get movementStats => _movementStats;

  int _activeProducts = 0;
  int get activeProducts => _activeProducts;

  List<Map<String, dynamic>> _recentLotActivity = [];
  List<Map<String, dynamic>> get recentLotActivity => _recentLotActivity;

  List<Map<String, dynamic>> _warehouseOccupancy = [];
  List<Map<String, dynamic>> get warehouseOccupancy => _warehouseOccupancy;

  int _defectiveLast30Days = 0;
  int get defectiveLast30Days => _defectiveLast30Days;

  double get defectRate {
    final last30DaysIn = movementStats
        .where((m) => m['type'] == 'in')
        .fold<int>(0, (sum, m) => sum + (m['count'] as int? ?? 0));
    final last30DaysOut = movementStats
        .where((m) => m['type'] == 'out')
        .fold<int>(0, (sum, m) => sum + (m['count'] as int? ?? 0));
    final last30DaysTotal = last30DaysIn + last30DaysOut + _defectiveLast30Days;
    return last30DaysTotal > 0
        ? (_defectiveLast30Days / last30DaysTotal * 100)
        : 0.0;
  }

  double get rotationRatio {
    final last30DaysIn = movementStats
        .where((m) => m['type'] == 'in')
        .fold<int>(0, (sum, m) => sum + (m['count'] as int? ?? 0));
    final last30DaysOut = movementStats
        .where((m) => m['type'] == 'out')
        .fold<int>(0, (sum, m) => sum + (m['count'] as int? ?? 0));
    return last30DaysIn > 0 ? (last30DaysOut / last30DaysIn) : 0.0;
  }

  int get last30DaysOut {
    return movementStats
        .where((m) => m['type'] == 'out')
        .fold<int>(0, (sum, m) => sum + (m['count'] as int? ?? 0));
  }

  AppLocalizations get _l10n {
    final context = StackedService.navigatorKey?.currentContext;
    if (context == null) {
      throw StateError('Localizations accessed before navigator is ready');
    }
    final localization = AppLocalizations.of(context);
    if (localization == null) {
      throw StateError('Localizations not found in context');
    }
    return localization;
  }

  Future<void> initialise() async {
    setBusy(true);
    await Future.wait([
      _fetchGlobalStats(),
      _fetchWarehouseDistribution(),
      _fetchTopProducts(),
      _fetchMovementStats(),
      _fetchActiveProducts(),
      _fetchRecentLotActivity(),
      _fetchWarehouseOccupancy(),
      _fetchDefectiveLast30Days(),
    ]);
    setBusy(false);
  }

  Future<void> _fetchGlobalStats() async {
    _globalStats = await _palletRepo.getGlobalStats();
  }

  Future<void> _fetchWarehouseDistribution() async {
    _warehouseDistribution = await _palletRepo.getWarehouseDistribution();
  }

  Future<void> _fetchTopProducts() async {
    _topProducts = await _palletRepo.getTopProducts(5);
  }

  Future<void> _fetchMovementStats() async {
    _movementStats = await _palletRepo.getMovementStats(30);
  }

  Future<void> _fetchActiveProducts() async {
    _activeProducts = await _palletRepo.getActiveProductsCount();
  }

  Future<void> _fetchRecentLotActivity() async {
    _recentLotActivity = await _palletRepo.getRecentLotActivity(5);
  }

  Future<void> _fetchWarehouseOccupancy() async {
    _warehouseOccupancy = await _palletRepo.getWarehouseOccupancy();
  }

  Future<void> _fetchDefectiveLast30Days() async {
    _defectiveLast30Days = await _palletRepo.getDefectiveLast30Days();
  }

  Future<void> generateAndShareAnalysisReport() async {
    final context = _navigationService.navigatorKey?.currentContext;
    if (context == null) return;

    _showLoadingDialog(context, _l10n.loading);
    try {
      final normalItems = await _palletRepo.getReportItems(isDefective: false);
      final defectiveItems = await _palletRepo.getReportItems(isDefective: true);

      final pdfBytes = await _generateAnalysisPdf(normalItems, defectiveItems);

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = await File('${tempDir.path}/analysis_report_$timestamp.pdf')
          .writeAsBytes(pdfBytes);

      _dismissLoadingDialog(context);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: _l10n
            .reportSubject(DateTime.now().toLocal().toString().split(' ')[0]),
        text: _l10n.reportBody,
      );
    } catch (e) {
      _dismissLoadingDialog(context);
      await _dialogService.showDialog(
          title: _l10n.pdfError,
          description: _l10n.pdfErrorDescription(e.toString()));
    }
  }

  Future<void> _showLoadingDialog(BuildContext context, String loadingText) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/icon/icon.png', width: 80, height: 80),
                const SizedBox(height: 16),
                Text(loadingText, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 12),
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _dismissLoadingDialog(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<Uint8List> _generateAnalysisPdf(
    List<WarehouseReportItem> normalItems,
    List<WarehouseReportItem> defectiveItems,
  ) async {
    final builder = PdfReportBuilder(_l10n);
    final pdf = await builder.createDocument();
    final logoImage = await builder.loadLogo();

    final totalIn = _globalStats['totalIn'] ?? 0;
    final totalOut = _globalStats['totalOut'] ?? 0;
    final totalDefective = _globalStats['totalDefective'] ?? 0;

    final last30DaysIn = _movementStats
        .where((m) => m['type'] == 'in')
        .fold<int>(0, (sum, m) => sum + (m['count'] as int? ?? 0));
    final last30DaysOut = _movementStats
        .where((m) => m['type'] == 'out')
        .fold<int>(0, (sum, m) => sum + (m['count'] as int? ?? 0));
    final last30DaysTotal = last30DaysIn + last30DaysOut + _defectiveLast30Days;
    final defectRate = last30DaysTotal > 0
        ? (_defectiveLast30Days / last30DaysTotal * 100)
        : 0.0;
    final rotationRatio = last30DaysIn > 0 ? (last30DaysOut / last30DaysIn) : 0.0;

    // 1. Analysis Dashboard Page
    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
            pageFormat: PdfPageFormat.a4, margin: const pw.EdgeInsets.all(32)),
        header: (context) => builder.buildHeader(context, logoImage),
        footer: (context) => builder.buildFooter(context),
        build: (context) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: [
                  builder.buildStatCard(_l10n.inStock, '$totalIn',
                      PdfColors.blue700, builder.brandPrimary,
                      subtitle: _l10n.currentStockDesc),
                  pw.SizedBox(width: 12),
                  builder.buildStatCard(_l10n.defective, '$totalDefective',
                      PdfColors.red700, builder.brandPrimary,
                      subtitle: _l10n.currentDefectiveDesc),
                  pw.SizedBox(width: 12),
                  builder.buildStatCard(_l10n.dispatched, '$totalOut',
                      PdfColors.green700, builder.brandPrimary,
                      subtitle: _l10n.dispatchedLast30Days(last30DaysOut)),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: [
                  builder.buildKpiBadge(_l10n.defectRate,
                      '${defectRate.toStringAsFixed(1)}%', PdfColors.red400,
                      description: _l10n.defectRateDesc),
                  pw.SizedBox(width: 12),
                  builder.buildKpiBadge(_l10n.rotationRatio,
                      rotationRatio.toStringAsFixed(2), PdfColors.teal600,
                      description: _l10n.rotationRatioDesc),
                  pw.SizedBox(width: 12),
                  builder.buildKpiBadge(
                      _l10n.activeProducts, '$_activeProducts', PdfColors.purple600),
                ],
              ),
              pw.SizedBox(height: 20),
              builder.buildSectionHeader(_l10n.warehouseOccupancy, builder.brandPrimary),
              pw.SizedBox(height: 8),
              builder.buildOccupancyBars(_warehouseOccupancy),
              pw.SizedBox(height: 20),
              builder.buildSectionHeader(_l10n.recentActivity, builder.brandAccent),
              pw.SizedBox(height: 8),
              builder.buildRecentActivityTable(_recentLotActivity),
              pw.SizedBox(height: 20),
              builder.buildPdfChart(_movementStats),
            ],
          ),
        ],
      ),
    );

    // 2. Summary Totals Page
    final totalNormalPallets = normalItems.fold<int>(
        0, (sum, item) => sum + item.palletCount);
    final totalDefectivePallets = defectiveItems.fold<int>(
        0, (sum, item) => sum + item.palletCount);

    final normalByProduct = <String, int>{};
    for (final item in normalItems) {
      final key = '${item.productName} - ${item.lotName}';
      normalByProduct[key] = (normalByProduct[key] ?? 0) + item.palletCount;
    }

    final defectiveByProduct = <String, int>{};
    for (final item in defectiveItems) {
      final key = '${item.productName} - ${item.lotName}';
      defectiveByProduct[key] = (defectiveByProduct[key] ?? 0) + item.palletCount;
    }

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
            pageFormat: PdfPageFormat.a4, margin: const pw.EdgeInsets.all(32)),
        header: (context) => builder.buildHeader(context, logoImage),
        footer: (context) => builder.buildFooter(context),
        build: (context) => [
          pw.Text(_l10n.reportTitle,
              style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: builder.brandPrimary)),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
            children: [
              builder.buildStatCard(
                  _l10n.reportStandardInventory,
                  '$totalNormalPallets',
                  builder.brandAccent,
                  builder.brandPrimary),
              pw.SizedBox(width: 20),
              builder.buildStatCard(
                  _l10n.reportDefectiveInventory,
                  '$totalDefectivePallets',
                  builder.brandDefective,
                  builder.brandPrimary),
            ],
          ),
          pw.SizedBox(height: 25),
          builder.buildSectionHeader(_l10n.reportStandardInventory, builder.brandAccent),
          pw.SizedBox(height: 8),
          if (normalByProduct.isNotEmpty)
            builder.buildSummaryTable(normalByProduct, totalNormalPallets, builder.brandAccent)
          else
            pw.Text(_l10n.reportNoStandardPallets,
                style: pw.TextStyle(
                    fontStyle: pw.FontStyle.italic, color: PdfColors.grey)),
          pw.SizedBox(height: 25),
          builder.buildSectionHeader(_l10n.reportDefectiveInventory, builder.brandDefective),
          pw.SizedBox(height: 8),
          if (defectiveByProduct.isNotEmpty)
            builder.buildSummaryTable(
                defectiveByProduct, totalDefectivePallets, builder.brandDefective)
          else
            pw.Text(_l10n.reportNoDefectivePallets,
                style: pw.TextStyle(
                    fontStyle: pw.FontStyle.italic, color: PdfColors.grey)),
        ],
      ),
    );

    // 3. Per-Warehouse Pages
    final allWarehouseNames = {
      ...normalItems.map((i) => i.warehouseName),
      ...defectiveItems.map((i) => i.warehouseName)
    }.toList();
    allWarehouseNames.sort();

    for (final warehouseName in allWarehouseNames) {
      final currentNormalItems =
          normalItems.where((i) => i.warehouseName == warehouseName).toList();
      final currentDefectiveItems = defectiveItems
          .where((i) => i.warehouseName == warehouseName)
          .toList();

      final whNormalPallets = currentNormalItems.fold<int>(
          0, (sum, item) => sum + item.palletCount);
      final whDefectivePallets = currentDefectiveItems.fold<int>(
          0, (sum, item) => sum + item.palletCount);
      final warehouseTotal = whNormalPallets + whDefectivePallets;

      pdf.addPage(
        pw.MultiPage(
          pageTheme: pw.PageTheme(
              pageFormat: PdfPageFormat.a4,
              margin: const pw.EdgeInsets.all(32)),
          header: (context) => builder.buildHeader(context, logoImage),
          footer: (context) => builder.buildFooter(context),
          build: (context) => [
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: builder.brandPrimary,
                borderRadius: pw.BorderRadius.circular(5),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(warehouseName,
                      style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white)),
                  pw.Text('$warehouseTotal pallets',
                      style: pw.TextStyle(
                          fontSize: 14,
                          color: PdfColor(1, 1, 1, 0.8))),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(5),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  builder.buildSummaryStatItem(
                      _l10n.inStock, '$whNormalPallets', builder.brandAccent),
                  pw.Container(width: 1, height: 25, color: PdfColors.grey300),
                  builder.buildSummaryStatItem(
                      _l10n.defective, '$whDefectivePallets', builder.brandDefective),
                  pw.Container(width: 1, height: 25, color: PdfColors.grey300),
                  builder.buildSummaryStatItem(
                      _l10n.reportPalletCount, '$warehouseTotal', builder.brandPrimary),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            builder.buildSectionHeader(_l10n.reportStandardInventory, builder.brandAccent),
            pw.SizedBox(height: 8),
            if (currentNormalItems.isNotEmpty) ...[
              builder.buildWarehouseTable(currentNormalItems, builder.brandAccent, builder.lightGrey),
              pw.SizedBox(height: 8),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: builder.brandAccent,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    _l10n.reportTotalStandard(whNormalPallets),
                    style:  pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10),
                  ),
                ),
              ),
            ] else
              pw.Text(_l10n.reportNoStandardPallets,
                  style: pw.TextStyle(
                      fontStyle: pw.FontStyle.italic, color: PdfColors.grey)),
            pw.SizedBox(height: 25),
            builder.buildSectionHeader(_l10n.reportDefectiveInventory, builder.brandDefective),
            pw.SizedBox(height: 8),
            if (currentDefectiveItems.isNotEmpty) ...[
              builder.buildWarehouseTable(
                  currentDefectiveItems, builder.brandDefective, builder.lightGrey),
              pw.SizedBox(height: 10),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: builder.brandDefective,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    _l10n.reportTotalDefective(whDefectivePallets),
                    style:  pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10),
                  ),
                ),
              ),
            ] else
              pw.Text(_l10n.reportNoDefectivePallets,
                  style: pw.TextStyle(
                      fontStyle: pw.FontStyle.italic, color: PdfColors.grey)),
          ],
        ),
      );
    }

    return pdf.save();
  }
}
