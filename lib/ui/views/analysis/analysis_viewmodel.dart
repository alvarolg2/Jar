import 'package:jar/app/app.locator.dart';
import 'package:jar/services/pallet_repository.dart';
import 'package:stacked/stacked.dart';

class AnalysisViewModel extends BaseViewModel {
  final _palletRepo = locator<PalletRepository>();

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
    _globalStats = await _palletRepo.getGlobalStats();
  }

  Future<void> _fetchWarehouseDistribution() async {
    _warehouseDistribution = await _palletRepo.getWarehouseDistribution();
  }

  Future<void> _fetchTopProducts() async {
    _topProducts = await _palletRepo.getTopProducts(5);
  }

  Future<void> _fetchMovementStats() async {
    _movementStats = await _palletRepo.getMovementStats(30);
  }
}
