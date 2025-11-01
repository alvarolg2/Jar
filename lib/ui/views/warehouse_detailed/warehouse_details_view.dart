import 'package:flutter/material.dart';
import 'package:jar/models/warehouse.dart';
import 'package:jar/ui/common/app_colors.dart';
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
          body: Column(
            children: [
              if (!model.isDefective && model.showDropdown)
                _buildFilterBar(context, model),
                
              Expanded(
                child: model.isBusy
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      )
                    : model.lots.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40.0),
                              child: Text(
                                model.selectedProduct != null
                                    ? "No hay palets para el producto \"${model.selectedProduct!.name}\""
                                    : "No hay palets que mostrar.",
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: kcTextSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 8, bottom: 100),
                            itemCount: model.lots.length,
                            itemBuilder: (context, index) {
                              final lot = model.lots[index];
                              final palletsCount = model.isDefective
                                  ? model.getPalletsNotOutDefective(index)
                                  : model.getPalletsNotOut(index);
                              final truckLoads = model.isDefective
                                  ? 0
                                  : model.getTruckLoads(index);
                              return LotCard(
                                lot: lot,
                                palletsCount: palletsCount,
                                truckLoads: truckLoads.toString(),
                                isDefective: model.isDefective,
                                onAddPallets: () => model.showPalletInSheet(lot),
                                onSubtractPallets: () =>
                                    model.showPalletSheet(lot, palletsCount),
                                onMarkDefective: () => model
                                    .showPalletDefectiveSheet(lot, palletsCount),
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

  Widget _buildFilterBar(BuildContext context, WarehouseDetailsViewModel model) {
    final theme = Theme.of(context);

    return Container(
      height: 60,
      alignment: Alignment.centerLeft,
      color: theme.scaffoldBackgroundColor, 
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Padding
        scrollDirection: Axis.horizontal,
        itemCount: model.allProducts.length + 1,
        itemBuilder: (context, index) {
          
          if (index == 0) {
            final bool isSelected = model.selectedProduct == null;
            return _buildFilterChip(
              context: context,
              label: "Todos",
              isSelected: isSelected,
              onTap: () => model.selectProduct(null),
            );
          }

          final product = model.allProducts[index - 1];
          final bool isSelected = model.selectedProduct == product;
          return _buildFilterChip(
            context: context,
            label: product.name ?? 'Sin Nombre',
            count: product.numPallets,
            isSelected: isSelected,
            onTap: () => model.selectProduct(product),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    int? count,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected 
                ? theme.colorScheme.secondary
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: isSelected 
                ? null 
                : Border.all(color: Colors.grey.shade300, width: 1.5),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: theme.colorScheme.secondary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              else
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected 
                      ? Colors.white 
                      : theme.colorScheme.primary.withOpacity(0.8),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
              
              if (count != null) ...[
                horizontalSpaceSmall,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Colors.white.withOpacity(0.2) 
                        : kcBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count.toString(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected ? Colors.white : kcTextSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}