import 'package:jar/app/app.bottomsheets.dart';
import 'package:jar/app/app.locator.dart';
import 'package:jar/models/pallet.dart';
import 'package:jar/ui/common/database_helper.dart';
import 'package:jar/models/lot.dart';
import 'package:jar/models/product.dart';
import 'package:jar/models/warehouse.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class WarehouseDetailsViewModel extends FutureViewModel<List<Lot>?> {
  final _sheetService = locator<BottomSheetService>();

  final Warehouse warehouse;
  List<Product> allProducts = [];
  Product? selectedProduct;
  List<Lot> _lots = [];

  WarehouseDetailsViewModel(this.warehouse);

  @override
  Future<List<Lot>?> futureToRun() => fetchLots();

  Future<List<Lot>> fetchLots({int? productId}) async {
    allProducts = await DatabaseHelper.instance.getAllProduct();
    if (productId == null) {
      _lots = await DatabaseHelper.instance
          .getAllLotsByWarehouseIdWithPallets(warehouse.id!);
    } else {
      _lots = await DatabaseHelper.instance
          .getAllLotsByWarehouseIdWithPalletsAndProductId(
              warehouse.id!, productId);
    }
    List<Pallet> a = await DatabaseHelper.instance.getPalletsForLot(7);
    a;
    return _lots; // Asegura que _lots siempre esté actualizado con los últimos datos, independientemente del filtro.
  }

  void setSelectedProduct(Product product) {
    selectedProduct = product;
    notifyListeners(); // Notifica a los widgets que escuchan este modelo para reconstruirse
    fetchLots(productId: selectedProduct?.id).then((lots) {
      _lots = lots; // Actualiza la lista de lotes internamente.
      notifyListeners(); // Notifica a los listeners para que la UI se actualice.
    });
  }

  Future<void> showPalletSheet(Lot lot, int numPallets) async {
    SheetResponse? response = await _sheetService.showCustomSheet(
        variant: BottomSheetType.pallet,
        title: lot.name,
        data: {"num_pallets": numPallets});
    int? extracNumPallets = response?.data['count'];
    if (extracNumPallets != null) {
      await DatabaseHelper.instance.markPalletsAsOut(lot.id!, extracNumPallets);
    }
  }

  List<Lot> get lots => _lots; // Proporciona acceso a _lots.

  int getTotalPallets(int index) {
    return _lots[index].pallet?.length ?? 0;
  }

  int getPalletsNotOut(int index) {
    return _lots[index].pallet?.where((p) => !p.isOut!).length ?? 0;
  }
}
