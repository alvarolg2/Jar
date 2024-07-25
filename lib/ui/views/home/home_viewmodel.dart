import 'package:flutter/material.dart';
import 'package:jar/ui/common/database_helper.dart';
import 'package:jar/models/warehouse.dart';
import 'package:jar/ui/views/create_received/create_received_view.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stacked/stacked.dart';

class HomeViewModel extends FutureViewModel {
  List<Warehouse> warehouses = [];
  bool isActivated = false;
  Warehouse? selectedWarehouse;
  int get warehouseCount => warehouses.length;

  @override
  Future futureToRun() async {
    await fetchWarehouses();
  }

  Future<bool> fetchWarehouses() async {
    warehouses = await DatabaseHelper.instance.getAllWarehouses();
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
      selectedWarehouse = null;
    }
    notifyListeners();
  }

  Future<void> addWarehouse(String name) async {
    setBusy(true);
    await DatabaseHelper.instance.createWarehouse(Warehouse(name: name));
    await fetchWarehouses();
    setBusy(false);
  }

  Future<void> updateWarehouseName(Warehouse warehouse, String name) async {
    warehouse.name = name;
    await DatabaseHelper.instance.updateWarehouse(warehouse);
    await fetchWarehouses();
  }

  Future<void> deleteWarehouse(Warehouse warehouse) async {
    setBusy(true);
    await DatabaseHelper.instance.deleteWarehouse(warehouse.id!);
    await fetchWarehouses();
    setBusy(false);
  }

  int getTabLength() {
    return warehouses.length;
  }

  void navigateToCreateReceived(BuildContext context, int index) {
    final Warehouse selectedWarehouse = warehouses[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateReceivedView(warehouse: selectedWarehouse),
      ),
    );
  }

  // TODO:  duplicado
  Future<int> getTotalPalletsNotOut({int? productId, required int warehouseId}) async {
    final db = await DatabaseHelper.instance.database;
    String query = '''
      SELECT COUNT(*) as count FROM pallet
      JOIN pallet_lot ON pallet.id = pallet_lot.id_pallet
      JOIN lot ON pallet_lot.id_lot = lot.id
      WHERE pallet.warehouse = ? AND pallet.is_out = 0 AND pallet.defective = 0
    ''';
    List<dynamic> params = [warehouseId];

    if (productId != null) {
      query += ' AND lot.product = ?';
      params.add(productId);
    }

    final result = await db.rawQuery(query, params);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // TODO: duplicado
  Future<int> getTotalPalletsNotOutDefective({int? productId, required int warehouseId}) async {
    final db = await DatabaseHelper.instance.database;
    String query = '''
      SELECT COUNT(*) as count FROM pallet
      JOIN pallet_lot ON pallet.id = pallet_lot.id_pallet
      JOIN lot ON pallet_lot.id_lot = lot.id
      WHERE pallet.warehouse = ? AND pallet.is_out = 0 AND pallet.defective = 1
    ''';
    List<dynamic> params = [warehouseId];

    if (productId != null) {
      query += ' AND lot.product = ?';
      params.add(productId);
    }

    final result = await db.rawQuery(query, params);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getTotalPalletsNotOutAll() async {
    final db = await DatabaseHelper.instance.database;
    String query = '''
      SELECT COUNT(*) as count FROM pallet
      JOIN pallet_lot ON pallet.id = pallet_lot.id_pallet
      JOIN lot ON pallet_lot.id_lot = lot.id
      WHERE pallet.is_out = 0 AND pallet.defective = 0
    ''';
    List<dynamic> params = [];

    final result = await db.rawQuery(query, params);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getTotalPalletsNotOutDefectiveAll() async {
    final db = await DatabaseHelper.instance.database;
    String query = '''
      SELECT COUNT(*) as count FROM pallet
      JOIN pallet_lot ON pallet.id = pallet_lot.id_pallet
      JOIN lot ON pallet_lot.id_lot = lot.id
      WHERE pallet.is_out = 0 AND pallet.defective = 1
    ''';
    List<dynamic> params = [];

    final result = await db.rawQuery(query, params);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  void toggleActivation(){
    isActivated = !isActivated;
    notifyListeners();
  }



}
