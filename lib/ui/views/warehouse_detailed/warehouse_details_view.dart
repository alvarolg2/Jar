import 'package:flutter/material.dart';
import 'package:jar/models/product.dart';
import 'package:jar/models/warehouse.dart';
import 'package:jar/ui/common/app_colors.dart';
import 'package:jar/ui/common/app_strings.dart';
import 'package:jar/ui/common/ui_helpers.dart';
import 'package:jar/ui/views/warehouse_detailed/warehouse_details_viewmodel.dart';
import 'package:jar/ui/views/warehouse_detailed/widgets/lot_card.dart';
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
        return Scaffold(
          backgroundColor: kcBackgroundColor,
          body: Column(
            children: [
              if (!model.isDefective)
                _buildStyledDropdown(context, model),
              Expanded(
                child: model.isBusy
                    ? const Center(child: CircularProgressIndicator(color: kcPrimaryColorDark))
                    : model.lots.isEmpty
                        ? const Center(child: Text("No hay palets que mostrar.", style: TextStyle(color: kcTextColor)))
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 8),
                            itemCount: model.lots.length,
                            itemBuilder: (context, index) {
                              final lot = model.lots[index];
                              final palletsCount = model.isDefective ? model.getPalletsNotOutDefective(index) : model.getPalletsNotOut(index);
                              final truckLoads = model.isDefective ? 0 : model.getTruckLoads(index);
                              return LotCard(
                                lot: lot,
                                palletsCount: palletsCount,
                                truckLoads: truckLoads.toString(),
                                isDefective: model.isDefective,
                                onAddPallets: () => model.showPalletInSheet(lot),
                                onSubtractPallets: () => model.showPalletSheet(lot, palletsCount),
                                onMarkDefective: () => model.showPalletDefectiveSheet(lot, palletsCount),
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

  Widget _buildInfoRow({required IconData icon, required String text, bool isHeader = false}) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        horizontalSpaceSmall,
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: kcTextColor,
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              fontSize: isHeader ? 16 : 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStyledDropdown(BuildContext context, WarehouseDetailsViewModel model) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      margin: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: DropdownButton<Product>(
              value: model.selectedProduct,
              hint: const Text(
                dropdownProductText,
                style: TextStyle(color: kcTextColor, fontSize: 16),
              ),
              onChanged: (Product? newValue) => model.selectProduct(newValue),
              isExpanded: true,
              underline: const SizedBox.shrink(),
              icon: const Icon(Icons.filter_list_rounded, color: kcPrimaryColorDark),
              items: model.allProducts.map<DropdownMenuItem<Product>>((Product product) {
                return DropdownMenuItem<Product>(
                  value: product,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name!,
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Chip(
                        avatar: Icon(Icons.pallet, size: 16, color: Colors.grey.shade700),
                        label: Text(
                          product.numPallets.toString(),
                          style: TextStyle(color: Colors.grey.shade900, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          if (model.selectedProduct != null) ...[
            horizontalSpaceSmall,
            IconButton(
              onPressed: () => model.selectProduct(null),
              icon: Icon(Icons.clear, color: Colors.grey.shade700),
              tooltip: resetFilters,
            )
          ]
        ],
      ),
    );
  }
}