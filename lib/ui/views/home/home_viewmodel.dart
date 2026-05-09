import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:jar/app/app.locator.dart';
import 'package:jar/app/app.router.dart';
import 'package:jar/l10n/app_localizations.dart';
import 'package:jar/models/product.dart';
import 'package:jar/models/report_item.dart';
import 'package:jar/models/warehouse.dart';
import 'package:jar/services/filter_service.dart';
import 'package:jar/services/locale_service.dart';
import 'package:jar/services/warehouse_data_service.dart';
import 'package:jar/services/database_service.dart';
import 'package:jar/services/warehouse_repository.dart';
import 'package:jar/services/pallet_repository.dart';
import 'package:jar/services/pdf_report_builder.dart';
import 'package:jar/ui/common/app_colors.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class HomeViewModel extends ReactiveViewModel {
  final _warehouseDataService = locator<WarehouseDataService>();
  final _filterService = locator<FilterService>();
  final _dialogService = locator<DialogService>();
  final _navigationService = locator<NavigationService>();
  final _localeService = locator<LocaleService>();
  final _warehouseRepo = locator<WarehouseRepository>();
  final _palletRepo = locator<PalletRepository>();
  final _dbService = DatabaseService.instance;

  bool isActivated = false;
  int currentIndex = 0;
  TabController? tabController;

  String? _appVersion;
  String? get appVersion => _appVersion;

  Map<int, int> get palletCounts => _warehouseDataService.palletCounts.value;
  List<Warehouse> get warehouses => _warehouseDataService.warehouses.value;
  int get warehouseCount => warehouses.length;
  Product? get selectedProduct => _filterService.selectedProduct.value;
  late bool isFilterActive;

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

  void setShowDropdown(bool value) {
    _filterService.setShowDropdown(value);
  }

  @override
  List<ListenableServiceMixin> get listenableServices => [
        _warehouseDataService,
        _filterService,
      ];

  bool get showDropdown => _filterService.showDropdown.value;

  Locale get currentLocale => _localeService.currentLocale;

  void setLocale(Locale locale) {
    _localeService.setLocale(locale);
  }

  @override
  void dispose() {
    tabController?.removeListener(_onTabChanged);
    tabController?.dispose();
    super.dispose();
  }

  Future<void> initialise() async {
    await _getAppVersion();
    await runBusyFuture(_loadInitialData());
    isFilterActive = _filterService.selectedProduct.value != null;
  }

  Future<void> _getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _appVersion = '${_l10n.version} ${packageInfo.version}';
      notifyListeners();
    } catch (e) {
      _appVersion = _l10n.versionUnknown;
      notifyListeners();
    }
  }

  Future<void> _loadInitialData() async {
    await fetchWarehouses();
    await fetchPalletCounts();
  }

  void initTabController(TickerProvider vsync) {
    if (tabController != null && tabController!.length == warehouseCount) {
      if (tabController!.index != currentIndex)
        tabController!.animateTo(currentIndex);
      return;
    }
    tabController?.removeListener(_onTabChanged);
    tabController?.dispose();
    if (warehouseCount == 0) {
      tabController = null;
      return;
    }
    tabController = TabController(
        length: warehouseCount, initialIndex: currentIndex, vsync: vsync);
    tabController!.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (currentIndex != tabController!.index &&
        !tabController!.indexIsChanging) {
      currentIndex = tabController!.index;
      notifyListeners();
    }
  }

  Future<void> fetchWarehouses() async {
    _warehouseDataService.warehouses.value =
        await _warehouseRepo.getAll();
    if (currentIndex >= warehouses.length) {
      currentIndex = warehouses.isNotEmpty ? warehouses.length - 1 : 0;
    }
  }

  Future<void> fetchPalletCounts() async {
    _warehouseDataService.palletCounts.value = await _palletRepo
        .getAllWarehousePalletCounts(isDefective: isActivated);
  }

  Future<void> addWarehouse(String name) async {
    await runBusyFuture(_warehouseRepo.create(Warehouse(name: name)));
    await fetchWarehouses();
    await fetchPalletCounts();
  }

  Future<void> deleteWarehouse(Warehouse warehouse) async {
    await runBusyFuture(_warehouseRepo.delete(warehouse.id!));
    await fetchWarehouses();
    await fetchPalletCounts();
  }

  Future<void> updateWarehouseName(Warehouse warehouse, String name) async {
    warehouse.name = name;
    await runBusyFuture(_warehouseRepo.update(warehouse));
    notifyListeners();
  }

  void toggleActivation() {
    isActivated = !isActivated;
    _filterService.setSelectedProduct(null);
    fetchPalletCounts();
    notifyListeners();
  }

  void navigateToCreateReceived() {
    if (warehouses.isNotEmpty) {
        final Warehouse selectedWarehouse = warehouses[currentIndex];
        _navigationService.navigateToCreateReceivedView(warehouse: selectedWarehouse);
    }
  }

  void navigateToAnalysis() {
    _navigationService.navigateToAnalysisView();
  }

  void setCurrentIndex(int index) {
    if (currentIndex == index) return;
    currentIndex = index;
    tabController?.animateTo(index);
    notifyListeners();
  }

  Future<void> exportDatabase() async {
    setBusy(true);
    try {
      await _dbService.close();
      final path = await DatabaseService.getDatabasePath();
      await Share.shareXFiles([XFile(path)],
          subject: _l10n.dbBackupSubject(
              DateTime.now().toLocal().toString().split(' ')[0]),
          text: _l10n.dbBackupBody);
    } catch (e) {
      await _dialogService.showDialog(
          title: _l10n.exportError,
          description: _l10n.exportErrorDescription(e.toString()));
    } finally {
      await _dbService.reopen();
      setBusy(false);
    }
  }

  Future<void> importDatabase() async {
    try {
      final result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['db']);
      if (result == null) return;

      final response = await _dialogService.showConfirmationDialog(
        title: _l10n.importConfirm,
        description: _l10n.importConfirmMessage,
        confirmationTitle: _l10n.importConfirmYes,
        cancelTitle: _l10n.cancel,
      );
      if (response?.confirmed != true) return;

      final sourcePath = result.files.single.path!;
      final destinationPath = await DatabaseService.getDatabasePath();
      final backupPath = '$destinationPath.backup';

      setBusy(true);

      try {
        if (!await _dbService.isValidSqliteFile(sourcePath)) {
          await _dialogService.showDialog(
              title: _l10n.importError,
              description: _l10n.importNotSqlite);
          return;
        }

        final integrityError = await _dbService.checkIntegrity(sourcePath);
        if (integrityError != null) {
          await _dialogService.showDialog(
              title: _l10n.importError,
              description: _l10n.importCorrupted);
          return;
        }

        if (!await _dbService.hasValidSchema(sourcePath)) {
          await _dialogService.showDialog(
              title: _l10n.importError,
              description: _l10n.importSchemaMismatch);
          return;
        }

        await _dbService.close();

        final backupFile = File(destinationPath);
        if (await backupFile.exists()) {
          await backupFile.copy(backupPath);
        }

        try {
          await File(sourcePath).copy(destinationPath);
        } catch (e) {
          await _restoreFromBackup(backupPath, destinationPath);
          await _dialogService.showDialog(
              title: _l10n.importError,
              description: _l10n.importErrorDescription(e.toString()));
          return;
        }

        setBusy(false);
        await _dialogService.showDialog(
            title: _l10n.importComplete, description: _l10n.importCompleteMessage);

        _navigationService.clearStackAndShow(Routes.homeView);
      } catch (e) {
        await _restoreFromBackup(backupPath, destinationPath);
        setBusy(false);
        await _dialogService.showDialog(
            title: _l10n.importError,
            description: _l10n.importBackupRestored);
      } finally {
        await _cleanupBackup(backupPath);
      }
    } catch (e) {
      setBusy(false);
      await _dialogService.showDialog(
          title: _l10n.importError,
          description: _l10n.importErrorDescription(e.toString()));
    }
  }

  Future<void> _restoreFromBackup(String backupPath, String destinationPath) async {
    try {
      final backupFile = File(backupPath);
      if (await backupFile.exists()) {
        await backupFile.copy(destinationPath);
      }
    } catch (_) {}
  }

  Future<void> _cleanupBackup(String backupPath) async {
    try {
      final backupFile = File(backupPath);
      if (await backupFile.exists()) {
        await backupFile.delete();
      }
    } catch (_) {}
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

  Future<void> generateAndShareWarehouseReport() async {
    final context = _navigationService.navigatorKey?.currentContext;
    if (context == null) return;

    _showLoadingDialog(context, _l10n.loading);
    try {
      final normalItems = await _palletRepo
          .getReportItems(isDefective: false);
      final defectiveItems = await _palletRepo
          .getReportItems(isDefective: true);

      // Fetch Analysis Data
      final globalStats = await _palletRepo.getGlobalStats();
      final warehouseDistribution =
          await _palletRepo.getWarehouseDistribution();
      final topProducts = await _palletRepo.getTopProducts(5);
      final movementStats = await _palletRepo.getMovementStats(30);
      final activeProducts = await _palletRepo.getActiveProductsCount();
      final recentLotActivity = await _palletRepo.getRecentLotActivity(5);
      final warehouseOccupancy = await _palletRepo.getWarehouseOccupancy();
      final defectiveLast30Days = await _palletRepo.getDefectiveLast30Days();

      if (normalItems.isEmpty && defectiveItems.isEmpty) {
        _dismissLoadingDialog(context);
        await _dialogService.showDialog(
            title: _l10n.reportEmptyTitle, description: _l10n.reportEmptyMessage);
        return;
      }

      final pdfBytes = await _generatePdf(
        normalItems,
        defectiveItems,
        globalStats,
        warehouseDistribution,
        topProducts,
        movementStats,
        activeProducts,
        recentLotActivity,
        warehouseOccupancy,
        defectiveLast30Days,
      );

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = await File('${tempDir.path}/report_warehouse_$timestamp.pdf')
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

  Future<Uint8List> _generatePdf(
    List<WarehouseReportItem> normalItems,
    List<WarehouseReportItem> defectiveItems,
    Map<String, int> globalStats,
    List<Map<String, dynamic>> warehouseDistribution,
    List<Map<String, dynamic>> topProducts,
    List<Map<String, dynamic>> movementStats,
    int activeProducts,
    List<Map<String, dynamic>> recentLotActivity,
    List<Map<String, dynamic>> warehouseOccupancy,
    int defectiveLast30Days,
  ) async {
    final builder = PdfReportBuilder(_l10n);
    final pdf = await builder.createDocument();
    final logoImage = await builder.loadLogo();

    final totalIn = globalStats['totalIn'] ?? 0;
    final totalOut = globalStats['totalOut'] ?? 0;
    final totalDefective = globalStats['totalDefective'] ?? 0;

    final last30DaysIn = movementStats
        .where((m) => m['type'] == 'in')
        .fold<int>(0, (sum, m) => sum + (m['count'] as int? ?? 0));
    final last30DaysOut = movementStats
        .where((m) => m['type'] == 'out')
        .fold<int>(0, (sum, m) => sum + (m['count'] as int? ?? 0));
    final totalReceived = last30DaysIn + defectiveLast30Days;
    final defectRate = totalReceived > 0
        ? (defectiveLast30Days / totalReceived * 100)
        : 0.0;
    final rotationRatio = last30DaysIn > 0 ? (last30DaysOut / last30DaysIn) : 0.0;

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
                      _l10n.activeProducts, '$activeProducts', PdfColors.purple600),
                ],
              ),
              pw.SizedBox(height: 20),
              builder.buildSectionHeader(_l10n.warehouseOccupancy, builder.brandPrimary),
              pw.SizedBox(height: 8),
              builder.buildOccupancyBars(warehouseOccupancy),
              pw.SizedBox(height: 20),
              builder.buildSectionHeader(_l10n.recentActivity, builder.brandAccent),
              pw.SizedBox(height: 8),
              builder.buildRecentActivityTable(recentLotActivity),
              pw.SizedBox(height: 20),
              builder.buildPdfChart(movementStats),
            ],
          ),
        ],
      ),
    );

    final allWarehouseNames = {
      ...normalItems.map((i) => i.warehouseName),
      ...defectiveItems.map((i) => i.warehouseName)
    }.toList();
    allWarehouseNames.sort();

    final totalNormalPallets = normalItems.fold<int>(
        0, (sum, item) => sum + item.palletCount);
    final totalDefectivePallets = defectiveItems.fold<int>(
        0, (sum, item) => sum + item.palletCount);

    final normalByProduct = <String, int>{};
    for (final item in normalItems) {
      final key = item.productName;
      normalByProduct[key] = (normalByProduct[key] ?? 0) + item.palletCount;
    }

    final defectiveByProduct = <String, int>{};
    for (final item in defectiveItems) {
      final key = item.productName;
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

    for (final warehouseName in allWarehouseNames) {
      final currentNormalItems =
          normalItems.where((i) => i.warehouseName == warehouseName).toList();
      final currentDefectiveItems = defectiveItems
          .where((i) => i.warehouseName == warehouseName)
          .toList();

      final totalNormalPallets = currentNormalItems.fold<int>(
          0, (sum, item) => sum + item.palletCount);
      final totalDefectivePallets = currentDefectiveItems.fold<int>(
          0, (sum, item) => sum + item.palletCount);

      final warehouseTotal = totalNormalPallets + totalDefectivePallets;

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
                      _l10n.inStock, '$totalNormalPallets', builder.brandAccent),
                  pw.Container(width: 1, height: 25, color: PdfColors.grey300),
                  builder.buildSummaryStatItem(
                      _l10n.defective, '$totalDefectivePallets', builder.brandDefective),
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
                    _l10n.reportTotalStandard(totalNormalPallets),
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
                    _l10n.reportTotalDefective(totalDefectivePallets),
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

  Color filterActive() {
    return selectedProduct == null ? Colors.white : kcDefectiveColor;
  }
}
