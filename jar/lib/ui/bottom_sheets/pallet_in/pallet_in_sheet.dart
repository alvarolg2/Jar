import 'package:flutter/material.dart';
import 'package:jar/ui/bottom_sheets/pallet_in/pallet_in_sheet_model.dart';
import 'package:jar/ui/common/app_colors.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class PalletsInSheet extends StatelessWidget {
  final Function(SheetResponse)? completer;
  final SheetRequest request;

  const PalletsInSheet({
    Key? key,
    required this.completer,
    required this.request,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PalletsInSheetModel>.reactive(
      viewModelBuilder: () => PalletsInSheetModel(),
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
              'Entrada de Palés',
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
              onPressed: () async {
                // Comprobar si el campo de texto no está vacío y si contiene solo dígitos (es un número válido).
                if (model.palletsController.text.isNotEmpty &&
                    model.palletsController.text.runes.every((r) =>
                        String.fromCharCode(r).contains(RegExp(r'[0-9]')))) {
                  int numPallets = int.parse(model.palletsController.text);
                  await model.generatePallets(
                      numPallets, request.data['lotId']);
                  completer?.call(SheetResponse(confirmed: true));
                } else {
                  // Mostrar un Snackbar o un mensaje de error si la entrada no es válida.
                  model.showInvalidInputError();
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
