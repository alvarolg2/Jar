import 'package:jar/models/warehouse.dart';
import 'package:stacked/stacked.dart';

class WarehouseDataService with ListenableServiceMixin {
  
  final ReactiveValue<Map<int, int>> palletCounts = ReactiveValue<Map<int, int>>({});
  final ReactiveValue<List<Warehouse>> warehouses = ReactiveValue<List<Warehouse>>([]);
  final ReactiveValue<bool> _dataChanged = ReactiveValue<bool>(false);

  WarehouseDataService() {
    listenToReactiveValues([palletCounts, warehouses, _dataChanged]);
  }
  
  void notifyDataChanged() {
    _dataChanged.value = !_dataChanged.value;
    notifyListeners();
  }
}