import 'package:flutter/material.dart';
import 'package:jar/helpers/database_helper.dart';
import 'package:jar/models/batch.dart';
import 'package:jar/models/jar.dart';
import 'package:jar/models/pallet.dart';
import 'package:jar/models/user.dart';
import 'package:jar/models/warehouse.dart';
import 'package:stacked/stacked.dart';

class CreateReceivedViewModel extends BaseViewModel {
  final _dateController = TextEditingController();
  final _productController = TextEditingController();
  final _batchController = TextEditingController();

  TextEditingController get dateController => _dateController;
  TextEditingController get productController => _productController;
  TextEditingController get batchController => _batchController;

  // Método para inicializar cualquier dato si es necesario
  void init(Warehouse warehouse, User user) {
    // Inicializa tus controladores o realiza alguna lógica inicial aquí
  }

  Future<void> createReceived(Warehouse warehouse, User user) async {
    setBusy(true);
    try {
      Jar currentJar = await DatabaseHelper.instance
          .createJar(Jar(name: productController.text));
      Batch2 currentBatch = await DatabaseHelper.instance.createBatch(Batch2(
          name: batchController.text, jarId: currentJar.id!, palletIds: []));
      // Aquí va tu lógica para crear el "Received", usando los datos de los controladores y los objetos Warehouse y User
      await DatabaseHelper.instance.createReceived(
          date: _dateController.text,
          warehouseId: warehouse.id!,
          userId: user.id!,
          jarId: currentJar.id!,
          batchId: currentBatch.id!);
      setBusy(false);
      // Lógica después de crear el "Received" con éxito, como mostrar un SnackBar
    } catch (e) {
      setBusy(false);
      // Maneja cualquier error que ocurra
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _productController.dispose();
    _batchController.dispose();
    super.dispose();
  }
}
