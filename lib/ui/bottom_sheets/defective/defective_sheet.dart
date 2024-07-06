import 'package:flutter/material.dart';
import 'package:jar/ui/bottom_sheets/pallet/pallet_sheet_model.dart';
import 'package:jar/ui/common/app_colors.dart';
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
    return ViewModelBuilder<PalletsSheetModel>.reactive(
      viewModelBuilder: () => PalletsSheetModel(),
      builder: (context, model, child) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kcBackgroundColor, kcPrimaryColor],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20), // Espacio antes del título
            Text(
              'Palés defectuosos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(1.0, 1.0),
                    blurRadius: 3.0,
                    color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                  ),
                ],
              ),
            ),
            Text(
              "Lote: ${request.title}",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(1.0, 1.0),
                    blurRadius: 3.0,
                    color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20), // Espacio después del título
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: model.palletsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Número de palés',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10), // Espacio entre el TextField y el botón
                ElevatedButton(
                  onPressed: model.addTwentySixPallets,
                  child: Text('26'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                int numPalletsAvailable = request.data[
                    'num_pallets']; // Asegúrate de obtener este valor correctamente
                model.confirmPallets(numPalletsAvailable);
                if (model.validationPassed) {
                  // Asumiendo que tienes una manera de validar esto en tu ViewModel
                  completer?.call(SheetResponse(
                      confirmed: true, data: {"count": model.currentCount}));
                }
              },
              child: Text('Confirmar Palés'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
