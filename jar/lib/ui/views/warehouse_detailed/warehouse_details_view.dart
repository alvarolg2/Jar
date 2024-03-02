import 'package:flutter/material.dart';
import 'package:jar/models/product.dart';
import 'package:jar/models/warehouse.dart';
import 'package:jar/ui/common/ui_helpers.dart';
import 'package:jar/ui/views/warehouse_detailed/warehouse_details_viewmodel.dart';
import 'package:stacked/stacked.dart';

class WarehouseDetailsView extends StatelessWidget {
  final Warehouse warehouse;

  const WarehouseDetailsView({Key? key, required this.warehouse})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle style = TextStyle(fontSize: 20);
    return ViewModelBuilder<WarehouseDetailsViewModel>.reactive(
      viewModelBuilder: () => WarehouseDetailsViewModel(warehouse),
      onModelReady: (model) =>
          model.fetchLots(), // Carga inicial de todos los lotes.
      builder: (context, model, child) => Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<Product>(
                value: model.selectedProduct,
                hint: Text("Selecciona un producto"),
                onChanged: (Product? newValue) {
                  if (newValue != null) {
                    model.setSelectedProduct(newValue);
                  }
                },
                items: model.allProducts
                    .map<DropdownMenuItem<Product>>((Product product) {
                  return DropdownMenuItem<Product>(
                    value: product,
                    child: Text(product.name!),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: model.isBusy
                  ? Center(child: const CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: model.lots.length,
                      itemBuilder: (context, index) {
                        final lot = model.lots[index];
                        return Container(
                          margin: const EdgeInsets.all(8.0),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      model.selectedProduct == null
                                          ? Row(
                                              children: [
                                                const Icon(
                                                    Icons.inventory_2_outlined),
                                                SizedBox(width: 8),
                                                Text(
                                                  lot.product?.name ??
                                                      "Without name",
                                                  style: style,
                                                ),
                                              ],
                                            )
                                          : const SizedBox.shrink(),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.ballot),
                                          SizedBox(width: 8),
                                          Text(
                                            lot.name ?? "Without product",
                                            style: style,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.pallet),
                                          SizedBox(width: 8),
                                          Text(
                                              "${model.getPalletsNotOut(index)} / ${model.getTotalPallets(index)} palés",
                                              style: style),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.date_range),
                                          SizedBox(width: 8),
                                          Text(
                                            // Asumiendo que tienes un DateFormatter o similar para formatear la fecha
                                            DateFormatter.format(
                                                lot.createDate!),
                                            style: style,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.arrow_outward_outlined,
                                            size: 40),
                                        onPressed: () async {
                                          await model.showPalletSheet(lot,
                                              model.getPalletsNotOut(index));
                                        },
                                      )
                                    ],
                                  )
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
