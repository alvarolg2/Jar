import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:jar/app/app.locator.dart';
import 'package:jar/app/app.router.dart';
import 'package:jar/models/warehouse.dart';
import 'package:jar/services/warehouse_data_service.dart';
import 'package:jar/ui/common/database_helper.dart';
import 'package:jar/ui/views/create_received/create_received_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:share_plus/share_plus.dart';

class HomeViewModel extends ReactiveViewModel {
  final _warehouseDataService = locator<WarehouseDataService>();
  final _dialogService = locator<DialogService>();
  final _navigationService = locator<NavigationService>();

  bool isActivated = false;
  int currentIndex = 0;
  TabController? tabController;

  Map<int, int> get palletCounts => _warehouseDataService.palletCounts.value;
  List<Warehouse> get warehouses => _warehouseDataService.warehouses.value;
  int get warehouseCount => warehouses.length;

  @override
  List<ListenableServiceMixin> get listenableServices => [_warehouseDataService];

  @override
  void dispose() {
    tabController?.removeListener(_onTabChanged);
    tabController?.dispose();
    super.dispose();
  }

  Future<void> initialise() async {
    await runBusyFuture(_loadInitialData());
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
    fetchPalletCounts();
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
        subject: 'Backup Base de Datos - JAR App - ${DateTime.now().toIso8601String()}',
        text: 'Adjunto se encuentra la base de datos "warehouse_transport.db".'
      );
    } catch (e) {
      await _dialogService.showDialog(title: 'Error al Exportar', description: 'No se pudo exportar la base de datos. Detalle: ${e.toString()}');
    } finally {
      setBusy(false);
    }
  }

  Future<void> importDatabase() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['db']);
      if (result == null) return;

      final response = await _dialogService.showConfirmationDialog(
        title: 'Confirmar Importación',
        description: '¿Estás seguro de que quieres importar este archivo? Todos los datos actuales se borrarán y serán reemplazados por los del archivo seleccionado. Esta acción no se puede deshacer.',
        confirmationTitle: 'Sí, Importar',
        cancelTitle: 'Cancelar',
      );
      if (response?.confirmed != true) return;

      setBusy(true);

      await DatabaseHelper.instance.close();
      await Future.delayed(const Duration(milliseconds: 200));

      final sourcePath = result.files.single.path!;
      final destinationPath = await DatabaseHelper.getDatabasePath();
      await File(sourcePath).copy(destinationPath);

      setBusy(false);
      await _dialogService.showDialog(title: 'Importación Completa', description: 'La base de datos se ha importado correctamente. La aplicación se reiniciará para cargar los nuevos datos.');
      
      _navigationService.clearStackAndShow(Routes.homeView);

    } catch (e) {
      setBusy(false);
      await _dialogService.showDialog(title: 'Error al Importar', description: 'No se pudo importar la base de datos. Asegúrate de que es un archivo válido. Detalle: ${e.toString()}');
    }
  }
}