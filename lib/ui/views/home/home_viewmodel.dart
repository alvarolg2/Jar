import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:jar/ui/common/app_colors.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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

  Future<void> generateAndShareWarehouseReport() async {
    setBusy(true);
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

      if (normalItems.isEmpty && defectiveItems.isEmpty) {
        await _dialogService.showDialog(
            title: _l10n.reportEmptyTitle, description: _l10n.reportEmptyMessage);
        setBusy(false);
        return;
      }

      final pdfBytes = await _generatePdf(
        normalItems,
        defectiveItems,
        globalStats,
        warehouseDistribution,
        topProducts,
        movementStats,
      );

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = await File('${tempDir.path}/report_warehouse_$timestamp.pdf')
          .writeAsBytes(pdfBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: _l10n
            .reportSubject(DateTime.now().toLocal().toString().split(' ')[0]),
        text: _l10n.reportBody,
      );
    } catch (e) {
      await _dialogService.showDialog(
          title: _l10n.pdfError,
          description: _l10n.pdfErrorDescription(e.toString()));
    } finally {
      setBusy(false);
    }
  }

  final PdfColor brandPrimary = PdfColor.fromHex("#0D253F");
  final PdfColor brandAccent = PdfColor.fromHex("#26A69A");
  final PdfColor brandDefective = PdfColor.fromHex("#D32F2F");
  final PdfColor lightGrey = PdfColor.fromHex("#F5F7FA");

  Future<Uint8List> _generatePdf(
    List<WarehouseReportItem> normalItems,
    List<WarehouseReportItem> defectiveItems,
    Map<String, int> globalStats,
    List<Map<String, dynamic>> warehouseDistribution,
    List<Map<String, dynamic>> topProducts,
    List<Map<String, dynamic>> movementStats,
  ) async {
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

    // 1. Add Analysis Page
    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
            pageFormat: PdfPageFormat.a4, margin: const pw.EdgeInsets.all(32)),
        header: (context) => _buildHeader(context, logoImage, brandPrimary),
        footer: (context) => _buildFooter(context, brandPrimary),
        build: (context) => [
          pw.Text(_l10n.analysisTitle,
              style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: brandPrimary)),
          pw.SizedBox(height: 20),
          _buildAnalysisDashboard(globalStats, warehouseDistribution,
              topProducts, movementStats, brandPrimary, brandAccent),
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
        header: (context) => _buildHeader(context, logoImage, brandPrimary),
        footer: (context) => _buildFooter(context, brandPrimary),
        build: (context) => [
          pw.Text(_l10n.reportTitle,
              style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: brandPrimary)),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard(
                  _l10n.reportStandardInventory,
                  '$totalNormalPallets',
                  brandAccent,
                  brandPrimary),
              pw.SizedBox(width: 20),
              _buildStatCard(
                  _l10n.reportDefectiveInventory,
                  '$totalDefectivePallets',
                  brandDefective,
                  brandPrimary),
            ],
          ),
          pw.SizedBox(height: 25),
          pw.Text(_l10n.reportStandardInventory,
              style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: brandAccent)),
          pw.SizedBox(height: 10),
          if (normalByProduct.isNotEmpty)
            _buildSummaryTable(normalByProduct, totalNormalPallets, brandAccent)
          else
            pw.Text(_l10n.reportNoStandardPallets,
                style: pw.TextStyle(
                    fontStyle: pw.FontStyle.italic, color: PdfColors.grey)),
          pw.SizedBox(height: 25),
          pw.Text(_l10n.reportDefectiveInventory,
              style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: brandDefective)),
          pw.SizedBox(height: 10),
          if (defectiveByProduct.isNotEmpty)
            _buildSummaryTable(
                defectiveByProduct, totalDefectivePallets, brandDefective)
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

      pdf.addPage(
        pw.MultiPage(
          pageTheme: pw.PageTheme(
              pageFormat: PdfPageFormat.a4,
              margin: const pw.EdgeInsets.all(32)),
          header: (context) => _buildHeader(context, logoImage, brandPrimary),
          footer: (context) => _buildFooter(context, brandPrimary),
          build: (context) => [
            pw.Text(warehouseName,
                style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: brandPrimary)),
            pw.SizedBox(height: 20),
            pw.Text(_l10n.reportStandardInventory,
                style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: brandAccent)),
            pw.SizedBox(height: 10),
            if (currentNormalItems.isNotEmpty) ...[
              _buildWarehouseTable(currentNormalItems, brandPrimary, lightGrey),
              pw.SizedBox(height: 10),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(_l10n.reportTotalStandard(totalNormalPallets),
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, color: brandPrimary)),
              ),
            ] else
              pw.Text(_l10n.reportNoStandardPallets,
                  style: pw.TextStyle(
                      fontStyle: pw.FontStyle.italic, color: PdfColors.grey)),
            pw.SizedBox(height: 25),
            pw.Text(_l10n.reportDefectiveInventory,
                style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: brandDefective)),
            pw.SizedBox(height: 10),
            if (currentDefectiveItems.isNotEmpty) ...[
              _buildWarehouseTable(
                  currentDefectiveItems, brandDefective, lightGrey),
              pw.SizedBox(height: 10),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(_l10n.reportTotalDefective(totalDefectivePallets),
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, color: brandDefective)),
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

  pw.Widget _buildHeader(
      pw.Context context, pw.ImageProvider logoImage, PdfColor brandPrimary) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
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

  pw.Widget _buildAnalysisDashboard(
      Map<String, int> globalStats,
      List<Map<String, dynamic>> warehouseDistribution,
      List<Map<String, dynamic>> topProducts,
      List<Map<String, dynamic>> movementStats,
      PdfColor primary,
      PdfColor secondary) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // 1. Global Stats
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _buildStatCard(_l10n.inStock, '${globalStats['totalIn'] ?? 0}',
                PdfColors.blue700, primary),
            pw.SizedBox(width: 10),
            _buildStatCard(_l10n.dispatched, '${globalStats['totalOut'] ?? 0}',
                PdfColors.green700, primary),
            pw.SizedBox(width: 10),
            _buildStatCard(_l10n.defective, '${globalStats['totalDefective'] ?? 0}',
                PdfColors.red700, primary),
          ],
        ),
        pw.SizedBox(height: 20),

        // 2. Tables Row
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Warehouse Distribution
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(_l10n.warehouseDistribution,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 14)),
                  pw.SizedBox(height: 5),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300),
                    children: warehouseDistribution.map((item) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(
                                item['warehouseName'] ?? _l10n.unknown,
                                style: const pw.TextStyle(fontSize: 10)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text('${item['count']}',
                                style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            pw.SizedBox(width: 20),
            // Top Products
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(_l10n.top5Products,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 14)),
                  pw.SizedBox(height: 5),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300),
                    children: topProducts.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      PdfColor rankColor = PdfColors.grey300;
                      if (index == 0) rankColor = PdfColor.fromHex("#FFD700");
                      if (index == 1) rankColor = PdfColor.fromHex("#C0C0C0");
                      if (index == 2) rankColor = PdfColor.fromHex("#CD7F32");

                      return pw.TableRow(
                        children: [
                          pw.Container(
                            width: 15,
                            height: 15,
                            margin: const pw.EdgeInsets.all(5),
                            decoration: pw.BoxDecoration(
                                color: rankColor, shape: pw.BoxShape.circle),
                            child: pw.Center(
                                child: pw.Text('${index + 1}',
                                    style: const pw.TextStyle(fontSize: 8))),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 5, horizontal: 2),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(item['productName'] ?? _l10n.unknown,
                                    style: const pw.TextStyle(fontSize: 10)),
                                pw.Text(item['description'] ?? '',
                                    style: const pw.TextStyle(
                                        fontSize: 8, color: PdfColors.grey600)),
                              ],
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text('${item['count']}',
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 20),

        // 3. Movement Chart (Simplified)
        pw.Text(_l10n.movementTrends30Days,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
        pw.SizedBox(height: 5),
        pw.Container(
          height: 150,
          width: double.infinity,
          decoration:
              pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)),
          padding: const pw.EdgeInsets.all(10),
          child: _buildPdfChart(movementStats),
        ),
        pw.Row(children: [
          pw.Container(width: 8, height: 8, color: PdfColors.green),
          pw.SizedBox(width: 4),
          pw.Text(_l10n.inStock, style: const pw.TextStyle(fontSize: 8)),
          pw.SizedBox(width: 10),
          pw.Container(width: 8, height: 8, color: PdfColors.orange),
          pw.SizedBox(width: 4),
          pw.Text(_l10n.dispatched, style: const pw.TextStyle(fontSize: 8)),
        ])
      ],
    );
  }

  pw.Widget _buildStatCard(
      String title, String value, PdfColor color, PdfColor textColor) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(5),
        ),
        child: pw.Column(
          children: [
            pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: color)),
            pw.Text(title,
                style:
                    const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildPdfChart(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return pw.Center(child: pw.Text(_l10n.noData));

    Map<String, int> inData = {};
    Map<String, int> outData = {};

    for (var item in data) {
      final date = item['date'] as String;
      final type = item['type'] as String;
      final count = item['count'] as int;

      if (type == 'in') {
        inData[date] = count;
      } else {
        outData[date] = count;
      }
    }

    List<String> sortedDates = inData.keys.toSet().union(outData.keys.toSet()).toList();
    sortedDates.sort();

    int maxCount = 1;
    for (var v in inData.values) if (v > maxCount) maxCount = v;
    for (var v in outData.values) if (v > maxCount) maxCount = v;

    final double chartHeight = 100.0;

    List<pw.Widget> barColumns = [];
    for (final date in sortedDates) {
      final int inVal = inData[date] ?? 0;
      final int outVal = outData[date] ?? 0;

      final double hIn = (inVal.toDouble() / maxCount.toDouble()) * chartHeight;
      final double hOut = (outVal.toDouble() / maxCount.toDouble()) * chartHeight;

      barColumns.add(
        pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Container(
                  width: 4,
                  height: hIn < 1 ? 1 : hIn,
                  color: inVal > 0 ? PdfColors.green : PdfColors.grey300,
                ),
                pw.Container(width: 1),
                pw.Container(
                  width: 4,
                  height: hOut < 1 ? 1 : hOut,
                  color: outVal > 0 ? PdfColors.orange : PdfColors.grey300,
                ),
              ],
            ),
          ],
        ),
      );
    }

    List<pw.Widget> dateLabels = [];
    final int labelSkip = sortedDates.length > 15 ? 5 : (sortedDates.length > 7 ? 3 : 1);
    for (int i = 0; i < sortedDates.length; i++) {
      if (i % labelSkip == 0) {
        final date = sortedDates[i];
        final label = date.length >= 10 ? '${date.substring(8, 10)}/${date.substring(5, 7)}' : date;
        dateLabels.add(
          pw.Container(
            width: 10,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: 6, color: PdfColors.grey600),
              textAlign: pw.TextAlign.center,
            ),
          ),
        );
      } else {
        dateLabels.add(pw.Container(width: 10));
      }
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          height: chartHeight,
          decoration: pw.BoxDecoration(
            border: pw.Border(
              left: pw.BorderSide(color: PdfColors.grey600, width: 1),
              bottom: pw.BorderSide(color: PdfColors.grey600, width: 1),
            ),
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
            children: barColumns,
          ),
        ),
        pw.Container(
          height: 14,
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
            children: dateLabels,
          ),
        ),
      ],
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

  pw.Widget _buildWarehouseTable(List<WarehouseReportItem> items,
      PdfColor headerColor, PdfColor zebraColor) {
    final headers = [_l10n.product, _l10n.batch, _l10n.reportPalletCount];

    final headerStyle = pw.TextStyle(
        fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10);
    const cellStyle = pw.TextStyle(fontSize: 10);
    const cellPadding = pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8);

    final headerRow = pw.TableRow(
      decoration: pw.BoxDecoration(color: headerColor),
      children: headers.map((header) {
        return pw.Padding(
          padding: cellPadding,
          child: pw.Text(
            header,
            style: headerStyle,
            textAlign: header == _l10n.reportPalletCount
                ? pw.TextAlign.right
                : pw.TextAlign.left,
          ),
        );
      }).toList(),
    );

    final List<pw.TableRow> dataRows = [];
    for (var index = 0; index < items.length; index++) {
      final item = items[index];
      final bool isZebra = index % 2 != 0;

      dataRows.add(
        pw.TableRow(
          decoration: isZebra
              ? pw.BoxDecoration(color: zebraColor)
              : const pw.BoxDecoration(color: PdfColors.white),
          children: [
            // Producto
            pw.Padding(
              padding: cellPadding,
              child: pw.Text(item.productName, style: cellStyle),
            ),
            // Lote
            pw.Padding(
              padding: cellPadding,
              child: pw.Text(item.lotName, style: cellStyle),
            ),
            // Nº Palets
            pw.Padding(
              padding: cellPadding,
              child: pw.Text(
                item.palletCount.toString(),
                style: cellStyle,
                textAlign: pw.TextAlign.right,
              ),
            ),
          ],
        ),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(3), // Producto
        1: pw.FlexColumnWidth(3), // Lote
        2: pw.FlexColumnWidth(1.5), // Contador
      },
      children: [
        headerRow,
        ...dataRows,
      ],
    );
  }

  pw.Widget _buildSummaryTable(
      Map<String, int> itemsByProduct, int total, PdfColor color) {
    final headerStyle = pw.TextStyle(
        fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10);
    const cellStyle = pw.TextStyle(fontSize: 10);
    const cellPadding = pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8);

    final headerRow = pw.TableRow(
      decoration: pw.BoxDecoration(color: color),
      children: [
        pw.Padding(
          padding: cellPadding,
          child: pw.Text(_l10n.product, style: headerStyle),
        ),
        pw.Padding(
          padding: cellPadding,
          child: pw.Text(_l10n.reportPalletCount,
              style: headerStyle, textAlign: pw.TextAlign.right),
        ),
      ],
    );

    final sortedEntries = itemsByProduct.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final List<pw.TableRow> dataRows = [];
    for (var index = 0; index < sortedEntries.length; index++) {
      final entry = sortedEntries[index];
      final bool isZebra = index % 2 != 0;

      dataRows.add(
        pw.TableRow(
          decoration: isZebra
              ? pw.BoxDecoration(color: lightGrey)
              : const pw.BoxDecoration(color: PdfColors.white),
          children: [
            pw.Padding(
              padding: cellPadding,
              child: pw.Text(entry.key, style: cellStyle),
            ),
            pw.Padding(
              padding: cellPadding,
              child: pw.Text(
                entry.value.toString(),
                style: cellStyle,
                textAlign: pw.TextAlign.right,
              ),
            ),
          ],
        ),
      );
    }

    dataRows.add(
      pw.TableRow(
        decoration: pw.BoxDecoration(color: lightGrey),
        children: [
          pw.Padding(
            padding: cellPadding,
            child: pw.Text('Total',
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, fontSize: 10)),
          ),
          pw.Padding(
            padding: cellPadding,
            child: pw.Text(
              total.toString(),
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, fontSize: 10),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(4),
        1: pw.FlexColumnWidth(1.5),
      },
      children: [
        headerRow,
        ...dataRows,
      ],
    );
  }

  Color filterActive() {
    return selectedProduct == null ? Colors.white : kcDefectiveColor;
  }
}
