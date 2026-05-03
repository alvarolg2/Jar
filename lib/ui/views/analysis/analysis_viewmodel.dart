import 'package:jar/ui/common/database_helper.dart';
import 'package:stacked/stacked.dart';

class AnalysisViewModel extends BaseViewModel {
  Map<String, int> _globalStats = {};
  Map<String, int> get globalStats => _globalStats;

  List<Map<String, dynamic>> _warehouseDistribution = [];
  List<Map<String, dynamic>> get warehouseDistribution =>
      _warehouseDistribution;

  List<Map<String, dynamic>> _topProducts = [];
  List<Map<String, dynamic>> get topProducts => _topProducts;

  List<Map<String, dynamic>> _movementStats = [];
  List<Map<String, dynamic>> get movementStats => _movementStats;

  Future<void> initialise() async {
    setBusy(true);
    await Future.wait([
      _fetchGlobalStats(),
      _fetchWarehouseDistribution(),
      _fetchTopProducts(),
      _fetchMovementStats(),
    ]);
    setBusy(false);
  }

  Future<void> _fetchGlobalStats() async {
    _globalStats = await DatabaseHelper.instance.getGlobalStats();
  }

  Future<void> _fetchWarehouseDistribution() async {
    _warehouseDistribution =
        await DatabaseHelper.instance.getWarehouseDistribution();
  }

  Future<void> _fetchTopProducts() async {
    _topProducts = await DatabaseHelper.instance.getTopProducts(5);
  }

  Future<void> _fetchMovementStats() async {
    _movementStats = await DatabaseHelper.instance.getMovementStats(30);
  }
}
