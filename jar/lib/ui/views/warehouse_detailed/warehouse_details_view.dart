import 'package:flutter/material.dart';
import 'package:jar/models/product.dart';
import 'package:jar/models/warehouse.dart';
import 'package:jar/ui/common/app_colors.dart';
import 'package:jar/ui/common/ui_helpers.dart';
import 'package:jar/ui/views/warehouse_detailed/warehouse_details_viewmodel.dart';
import 'package:stacked/stacked.dart';

class WarehouseDetailsView extends StatelessWidget {
  final Warehouse warehouse;

  const WarehouseDetailsView({Key? key, required this.warehouse})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle =
        const TextStyle(color: kcTextColor); // Estilo de texto general

    return ViewModelBuilder<WarehouseDetailsViewModel>.reactive(
      viewModelBuilder: () => WarehouseDetailsViewModel(warehouse),
      onModelReady: (model) => model.fetchLots(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: kcBackgroundColor, // Fondo general claro
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<Product>(
                    value: model.selectedProduct,
                    hint: Text("Selecciona un producto", style: textStyle),
                    onChanged: (Product? newValue) {
                      if (newValue != null) {
                        model.setSelectedProduct(newValue);
                      }
                    },
                    items: model.allProducts
                        .map<DropdownMenuItem<Product>>((Product product) {
                      return DropdownMenuItem<Product>(
                        value: product,
                        child: Text(product.name!, style: textStyle),
                      );
                    }).toList(),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      model.selectProductNull();
                    },
                    color: kcPrimaryColorDark,
                    icon: Icon(Icons.restart_alt_outlined))
              ],
            ),
            FutureBuilder<int>(
              future: model.getTotalPalletsNotOut(
                  productId: model.selectedProduct?.id,
                  warehouseId: model.warehouse.id!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Mostrar un indicador de carga mientras se espera el resultado.
                }
                return Text(
                  "Total de palés: ${snapshot.data}",
                  style: TextStyle(fontSize: 20, color: Colors.black),
                );
              },
            ),
            Expanded(
              child: model.isBusy
                  ? Center(
                      child:
                          CircularProgressIndicator(color: kcPrimaryColorDark))
                  : ListView.builder(
                      itemCount: model.lots.length,
                      itemBuilder: (context, index) {
                        final lot = model.lots[index];
                        return Container(
                          margin: const EdgeInsets.all(8.0),
                          child: Card(
                            color: kcMediumGrey, // Gris claro para tarjetas
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Iconos reintegrados con su respectivo texto
                                        if (model.selectedProduct == null)
                                          Row(
                                            children: [
                                              Icon(Icons.inventory_2_outlined,
                                                  color: kcPrimaryColorDark),
                                              SizedBox(width: 8),
                                              Text(
                                                  lot.product?.name ??
                                                      "Sin nombre",
                                                  style: textStyle),
                                            ],
                                          ),
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.ballot,
                                                color: kcPrimaryColorDark),
                                            SizedBox(width: 8),
                                            Text(lot.name ?? "Sin producto",
                                                style: textStyle),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.pallet,
                                                color: kcPrimaryColorDark),
                                            SizedBox(width: 8),
                                            Text(
                                                "${model.getPalletsNotOut(index)} / ${model.getTotalPallets(index)} palés",
                                                style: textStyle),
                                            SizedBox(width: 8),
                                            Icon(Icons.local_shipping,
                                                color:
                                                    kcPrimaryColorDark), // Icono de camión
                                            SizedBox(width: 8),
                                            Text(
                                                "${model.getTruckLoads(index)}",
                                                style:
                                                    textStyle), // Cantidad de viajes de camión
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.date_range,
                                                color: kcPrimaryColorDark),
                                            SizedBox(width: 8),
                                            Text(
                                                DateFormatter.format(
                                                    lot.createDate!),
                                                style: textStyle),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.add_outlined,
                                            color: kcPrimaryColorDark),
                                        onPressed: () async {
                                          await model.showPalletInSheet(
                                            lot,
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.arrow_forward,
                                            color: kcPrimaryColorDark),
                                        onPressed: () async {
                                          await model.showPalletSheet(lot,
                                              model.getPalletsNotOut(index));
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
