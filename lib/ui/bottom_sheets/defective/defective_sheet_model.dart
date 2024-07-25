import 'package:flutter/material.dart';
import 'package:jar/ui/common/app_strings.dart';
import 'package:jar/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class DefectiveSheetModel extends BaseViewModel {
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
    } else {
      _validationPassed = false;
      _snackbarService.showSnackbar(
        title: error,
        message: snackbarDefective,
        duration: durationSnackbar,
      );
    }
    notifyListeners();
  }

  @override
  void dispose() {
    palletsController.dispose();
    super.dispose();
  }
}
