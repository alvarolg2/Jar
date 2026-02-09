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
import 'package:jar/ui/common/app_colors.dart';
import 'package:jar/ui/common/database_helper.dart';
import 'package:jar/ui/views/create_received/create_received_view.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;

class HomeViewModel extends ReactiveViewModel {
  final _warehouseDataService = locator<WarehouseDataService>();
  final _filterService = locator<FilterService>();
  final _dialogService = locator<DialogService>();
  final _navigationService = locator<NavigationService>();
  final _localeService = locator<LocaleService>();

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

  AppLocalizations get l10n => AppLocalizations.of(StackedService.navigatorKey!.currentContext!)!;

  void setShowDropdown(bool value) {
    _filterService.setShowDropdown(value);
  }

  @override
  List<ListenableServiceMixin> get listenableServices => [_warehouseDataService, _filterService,];

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
      _appVersion = '${l10n.version} ${packageInfo.version}';
      notifyListeners();
    } catch (e) {
      _appVersion = l10n.versionUnknown;
      notifyListeners();
    }
  }

  Future<void> _loadInitialData() async {
    await fetchWarehouses();
    await fetchPalletCounts();
  }

  void initTabController(TickerProvider vsync) {
    if (tabController != null && tabController!.length == warehouseCount) {
      if (tabController!.index != currentIndex) tabController!.animateTo(currentIndex);
      return;
    }
    tabController?.removeListener(_onTabChanged);
    tabController?.dispose();
    if (warehouseCount == 0) {
      tabController = null;
      return;
    }
    tabController = TabController(length: warehouseCount, initialIndex: currentIndex, vsync: vsync);
    tabController!.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (currentIndex != tabController!.index && !tabController!.indexIsChanging) {
      currentIndex = tabController!.index;
      notifyListeners();
    }
  }

  Future<void> fetchWarehouses() async {
    _warehouseDataService.warehouses.value = await DatabaseHelper.instance.getAllWarehouses();
    if (currentIndex >= warehouses.length) {
      currentIndex = warehouses.isNotEmpty ? warehouses.length - 1 : 0;
    }
  }

  Future<void> fetchPalletCounts() async {
    _warehouseDataService.palletCounts.value = await DatabaseHelper.instance.getAllWarehousePalletCounts(isDefective: isActivated);
  }

  Future<void> addWarehouse(String name) async {
    await runBusyFuture(DatabaseHelper.instance.createWarehouse(Warehouse(name: name)));
    await fetchWarehouses();
    await fetchPalletCounts();
  }

  Future<void> deleteWarehouse(Warehouse warehouse) async {
    await runBusyFuture(DatabaseHelper.instance.deleteWarehouse(warehouse.id!));
    await fetchWarehouses();
    await fetchPalletCounts();
  }

  Future<void> updateWarehouseName(Warehouse warehouse, String name) async {
    warehouse.name = name;
    await runBusyFuture(DatabaseHelper.instance.updateWarehouse(warehouse));
    notifyListeners();
  }

  void toggleActivation() {
    isActivated = !isActivated;
    _filterService.setSelectedProduct(null);
    fetchPalletCounts();
    notifyListeners();  
  }

  void navigateToCreateReceived(BuildContext context) {
    if (warehouses.isNotEmpty) {
      final Warehouse selectedWarehouse = warehouses[currentIndex];
      Navigator.push(context, MaterialPageRoute(builder: (context) => CreateReceivedView(warehouse: selectedWarehouse)));
    }
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
      await DatabaseHelper.instance.close();
      await Future.delayed(const Duration(milliseconds: 500));
      final path = await DatabaseHelper.getDatabasePath();
      await Share.shareXFiles(
        [XFile(path)],
        subject: l10n.dbBackupSubject(DateTime.now().toLocal().toString().split(' ')[0]),
        text: l10n.dbBackupBody
      );
    } catch (e) {
      await _dialogService.showDialog(title: l10n.exportError, description: l10n.exportErrorDescription(e.toString()));
    } finally {
      setBusy(false);
    }
  }

  Future<void> importDatabase() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['db']);
      if (result == null) return;

      final response = await _dialogService.showConfirmationDialog(
        title: l10n.importConfirm,
        description: l10n.importConfirmMessage,
        confirmationTitle: l10n.importConfirmYes,
        cancelTitle: l10n.cancel,
      );
      if (response?.confirmed != true) return;

      setBusy(true);

      await DatabaseHelper.instance.close();
      await Future.delayed(const Duration(milliseconds: 200));

      final sourcePath = result.files.single.path!;
      final destinationPath = await DatabaseHelper.getDatabasePath();
      await File(sourcePath).copy(destinationPath);

      setBusy(false);
      await _dialogService.showDialog(title: l10n.importComplete, description: l10n.importCompleteMessage);
      
      _navigationService.clearStackAndShow(Routes.homeView);

    } catch (e) {
      setBusy(false);
      await _dialogService.showDialog(title: l10n.importError, description: l10n.importErrorDescription(e.toString()));
    }
  }

Future<void> generateAndShareWarehouseReport() async {
    setBusy(true);
    try {
      final normalItems =
          await DatabaseHelper.instance.getWarehouseReportItems(isDefective: false);
      final defectiveItems =
          await DatabaseHelper.instance.getWarehouseReportItems(isDefective: true);

      if (normalItems.isEmpty && defectiveItems.isEmpty) {
        await _dialogService.showDialog(
            title: l10n.reportEmptyTitle,
            description: l10n.reportEmptyMessage);
        setBusy(false);
        return;
      }

      final pdfBytes = await _generatePdf(normalItems, defectiveItems);

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = await File('${tempDir.path}/report_warehouse_$timestamp.pdf')
          .writeAsBytes(pdfBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: l10n.reportSubject(DateTime.now().toLocal().toString().split(' ')[0]),
        text: l10n.reportBody,
      );
    } catch (e) {
      await _dialogService.showDialog(
          title: l10n.pdfError,
          description: l10n.pdfErrorDescription(e.toString()));
    } finally {
      setBusy(false);
    }
  }

  final PdfColor brandPrimary = PdfColor.fromHex("#0D253F");
  final PdfColor brandAccent = PdfColor.fromHex("#26A69A");
  final PdfColor brandDefective = PdfColor.fromHex("#D32F2F");
  final PdfColor lightGrey = PdfColor.fromHex("#F5F7FA");

  Future<Uint8List> _generatePdf(List<WarehouseReportItem> normalItems,
      List<WarehouseReportItem> defectiveItems) async {
    final pdf = pw.Document();

    final logoData = await rootBundle.load('assets/icon/icon.png');
    final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

    final allWarehouseNames = {
      ...normalItems.map((i) => i.warehouseName),
      ...defectiveItems.map((i) => i.warehouseName)
    }.toList();
    allWarehouseNames.sort();

    for (final warehouseName in allWarehouseNames) {
      final currentNormalItems =
          normalItems.where((i) => i.warehouseName == warehouseName).toList();
      final currentDefectiveItems =
          defectiveItems.where((i) => i.warehouseName == warehouseName).toList();

      final totalNormalPallets =
          currentNormalItems.fold<int>(0, (sum, item) => sum + item.palletCount);
      final totalDefectivePallets = currentDefectiveItems
          .fold<int>(0, (sum, item) => sum + item.palletCount);

      pdf.addPage(
        pw.MultiPage(
          pageTheme: pw.PageTheme(
              pageFormat: PdfPageFormat.a4,
              margin: const pw.EdgeInsets.all(32)),
          header: (context) =>
              _buildHeader(context, logoImage, brandPrimary),
          footer: (context) => _buildFooter(context, brandPrimary),
          build: (context) => [
            pw.Text(warehouseName,
                style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: brandPrimary)),
            pw.SizedBox(height: 20),

            pw.Text(l10n.reportStandardInventory,
                style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: brandAccent)),
            pw.SizedBox(height: 10),
            if (currentNormalItems.isNotEmpty) ...[
              _buildWarehouseTable(
                  currentNormalItems, brandPrimary, lightGrey),
              pw.SizedBox(height: 10),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(l10n.reportTotalStandard(totalNormalPallets),
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, color: brandPrimary)),
              ),
            ] else
              pw.Text(l10n.reportNoStandardPallets,
                  style: pw.TextStyle(
                      fontStyle: pw.FontStyle.italic, color: PdfColors.grey)),

            pw.SizedBox(height: 25),

            pw.Text(l10n.reportDefectiveInventory,
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
                child: pw.Text(l10n.reportTotalDefective(totalDefectivePallets),
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: brandDefective)),
              ),
            ] else
              pw.Text(l10n.reportNoDefectivePallets,
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
              pw.Text(l10n.reportTitle,
                  style: pw.TextStyle(
                      color: brandPrimary,
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold)),
              pw.Text(
                  l10n.reportGenerated(DateTime.now().toLocal().toString().split(' ')[0]),
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
        l10n.reportPage(context.pageNumber, context.pagesCount),
        style: pw.TextStyle(
          color: PdfColor(brandPrimary.red, brandPrimary.green, brandPrimary.blue, 0.7),
          fontSize: 9,
        ),
      ),
    );
  }

  pw.Widget _buildWarehouseTable(List<WarehouseReportItem> items,
      PdfColor headerColor, PdfColor zebraColor) {
    
    final headers = [l10n.product, l10n.batch, l10n.reportPalletCount];

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
            textAlign: header == l10n.reportPalletCount ? pw.TextAlign.right : pw.TextAlign.left,
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
        0: pw.FlexColumnWidth(3),   // Producto
        1: pw.FlexColumnWidth(3),   // Lote
        2: pw.FlexColumnWidth(1.5), // Contador
      },
      children: [
        headerRow,
        ...dataRows,
      ],
    );
  }

  Color filterActive () {
    return selectedProduct == null ? Colors.white : kcDefectiveColor;
  }
}