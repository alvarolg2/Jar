import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class PalletsSheetModel extends BaseViewModel {
  final _snackbarService = SnackbarService();

  final TextEditingController palletsController = TextEditingController();
  bool _validationPassed = false;
  bool get validationPassed => _validationPassed;
  int? currentCount;

  void addPallets(int count) {
    int currentCount = int.tryParse(palletsController.text) ?? 0;
    palletsController.text = (currentCount + count).toString();
    notifyListeners();
  }

  void setToSpecificNumber(int number) {
    palletsController.text = number.toString();
    notifyListeners();
  }

  void addTwentySixPallets() {
    palletsController.text = "26";
    notifyListeners();
  }

  void confirmPallets(int numPalletsAvailable) {
    currentCount = int.tryParse(palletsController.text) ?? 0;

    if (currentCount! <= numPalletsAvailable) {
      _validationPassed = true;
      print("Confirmados $currentCount palés.");
    } else {
      _validationPassed = false;
      _snackbarService.showSnackbar(
        title: 'Error',
        message:
            'El número introducido es mayor que el número de palés disponibles.',
        duration: Duration(seconds: 3),
      );
    }
    notifyListeners(); // Asegúrate de notificar a los listeners sobre el cambio de estado.
  }

  @override
  void dispose() {
    palletsController.dispose();
    super.dispose();
  }
}
