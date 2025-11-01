import 'package:flutter/material.dart';
import 'package:jar/l10n/app_localizations.dart';
import 'package:jar/ui/bottom_sheets/pallet/pallet_sheet_model.dart';
import 'package:jar/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class DefectiveSheet extends StatelessWidget {
  final Function(SheetResponse)? completer;
  final SheetRequest request;

  const DefectiveSheet({
    Key? key,
    required this.completer,
    required this.request,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
              l10n.palletsDefective,
              style: theme.textTheme.titleLarge
                  ?.copyWith(color: theme.colorScheme.error),
            ),
            Text(
              "Lote: ${request.title}",
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.error),
            ),
            verticalSpace(20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    child: TextField(
                      controller: model.palletsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.numberOfPallets,
                      ),
                    ),
                  ),
                ),
                horizontalSpaceSmall,
                ElevatedButton(
                  onPressed: model.addTwentySixPallets,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary, // Azul
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  child: Text(l10n.defaultNumberPallets),
                ),
              ],
            ),
            verticalSpaceMedium,
            ElevatedButton(
              onPressed: () {
                int numPalletsAvailable = request.data['num_pallets'];
                model.confirmPallets(numPalletsAvailable);
                if (model.validationPassed) {
                  completer?.call(SheetResponse(confirmed: true, data: {"count": model.currentCount}));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error, // Botón principal de color error
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.confirmPallets),
            ),
            verticalSpaceSmall,
          ],
        ),
      ),
    );
  }
}