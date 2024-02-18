import 'package:jar/helpers/database_helper.dart';
import 'package:jar/models/warehouse.dart';
import 'package:stacked/stacked.dart';

class HomeViewModel extends FutureViewModel {
  List<Warehouse> warehouses = [];
  Warehouse? selectedWarehouse;
  int get warehouseCount => warehouses.length;

  @override
  Future futureToRun() async {
    await fetchWarehouses();
  }

  Future<bool> fetchWarehouses() async {
    setBusy(true);
    warehouses = await DatabaseHelper.instance.getWarehouses();
    setBusy(false);
    notifyListeners();
    return true;
  }

  void selectWarehouse(Warehouse warehouse) {
    selectedWarehouse = warehouse;
    notifyListeners();
  }

  // Añade esta función para seleccionar el almacén por índice
  void selectWarehouseByIndex(int index) {
    if (index < warehouses.length) {
      selectedWarehouse = warehouses[index];
    } else {
      selectedWarehouse = null; // O maneja la lógica para el botón de añadir
    }
    notifyListeners();
  }

  Future<void> addWarehouse(String name) async {
    setBusy(true);
    await DatabaseHelper.instance.createWarehouse(Warehouse(name: name));
    await fetchWarehouses();
    setBusy(false);
  }

  Future<void> updateWarehouseName(int id, String newName) async {
    await DatabaseHelper.instance.updateWarehouseName(id, newName);
    await fetchWarehouses();
  }

  Future<void> deleteWarehouse(Warehouse warehouse) async {
    setBusy(true);
    await DatabaseHelper.instance.deleteWarehouse(warehouse.id!);
    await fetchWarehouses();
    setBusy(false);
  }

  // Considera añadir un método para actualizar el TabController cuando cambie la lista de almacenes
  int getTabLength() {
    return warehouses.length; // +1 por el botón de añadir
  }
}
