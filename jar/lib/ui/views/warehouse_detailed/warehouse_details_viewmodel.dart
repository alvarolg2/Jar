import 'package:jar/helpers/database_helper.dart';
import 'package:jar/models/received.dart';
import 'package:jar/models/warehouse.dart';
import 'package:stacked/stacked.dart';

class WarehouseDetailsViewModel extends FutureViewModel<List<Received>> {
  final Warehouse warehouse;

  WarehouseDetailsViewModel(this.warehouse);

  @override
  Future<List<Received>> futureToRun() async {
    // Usa el warehouseId para filtrar los received
    return DatabaseHelper.instance.getReceivedForIdWarehouse(warehouse.id!);
  }
}
