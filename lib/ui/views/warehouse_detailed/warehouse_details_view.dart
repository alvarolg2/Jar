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

  const WarehouseDetailsView({Key? key, required this.warehouse, required this.defective})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = const TextStyle(color: kcTextColor);
    return ViewModelBuilder<WarehouseDetailsViewModel>.reactive(
      viewModelBuilder: () => WarehouseDetailsViewModel(warehouse),
      onViewModelReady: (model) => model.fetchLots(defective: defective),
      builder: (context, model, child) => Scaffold(
        backgroundColor: kcBackgroundColor,
        body: Column(
          children: [
            !defective ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<Product>(
                    value: model.selectedProduct,
                    hint: Text(dropdownProductText, style: textStyle),
                    onChanged: (Product? newValue) {
                      if (newValue != null) {
                        model.setSelectedProduct(newValue);
                      }
                    },
                    items: model.allProducts
                        .map<DropdownMenuItem<Product>>((Product product) {
                      return DropdownMenuItem<Product>(
                        value: product,
                        child: Text("${product.name!} # ${product.numPallets}" , style: textStyle),
                      );
                    }).toList(),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    model.selectProductNull();
                  },
                  color: kcPrimaryColorDark,
                  icon: const Icon(Icons.restart_alt_outlined),
                  tooltip: resetFilters,
                )
              ],
            ): const SizedBox.shrink(),
            Expanded(
              child: model.isBusy
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: kcPrimaryColorDark))
                  : ListView.builder(
                      itemCount: model.lots.length,
                      itemBuilder: (context, index) {
                        final lot = model.lots[index];
                        return Container(
                          margin: const EdgeInsets.all(8.0),
                          child: Card(
                            color: kcMediumGrey,
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
                                        if (model.selectedProduct == null)
                                          Row(
                                            children: [
                                              Tooltip(
                                                message: product,
                                                child: Icon(
                                                  Icons.inventory_2_outlined,
                                                  color: defective ? kcDefectiveColor : kcPrimaryColorDark
                                                ),
                                              ),
                                              horizontalSpaceSmall,
                                              Text(
                                                  lot.product?.name ?? withOutName,
                                                  style: textStyle),
                                            ],
                                          ),
                                        verticalSpaceSmall,
                                        Row(
                                          children: [
                                            Tooltip(
                                              message: batch,
                                              child: Icon(Icons.ballot,
                                                  color: defective ? kcDefectiveColor : kcPrimaryColorDark),
                                            ),
                                            horizontalSpaceSmall,
                                            Text(lot.name ?? withOutProduct,
                                                style: textStyle),
                                          ],
                                        ),
                                        verticalSpaceSmall,
                                        Row(
                                          children: [
                                            Tooltip(
                                              message: pallets,
                                              child: Icon(Icons.pallet,
                                                  color: defective ? kcDefectiveColor : kcPrimaryColorDark),
                                            ),
                                            horizontalSpaceSmall,
                                            !defective ?
                                            Text(
                                                "${model.getPalletsNotOut(index)} $pallets",
                                                style: textStyle) 
                                              : Text(
                                                "${model.getPalletsNotOutDefective(index)} $pallets",
                                                style: textStyle)  ,
                                            !defective ? Row(
                                              children: [
                                                horizontalSpaceSmall,
                                                Tooltip(
                                                  message: tooltipTruckLoads,
                                                  child: Icon(Icons.local_shipping,
                                                      color: defective ? kcDefectiveColor : kcPrimaryColorDark),
                                                ),
                                                horizontalSpaceSmall,
                                                Text(
                                                    model.getTruckLoads(index),
                                                    style: textStyle),
                                              ],
                                            ): const SizedBox.shrink(),
                                          ],
                                        ),
                                        !defective ?
                                        Column(
                                          children: [
                                            verticalSpaceSmall,
                                            Row(
                                              children: [
                                                Tooltip(
                                                  message: tooltipDateCreationBatch,
                                                  child: Icon(Icons.date_range,
                                                      color: defective ? kcDefectiveColor: kcPrimaryColorDark),
                                                ),
                                                horizontalSpaceSmall,
                                                Text(
                                                    DateFormatter.format(
                                                        lot.createDate!),
                                                    style: textStyle),
                                              ],
                                            ),
                                          ],
                                        ) : const SizedBox.shrink(),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      !defective ?
                                      IconButton(
                                        icon: Icon(Icons.add_outlined,
                                            color: defective ? kcDefectiveColor : kcPrimaryColorDark),
                                        tooltip: tooltipAddPallets,
                                        onPressed: () async {
                                          await model.showPalletInSheet(
                                            lot,
                                          );
                                        },
                                      )
                                      : const SizedBox.shrink(),
                                      IconButton(
                                        icon: Icon(Icons.arrow_forward,
                                            color: defective ? kcDefectiveColor : kcPrimaryColorDark),
                                        tooltip: tooltipSubstractPallets,
                                        onPressed: () async {
                                          if(defective){
                                            await model.showPalletSheet(lot, model.getPalletsNotOutDefective(index));
                                          } else {
                                           await model.showPalletSheet(lot, model.getPalletsNotOut(index));
                                          }
                                        },
                                      ),
                                      !defective ?
                                      IconButton(
                                        icon: Icon(Icons.warning,
                                            color: defective ? kcDefectiveColor : kcPrimaryColorDark),
                                        tooltip: tooltipDefectivePallets,
                                        onPressed: () async {
                                          await model.showPalletDefectiveSheet(lot,
                                              model.getPalletsNotOut(index));
                                        },
                                      ) 
                                      : const SizedBox.shrink(),
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
