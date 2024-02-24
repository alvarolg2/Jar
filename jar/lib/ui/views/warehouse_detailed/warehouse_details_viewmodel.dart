import 'package:jar/helpers/database_helper.dart';
import 'package:jar/models/lot.dart';
import 'package:jar/models/product.dart';
import 'package:jar/models/warehouse.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stacked/stacked.dart';

class WarehouseDetailsViewModel extends FutureViewModel<List<Lot>> {
  final Warehouse warehouse;

  WarehouseDetailsViewModel(this.warehouse);

  @override
  Future<List<Lot>> futureToRun() async {
    List<Product> p = await DatabaseHelper.instance.getAllProduct();
    p;
    return DatabaseHelper.instance
        .getAllLotsByWarehouseIdWithPallets(warehouse.id!);
  }
}
