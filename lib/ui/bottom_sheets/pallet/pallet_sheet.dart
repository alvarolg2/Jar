import 'package:flutter/material.dart';
import 'package:jar/ui/bottom_sheets/pallet/pallet_sheet_model.dart';
import 'package:jar/ui/common/app_strings.dart';
import 'package:jar/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class PalletsSheet extends StatelessWidget {
  final Function(SheetResponse)? completer;
  final SheetRequest request;

  const PalletsSheet({
    Key? key,
    required this.completer,
    required this.request,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ViewModelBuilder<PalletsSheetModel>.reactive(
      viewModelBuilder: () => PalletsSheetModel(),
      builder: (context, model, child) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            verticalSpaceMedium,
            Text(
              'Salida de Palés',
              style: theme.textTheme.titleLarge
                  ?.copyWith(color: theme.colorScheme.primary),
            ),
            Text(
              "Lote: ${request.title}",
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.primary),
            ),
            verticalSpace(20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    controller: model.palletsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: numberOfPallets,
                    ),
                  ),
                ),
                horizontalSpaceSmall,
                ElevatedButton(
                  onPressed: model.addTwentySixPallets,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                  child: const Text(defaultNumberPallets),
                ),
              ],
            ),
            verticalSpace(20),
            ElevatedButton(
              onPressed: () {
                int numPalletsAvailable = request.data['num_pallets'];
                model.confirmPallets(numPalletsAvailable);
                if (model.validationPassed) {
                  completer?.call(
                      SheetResponse(confirmed: true, data: {"count": model.currentCount}));
                }
              },
              child: const Text(confirmPallets),
            ),
            verticalSpaceSmall,
          ],
        ),
      ),
    );
  }
}