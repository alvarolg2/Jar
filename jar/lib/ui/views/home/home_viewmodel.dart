import 'package:flutter/material.dart';
import 'package:jar/helpers/database_helper.dart';
import 'package:jar/models/user.dart';
import 'package:jar/models/warehouse.dart';
import 'package:jar/ui/views/create_received/create_received_view.dart';
import 'package:stacked/stacked.dart';

class HomeViewModel extends FutureViewModel {
  List<Warehouse> warehouses = [];
  List<User> users = [];
  User? currentUser;
  Warehouse? selectedWarehouse;
  int get warehouseCount => warehouses.length;

  @override
  Future futureToRun() async {
    await fetchUsers();
    await fetchWarehouses();
  }

  Future<bool> fetchWarehouses() async {
    warehouses = await DatabaseHelper.instance.getWarehouses();
    notifyListeners();
    return true;
  }

  Future<bool> fetchUsers() async {
    users = await DatabaseHelper.instance.getUsers();
    currentUser = users[0];
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

  void navigateToCreateReceived(BuildContext context, int index) {
    final Warehouse selectedWarehouse = warehouses[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateReceivedView(
            warehouse: selectedWarehouse, user: currentUser!),
      ),
    );
  }
}
