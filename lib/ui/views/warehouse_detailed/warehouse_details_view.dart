import 'package:flutter/material.dart';
import 'package:jar/models/product.dart';
import 'package:jar/models/warehouse.dart';
import 'package:jar/ui/common/app_colors.dart';
import 'package:jar/ui/common/app_strings.dart';
import 'package:jar/ui/common/ui_helpers.dart';
import 'package:jar/ui/views/warehouse_detailed/warehouse_details_viewmodel.dart';
import 'package:stacked/stacked.dart';

class WarehouseDetailsView extends StatelessWidget {
  final Warehouse warehouse;
  final bool defective;

  const WarehouseDetailsView({
    super.key,
    required this.warehouse,
    required this.defective,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<WarehouseDetailsViewModel>.reactive(
      key: ValueKey('${warehouse.id}_$defective'),
      viewModelBuilder: () => WarehouseDetailsViewModel(
        warehouse: warehouse,
        isDefective: defective,
      ),

      builder: (context, model, child) {
        const textStyle = TextStyle(color: kcTextColor);

        return Scaffold(
          backgroundColor: kcBackgroundColor,
          body: Column(
            children: [
              if (!model.isDefective)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DropdownButton<Product>(
                        value: model.selectedProduct,
                        hint: const Text(dropdownProductText, style: textStyle),
                        onChanged: (Product? newValue) => model.selectProduct(newValue),
                        items: model.allProducts.map<DropdownMenuItem<Product>>((Product product) {
                          return DropdownMenuItem<Product>(
                            value: product,
                            child: Text("${product.name!} # ${product.numPallets}", style: const TextStyle(color: Colors.black)),
                          );
                        }).toList(),
                      ),
                      IconButton(
                        onPressed: () => model.selectProduct(null),
                        icon: const Icon(Icons.restart_alt_outlined, color: kcPrimaryColorDark),
                        tooltip: resetFilters,
                      )
                    ],
                  ),
                ),

              Expanded(
                child: model.isBusy
                    ? const Center(child: CircularProgressIndicator(color: kcPrimaryColorDark))
                    : model.lots.isEmpty
                        ? const Center(child: Text("No hay palets que mostrar.", style: textStyle))
                        : ListView.builder(
                            itemCount: model.lots.length,
                            itemBuilder: (context, index) {
                              final lot = model.lots[index];
                              final palletsCount = model.isDefective ? model.getPalletsNotOutDefective(index) : model.getPalletsNotOut(index);

                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                child: Card(
                                  color: kcMediumGrey,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Columna de información
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              if (model.selectedProduct == null) ...[
                                                Row(
                                                  children: [
                                                    Icon(Icons.inventory_2_outlined, color: defective ? kcDefectiveColor : kcPrimaryColorDark, size: 18),
                                                    horizontalSpaceSmall,
                                                    Expanded(child: Text(lot.product?.name ?? withOutName, style: textStyle)),
                                                  ],
                                                ),
                                                verticalSpaceSmall,
                                              ],
                                              Row(
                                                children: [
                                                  Icon(Icons.ballot, color: defective ? kcDefectiveColor : kcPrimaryColorDark, size: 18),
                                                  horizontalSpaceSmall,
                                                  Text(lot.name ?? withOutProduct, style: textStyle),
                                                ],
                                              ),
                                              verticalSpaceSmall,
                                              Row(
                                                children: [
                                                  Icon(Icons.pallet, color: defective ? kcDefectiveColor : kcPrimaryColorDark, size: 18),
                                                  horizontalSpaceSmall,
                                                  Text("$palletsCount $pallets", style: textStyle),
                                                  if (!model.isDefective) ...[
                                                    horizontalSpaceSmall,
                                                    const Icon(Icons.local_shipping, color: kcPrimaryColorDark, size: 18),
                                                    horizontalSpaceTiny,
                                                    Text(model.getTruckLoads(index), style: textStyle),
                                                  ],
                                                ],
                                              ),
                                              if (!model.isDefective) ...[
                                                verticalSpaceSmall,
                                                Row(
                                                  children: [
                                                    const Icon(Icons.date_range, color: kcPrimaryColorDark, size: 18),
                                                    horizontalSpaceSmall,
                                                    Text(DateFormatter.format(lot.createDate!), style: textStyle),
                                                  ],
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        // Columna de acciones
                                        Column(
                                          children: [
                                            if (!model.isDefective)
                                              IconButton(
                                                icon: const Icon(Icons.add_outlined, color: kcPrimaryColorDark),
                                                tooltip: tooltipAddPallets,
                                                onPressed: () => model.showPalletInSheet(lot),
                                              ),
                                            IconButton(
                                              icon: Icon(Icons.arrow_forward, color: defective ? kcDefectiveColor : kcPrimaryColorDark),
                                              tooltip: tooltipSubstractPallets,
                                              onPressed: () => model.showPalletSheet(lot, palletsCount),
                                            ),
                                            if (!model.isDefective)
                                              IconButton(
                                                icon: const Icon(Icons.warning, color: kcPrimaryColorDark),
                                                tooltip: tooltipDefectivePallets,
                                                onPressed: () => model.showPalletDefectiveSheet(lot, palletsCount),
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
        );
      },
    );
  }
}