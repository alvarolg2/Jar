import 'package:jar/app/app.bottomsheets.dart';
import 'package:jar/app/app.locator.dart';
import 'package:jar/ui/common/database_helper.dart';
import 'package:jar/models/lot.dart';
import 'package:jar/models/product.dart';
import 'package:jar/models/warehouse.dart';
import 'package:sqflite/sqflite.dart';
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
    allProducts = await DatabaseHelper.instance.getProductsByPalletsNotOutWithCount(warehouse.id!);
    if (productId == null) {
      _lots = await DatabaseHelper.instance
          .getAllLotsByWarehouseIdWithPallets(warehouse.id!);
    } else {
      _lots = await DatabaseHelper.instance
          .getAllLotsByWarehouseIdWithPalletsAndProductId(
              warehouse.id!, productId);
    }
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
      await DatabaseHelper.instance.markPalletsAsOut(lot.id!, extracNumPallets, warehouse.id!);
    }
    initialise();
  }

  Future<void> showPalletInSheet(Lot lot) async {
    SheetResponse? response = await _sheetService.showCustomSheet(
        variant: BottomSheetType.pallet_in,
        title: lot.name,
        data: {"lotId": lot.id, "warehouseId": warehouse.id});
    initialise();
  }

  void selectProductNull() {
    selectedProduct = null;
    initialise();
    notifyListeners();
  }

  List<Lot> get lots => _lots; // Proporciona acceso a _lots.

  int getTotalPallets(int index) {
    return _lots[index].pallet?.length ?? 0;
  }

  int getPalletsNotOut(int index) {
    return _lots[index].pallet?.where((p) => !p.isOut!).length ?? 0;
  }

  String getTruckLoads(int index) {
  // Asegúrate de que el lote tiene palés para procesar.
  if (_lots[index].pallet != null && _lots[index].pallet!.isNotEmpty) {
    // Filtra los palés donde `isOut` es falso y cuenta el total.
    int notOutPallets = _lots[index].pallet!.where((p) => !p.isOut!).length;

    // Calcula el número de viajes de camión completos (truncando el valor a un entero).
    int fullTruckLoads = notOutPallets ~/ 26;

    // Calcula el número de pallets que sobran después de llenar los viajes completos.
    int remainingPallets = notOutPallets % 26;

    // Formatea el resultado como un String que muestra ambos valores.
    return '$fullTruckLoads, $remainingPallets';
  } else {
    // Devuelve un mensaje indicando que no hay pallets para procesar.
    return '';
  }
}




  // Esta función calcula el número total de pallets no salidos en el almacén,
  // y opcionalmente para un producto específico.
  Future<int> getTotalPalletsNotOut(
      {int? productId, required int warehouseId}) async {
    final db = await DatabaseHelper.instance.database;
    // La consulta inicial ahora filtra por warehouse en la tabla pallet
    String query = '''
      SELECT COUNT(*) as count FROM pallet
      JOIN pallet_lot ON pallet.id = pallet_lot.id_pallet
      JOIN lot ON pallet_lot.id_lot = lot.id
      WHERE pallet.warehouse = ? AND pallet.is_out = 0
    ''';
    List<dynamic> params = [
      warehouseId
    ]; // Se asume que se pasa el ID del almacén como parámetro

    if (productId != null) {
      // Se añade el filtro por productId en la tabla lot
      query += ' AND lot.product = ?';
      params.add(productId);
    }

    final result = await db.rawQuery(query, params);
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
