import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jar/models/pallet.dart';
import 'package:jar/models/warehouse.dart';
import 'package:jar/ui/common/app_strings.dart';
import 'package:jar/ui/common/database_helper.dart';
import 'package:jar/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class PalletsInSheetModel extends BaseViewModel {
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
    palletsController.text = defaultNumberPallets;
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
        message:
            snackbarDefective,
        duration: durationSnackbar,
      );
    }
    notifyListeners(); // Asegúrate de notificar a los listeners sobre el cambio de estado.
  }

  Future<List<Pallet>> generatePallets(
      int numberOfPallets, int lotId, int warehouseId) async {
    List<Pallet> pallets = [];
    Random random = Random();

    for (int i = 0; i < numberOfPallets; i++) {
      String palletReference =
          'Pallet-${random.nextInt(999999).toString().padLeft(6, '0')}-Date-${DateTime.now().toIso8601String()}';

      Pallet pallet = Pallet(
          name: palletReference,
          date: null,
          warehouse: Warehouse(id: warehouseId));

      await DatabaseHelper.instance.createPalletAndLinkToLot(pallet, lotId);
    }

    return pallets;
  }

  void showInvalidInputError() {
    _snackbarService.showSnackbar(
      title: error,
      message: snackbarDefective,
      duration: durationSnackbar,
    );
  }

  @override
  void dispose() {
    palletsController.dispose();
    super.dispose();
  }
}
