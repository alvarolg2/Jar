import 'package:jar/app/app.bottomsheets.dart';
import 'package:jar/app/app.locator.dart';
import 'package:jar/models/lot.dart';
import 'package:jar/models/product.dart';
import 'package:jar/models/warehouse.dart';
import 'package:jar/services/filter_service.dart';
import 'package:jar/services/warehouse_data_service.dart';
import 'package:jar/ui/common/database_helper.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class WarehouseDetailsViewModel extends FutureViewModel<List<Lot>> {
  final _sheetService = locator<BottomSheetService>();
  final _warehouseDataService = locator<WarehouseDataService>();
  final _filterService = locator<FilterService>();

  final Warehouse warehouse;
  final bool isDefective;

  WarehouseDetailsViewModel({
    required this.warehouse,
    required this.isDefective,
  });

  List<Product> allProducts = [];
  List<Lot> lots = [];

  bool get showDropdown => _filterService.showDropdown.value;
  bool get filtersApply => _filterService.filtersApply.value;
  Product? get selectedProduct => _filterService.selectedProduct.value;

  @override
  List<ListenableServiceMixin> get listenableServices => [_filterService];

  @override
  Future<List<Lot>> futureToRun() => _fetchData();

  @override
  void onData(List<Lot>? data) {
    super.onData(data);
    _updateGlobalPalletCount();
  }

  Future<List<Lot>> _fetchData() async {
    if (!isDefective) {
      allProducts = await DatabaseHelper.instance.getProductsByPalletsNotOutWithCount(warehouse.id!);
    } else {
      allProducts = [];
    }

    lots = await DatabaseHelper.instance.getLotsWithPallets(
      warehouseId: warehouse.id!,
      isDefective: isDefective,
      productId: selectedProduct?.id,
    );

    return lots;
  }
  
  Future<void> _updateGlobalPalletCount() async {
      _warehouseDataService.palletCounts.value = await DatabaseHelper.instance.getAllWarehousePalletCounts(isDefective: isDefective);
  }


  Future<void> selectProduct(Product? product) async {
    _filterService.setSelectedProduct(product);
    await initialise();
  }

  Future<void> showPalletSheet(Lot lot, int numPallets) async {
    SheetResponse? response = await _sheetService.showCustomSheet(
        variant: BottomSheetType.pallet, 
        title: lot.name, 
        data: {"num_pallets": numPallets});
    
    int? extracNumPallets = response?.data['count'];

    if (extracNumPallets != null && extracNumPallets > 0) {
      setBusy(true);
      if (isDefective) {
        await DatabaseHelper.instance.markPalletsAsOutDefective(lot.id!, extracNumPallets, warehouse.id!);
      } else {
        await DatabaseHelper.instance.markPalletsAsOut(lot.id!, extracNumPallets, warehouse.id!);
      }
      await initialise();
      setBusy(false);
    }
  }

  Future<void> showPalletInSheet(Lot lot) async {
    await _sheetService.showCustomSheet(variant: BottomSheetType.pallet_in, title: lot.name, data: {"lotId": lot.id, "warehouseId": warehouse.id});
    await initialise();
  }

  Future<void> showPalletDefectiveSheet(Lot lot, int numPallets) async {
    SheetResponse? response = await _sheetService.showCustomSheet(variant: BottomSheetType.defective, title: lot.name, data: {"num_pallets": numPallets});
    int? defectiveNumPallets = response?.data['count'];

    if (defectiveNumPallets != null && defectiveNumPallets > 0) {
      setBusy(true);
      await DatabaseHelper.instance.markPalletsAsDefectuous(lot.id!, defectiveNumPallets, warehouse.id!);
      await initialise();
      setBusy(false);
    }
  }

  int getPalletsNotOut(int lotIndex) {
    if (lotIndex >= lots.length) return 0;
    return lots[lotIndex].pallet?.where((p) => !p.isOut! && !p.defective!).length ?? 0;
  }

  int getPalletsNotOutDefective(int lotIndex) {
    if (lotIndex >= lots.length) return 0;
    return lots[lotIndex].pallet?.where((p) => !p.isOut! && p.defective!).length ?? 0;
  }

  String getTruckLoads(int lotIndex) {
    if (lotIndex >= lots.length) return '0, 0';
    int palletsCount = getPalletsNotOut(lotIndex);
    int fullTruckLoads = palletsCount ~/ 26;
    int remainingPallets = palletsCount % 26;
    return '$fullTruckLoads, $remainingPallets';
  }
}