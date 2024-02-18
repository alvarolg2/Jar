import 'package:jar/helpers/database_helper.dart';
import 'package:jar/models/warehouse.dart';
import 'package:stacked/stacked.dart';

class HomeViewModel extends FutureViewModel {
  List<Warehouse> warehouses = [];
  Warehouse? selectedWarehouse;

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

  Future<void> addWarehouse(String name) async {
    setBusy(true);
    await DatabaseHelper.instance.createWarehouse(Warehouse(name: name));
    await fetchWarehouses(); // Recargar la lista de almacenes
    setBusy(false);
  }

  Future<void> updateWarehouseName(int id, String newName) async {
    await DatabaseHelper.instance.updateWarehouseName(id, newName);
    await fetchWarehouses(); // Actualizar la lista después de cambiar el nombre
  }

  Future<void> deleteWarehouse(Warehouse warehouse) async {
    setBusy(true);
    await DatabaseHelper.instance.deleteWarehouse(warehouse.id!);
    await fetchWarehouses(); // Recargar la lista de almacenes para reflejar la eliminación
    setBusy(false);
  }
}
