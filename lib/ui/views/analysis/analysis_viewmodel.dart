import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jar/app/app.locator.dart';
import 'package:jar/services/pallet_repository.dart';
import 'package:jar/l10n/app_localizations.dart';
import 'package:jar/utils/movement_data_processor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
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

  final PdfColor brandPrimary = PdfColor.fromHex("#0D253F");
  final PdfColor brandAccent = PdfColor.fromHex("#26A69A");
  final PdfColor brandDefective = PdfColor.fromHex("#D32F2F");
  final PdfColor lightGrey = PdfColor.fromHex("#F5F7FA");

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
      final pdfBytes = await _generateAnalysisPdf();

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

  Future<Uint8List> _generateAnalysisPdf() async {
    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final fontItalic = await PdfGoogleFonts.robotoItalic();
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: fontRegular,
        bold: fontBold,
        italic: fontItalic,
      ),
    );

    final logoData = await rootBundle.load('assets/icon/icon.png');
    final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
            pageFormat: PdfPageFormat.a4, margin: const pw.EdgeInsets.all(32)),
        header: (context) => _buildHeader(context, logoImage, brandPrimary),
        footer: (context) => _buildFooter(context, brandPrimary),
        build: (context) => [
          _buildAnalysisDashboard(
              _globalStats,
              _warehouseDistribution,
              _topProducts,
              _movementStats,
              _activeProducts,
              _recentLotActivity,
              _warehouseOccupancy,
              _defectiveLast30Days,
              brandPrimary,
              brandAccent),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(
      pw.Context context, pw.ImageProvider logoImage, PdfColor brandPrimary) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      margin: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
            bottom: pw.BorderSide(color: PdfColors.grey300, width: 1.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.SizedBox(
            height: 40,
            width: 40,
            child: pw.Image(logoImage),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(_l10n.reportTitle,
                  style: pw.TextStyle(
                      color: brandPrimary,
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold)),
              pw.Text(
                  _l10n.reportGenerated(
                      DateTime.now().toLocal().toString().split(' ')[0]),
                  style: const pw.TextStyle(
                      color: PdfColors.grey600, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(pw.Context context, PdfColor brandPrimary) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        _l10n.reportPage(context.pageNumber, context.pagesCount),
        style: pw.TextStyle(
          color: PdfColor(
              brandPrimary.red, brandPrimary.green, brandPrimary.blue, 0.7),
          fontSize: 9,
        ),
      ),
    );
  }

  pw.Widget _buildAnalysisDashboard(
      Map<String, int> globalStats,
      List<Map<String, dynamic>> warehouseDistribution,
      List<Map<String, dynamic>> topProducts,
      List<Map<String, dynamic>> movementStats,
      int activeProducts,
      List<Map<String, dynamic>> recentActivity,
      List<Map<String, dynamic>> warehouseOccupancy,
      int defectiveLast30Days,
      PdfColor primary,
      PdfColor secondary) {
    final totalIn = globalStats['totalIn'] ?? 0;
    final totalOut = globalStats['totalOut'] ?? 0;
    final totalDefective = globalStats['totalDefective'] ?? 0;

    final last30DaysIn = movementStats
        .where((m) => m['type'] == 'in')
        .fold<int>(0, (sum, m) => sum + (m['count'] as int? ?? 0));
    final last30DaysOut = movementStats
        .where((m) => m['type'] == 'out')
        .fold<int>(0, (sum, m) => sum + (m['count'] as int? ?? 0));
    final last30DaysTotal = last30DaysIn + last30DaysOut + defectiveLast30Days;
    final defectRate = last30DaysTotal > 0
        ? (defectiveLast30Days / last30DaysTotal * 100)
        : 0.0;
    final rotationRatio = last30DaysIn > 0 ? (last30DaysOut / last30DaysIn) : 0.0;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatCard(_l10n.inStock, '$totalIn', PdfColors.blue700, primary,
                subtitle: _l10n.currentStockDesc),
            pw.SizedBox(width: 12),
            _buildStatCard(_l10n.defective, '$totalDefective',
                PdfColors.red700, primary,
                subtitle: _l10n.currentDefectiveDesc),
            pw.SizedBox(width: 12),
            _buildStatCard(_l10n.dispatched, '$totalOut', PdfColors.green700,
                primary,
                subtitle: _l10n.dispatchedLast30Days(last30DaysOut)),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
          children: [
            _buildKpiBadge(_l10n.defectRate,
                '${defectRate.toStringAsFixed(1)}%', PdfColors.red400,
                description: _l10n.defectRateDesc),
            pw.SizedBox(width: 12),
            _buildKpiBadge(_l10n.rotationRatio,
                rotationRatio.toStringAsFixed(2), PdfColors.teal600,
                description: _l10n.rotationRatioDesc),
            pw.SizedBox(width: 12),
            _buildKpiBadge(
                _l10n.activeProducts, '$activeProducts', PdfColors.purple600),
          ],
        ),
        pw.SizedBox(height: 20),
        _buildSectionHeader(_l10n.warehouseOccupancy, primary),
        pw.SizedBox(height: 8),
        _buildOccupancyBars(warehouseOccupancy, primary),
        pw.SizedBox(height: 20),
        _buildSectionHeader(_l10n.recentActivity, secondary),
        pw.SizedBox(height: 8),
        _buildRecentActivityTable(recentActivity),
        pw.SizedBox(height: 20),
        _buildPdfChart(movementStats, primary, secondary),
      ],
    );
  }

  pw.Widget _buildStatCard(String title, String value, PdfColor color,
      PdfColor textColor,
      {String? subtitle}) {
    return pw.Expanded(
      child: pw.Container(
        height: 70,
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(5),
        ),
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: color)),
            pw.SizedBox(height: 4),
            pw.Text(title,
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                textAlign: pw.TextAlign.center),
            if (subtitle != null) ...[
              pw.SizedBox(height: 2),
              pw.Text(subtitle,
                  style: const pw.TextStyle(
                      fontSize: 7, color: PdfColors.grey500),
                  textAlign: pw.TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }

  pw.Widget _buildKpiBadge(String label, String value, PdfColor color,
      {String? description}) {
    return pw.Expanded(
      child: pw.Container(
        height: 70,
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(5),
        ),
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: color)),
            pw.SizedBox(height: 2),
            pw.Text(label,
                style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700),
                textAlign: pw.TextAlign.center),
            if (description != null) ...[
              pw.SizedBox(height: 2),
              pw.Text(description,
                  style: const pw.TextStyle(
                      fontSize: 7, color: PdfColors.grey500),
                  textAlign: pw.TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }

  pw.Widget _buildSectionHeader(String title, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: const pw.BorderRadius.only(
            topLeft: pw.Radius.circular(5), topRight: pw.Radius.circular(5)),
      ),
      child: pw.Text(title,
          style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white)),
    );
  }

  pw.Widget _buildOccupancyBars(
      List<Map<String, dynamic>> data, PdfColor primary) {
    if (data.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(5),
        ),
        child: pw.Center(child: pw.Text(_l10n.noData)),
      );
    }

    final rows = data.map((item) {
      final name = item['warehouseName']?.toString() ?? _l10n.unknown;
      final count = (item['count'] as num?)?.toInt() ?? 0;
      final percentage = (item['percentage'] as num?)?.toDouble() ?? 0.0;

      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Row(
          children: [
            pw.SizedBox(
              width: 70,
              child: pw.Text(name,
                  style: pw.TextStyle(
                      fontSize: 9, fontWeight: pw.FontWeight.bold),
                  overflow: pw.TextOverflow.clip),
            ),
            pw.SizedBox(width: 8),
            pw.Expanded(
              child: pw.Container(
                height: 8,
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: percentage.clamp(0.0, 100.0).toInt(),
                      child: pw.Container(
                        decoration: pw.BoxDecoration(
                          color: primary,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    if (percentage < 100)
                      pw.Expanded(
                        flex:
                            (100 - percentage.clamp(0.0, 100.0)).toInt(),
                        child: pw.Container(),
                      ),
                  ],
                ),
              ),
            ),
            pw.SizedBox(width: 8),
            pw.SizedBox(
              width: 40,
              child: pw.Text('${percentage.toStringAsFixed(0)}%',
                  style: pw.TextStyle(
                      fontSize: 9, fontWeight: pw.FontWeight.bold),
                  textAlign: pw.TextAlign.right),
            ),
          ],
        ),
      );
    }).toList();

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(children: rows),
    );
  }

  pw.Widget _buildRecentActivityTable(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(5),
        ),
        child: pw.Center(child: pw.Text(_l10n.noData)),
      );
    }

    final headerStyle = pw.TextStyle(
        fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 8);
    const cellStyle = pw.TextStyle(fontSize: 8);
    const cellPadding =
        pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5);

    final headerRow = pw.TableRow(
      decoration: pw.BoxDecoration(color: brandPrimary),
      children: [
        pw.Padding(
            padding: cellPadding,
            child: pw.Text(_l10n.date, style: headerStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text(_l10n.type, style: headerStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text(_l10n.product, style: headerStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text(_l10n.warehouse, style: headerStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text(_l10n.reportPalletCount, style: headerStyle)),
      ],
    );

    final dataRows = data.map((item) {
      final dateStr = item['date'] != null
          ? MovementDataProcessor.formatDateLabel(item['date'].toString())
          : _l10n.noDate;
      final type = item['type']?.toString() ?? 'in';
      final isEntry = type == 'in';
      final palletCount = (item['palletCount'] as num?)?.toInt() ?? 0;

      return pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.white),
        children: [
          pw.Padding(
              padding: cellPadding,
              child: pw.Text(dateStr, style: cellStyle)),
          pw.Padding(
            padding: cellPadding,
            child: pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                  horizontal: 4, vertical: 1),
              decoration: pw.BoxDecoration(
                color: isEntry ? PdfColors.green : PdfColors.orange,
                borderRadius: pw.BorderRadius.circular(2),
              ),
              child: pw.Text(
                isEntry ? _l10n.movementIn : _l10n.movementOut,
                style: const pw.TextStyle(
                    fontSize: 7, color: PdfColors.white),
              ),
            ),
          ),
          pw.Padding(
            padding: cellPadding,
            child: pw.Text(item['productName'] ?? _l10n.unknown,
                style: cellStyle, overflow: pw.TextOverflow.clip),
          ),
          pw.Padding(
            padding: cellPadding,
            child: pw.Text(item['warehouseName'] ?? _l10n.unknown,
                style: cellStyle, overflow: pw.TextOverflow.clip),
          ),
          pw.Padding(
            padding: cellPadding,
            child: pw.Text('$palletCount',
                style: pw.TextStyle(
                    fontSize: 8, fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.center),
          ),
        ],
      );
    }).toList();

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Table(
        columnWidths: const {
          0: pw.FlexColumnWidth(1.5),
          1: pw.FlexColumnWidth(1),
          2: pw.FlexColumnWidth(2.5),
          3: pw.FlexColumnWidth(2),
          4: pw.FlexColumnWidth(1),
        },
        children: [headerRow, ...dataRows],
      ),
    );
  }

  pw.Widget _buildPdfChart(
      List<Map<String, dynamic>> data, PdfColor primary, PdfColor secondary) {
    if (data.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(20),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(5),
        ),
        child: pw.Center(child: pw.Text(_l10n.noData)),
      );
    }

    final processed = MovementDataProcessor.process(data);
    final inData = processed.inData;
    final outData = processed.outData;
    final sortedDates = processed.sortedDates;

    final int totalIn = inData.values.fold(0, (a, b) => a + b);
    final int totalOut = outData.values.fold(0, (a, b) => a + b);
    final netBalance = totalIn - totalOut;

    final now = DateTime.now();
    final weeklyIn = <int>[];
    final weeklyOut = <int>[];
    final weekLabels = <String>[];

    for (int w = 4; w >= 0; w--) {
      final weekEnd = now.subtract(Duration(days: w * 7));
      final weekStart = weekEnd.subtract(const Duration(days: 6));
      final startStr = weekStart.toIso8601String().split('T').first;
      final endStr = weekEnd.toIso8601String().split('T').first;

      int sumIn = 0, sumOut = 0;
      for (final date in sortedDates) {
        if (date.compareTo(startStr) >= 0 && date.compareTo(endStr) <= 0) {
          sumIn += inData[date] ?? 0;
          sumOut += outData[date] ?? 0;
        }
      }
      weeklyIn.add(sumIn);
      weeklyOut.add(sumOut);

      final startDay = weekStart.day.toString().padLeft(2, '0');
      final endDay = weekEnd.day.toString().padLeft(2, '0');
      final month = _getMonthShort(weekEnd.month);
      weekLabels.add('$startDay-$endDay $month');
    }

    final maxWeekly =
        [...weeklyIn, ...weeklyOut].reduce((a, b) => a > b ? a : b);
    final chartHeight = 100.0;

    List<pw.Widget> barGroups = [];
    for (int i = 0; i < weeklyIn.length; i++) {
      final hIn =
          maxWeekly > 0 ? (weeklyIn[i] / maxWeekly) * chartHeight : 0.0;
      final hOut =
          maxWeekly > 0 ? (weeklyOut[i] / maxWeekly) * chartHeight : 0.0;

      barGroups.add(
        pw.Expanded(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 10,
                    height: hIn,
                    decoration: pw.BoxDecoration(
                      color: PdfColors.green,
                      borderRadius: const pw.BorderRadius.only(
                          topLeft: pw.Radius.circular(2),
                          topRight: pw.Radius.circular(2)),
                    ),
                  ),
                  pw.SizedBox(width: 3),
                  pw.Container(
                    width: 10,
                    height: hOut,
                    decoration: pw.BoxDecoration(
                      color: PdfColors.orange,
                      borderRadius: const pw.BorderRadius.only(
                          topLeft: pw.Radius.circular(2),
                          topRight: pw.Radius.circular(2)),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Text(weekLabels[i],
                  style: const pw.TextStyle(
                      fontSize: 7, color: PdfColors.grey600)),
            ],
          ),
        ),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(_l10n.movementTrends30Days,
            style:
                pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(5),
          ),
          child: pw.Column(
            children: [
              pw.Container(
                height: chartHeight + 16,
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    left: pw.BorderSide(
                        color: PdfColors.grey400, width: 0.5),
                    bottom: pw.BorderSide(
                        color: PdfColors.grey400, width: 0.5),
                  ),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: barGroups,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Container(width: 10, height: 8, color: PdfColors.green),
                  pw.SizedBox(width: 4),
                  pw.Text('${_l10n.movementIn} ($totalIn)',
                      style: const pw.TextStyle(fontSize: 8)),
                  pw.SizedBox(width: 20),
                  pw.Container(width: 10, height: 8, color: PdfColors.orange),
                  pw.SizedBox(width: 4),
                  pw.Text('${_l10n.movementOut} ($totalOut)',
                      style: const pw.TextStyle(fontSize: 8)),
                  pw.SizedBox(width: 20),
                  pw.Container(
                      width: 10,
                      height: 8,
                      color: netBalance >= 0
                          ? PdfColors.green
                          : PdfColors.red),
                  pw.SizedBox(width: 4),
                  pw.Text('Balance ($netBalance)',
                      style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getMonthShort(int month) {
    final months = [
      _l10n.monthJan, _l10n.monthFeb, _l10n.monthMar, _l10n.monthApr,
      _l10n.monthMay, _l10n.monthJun, _l10n.monthJul, _l10n.monthAug,
      _l10n.monthSep, _l10n.monthOct, _l10n.monthNov, _l10n.monthDec
    ];
    return months[month - 1];
  }
}
