import 'dart:math';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:jar/app/app.locator.dart';
import 'package:jar/app/app.router.dart';
import 'package:jar/l10n/app_localizations.dart';
import 'package:jar/models/lot.dart';
import 'package:jar/models/product.dart';
import 'package:jar/models/pallet.dart';
import 'package:jar/models/warehouse.dart';
import 'package:jar/services/label_parser_service.dart';
import 'package:jar/services/product_repository.dart';
import 'package:jar/services/lot_repository.dart';
import 'package:jar/services/pallet_repository.dart';
import 'package:jar/models/parsed_label_data.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

enum SearchDirection { after, before }

class CreateReceivedViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _labelParserService = locator<LabelParserService>();
  final _productRepo = locator<ProductRepository>();
  final _lotRepo = locator<LotRepository>();
  final _palletRepo = locator<PalletRepository>();

  final _productNameController = TextEditingController();
  final _productDescriptionController = TextEditingController();
  final _lotController = TextEditingController();
  final _numPalletController = TextEditingController();

  TextEditingController get productNameController => _productNameController;
  TextEditingController get productDescriptionController =>
      _productDescriptionController;
  TextEditingController get lotController => _lotController;
  TextEditingController get numPalletController => _numPalletController;

  late Warehouse _warehouse;
  TextRecognizer? _textRecognizer;

  void init(Warehouse warehouse) {
    _warehouse = warehouse;
  }

  AppLocalizations get _l10n {
    final context = StackedService.navigatorKey?.currentContext;
    if (context == null) {
      throw StateError('Localizations accessed before navigator is ready');
    }
    final localization = AppLocalizations.of(context);
    if (localization == null) {
      throw StateError('Localizations not found in context');
    }
    return localization;
  }

  Future<void> captureAndRecognizeText() async {
    setBusy(true);
    try {
      final List<String> pictures =
          await CunningDocumentScanner.getPictures() ?? [];
      if (pictures.isEmpty) {
        setBusy(false);
        return;
      }

      final imagePath = pictures.first;
      final inputImage = InputImage.fromFilePath(imagePath);
      
      _textRecognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText =
          await _textRecognizer!.processImage(inputImage);

      await _parseRecognizedText(recognizedText);
    } catch (e) {
      await _dialogService.showDialog(
        title: _l10n.scanError,
        description: _l10n.scanErrorDescription(e.toString()),
      );
    } finally {
      setBusy(false);
    }
  }

  Future<void> _parseRecognizedText(RecognizedText recognizedText) async {
    ParsedLabelData parsedData =
        _labelParserService.parseRecognizedText(recognizedText);

    try {
      final aiData = await _labelParserService.parseWithAi(recognizedText.text);
      if (aiData != null) {
        parsedData = ParsedLabelData(
          product: aiData.product ?? parsedData.product,
          description: aiData.description ?? parsedData.description,
          lot: aiData.lot ?? parsedData.lot,
          pallets: aiData.pallets ?? parsedData.pallets,
        );
      }
    } catch (e) {
      print('AI parsing failed: $e');
    }

    if (parsedData.product != null)
      _productNameController.text = parsedData.product!;
    if (parsedData.description != null)
      _productDescriptionController.text = parsedData.description!;
    if (parsedData.lot != null) _lotController.text = parsedData.lot!;
    if (parsedData.pallets != null)
      _numPalletController.text = parsedData.pallets!;
  }

  Future<bool> createLot() async {
    setBusy(true);
    try {
      Product product = await _findOrCreateProduct(
          productNameController.text, productDescriptionController.text);
      Lot lot = await _findOrCreateLot(lotController.text, product);
      int numPallets = int.tryParse(numPalletController.text) ?? 0;
      if (numPallets <= 0) throw Exception(_l10n.palletsGreaterThanZero);
      await _generatePallets(numPallets, lot.id!, _warehouse);
      return true;
    } catch (e) {
      await _dialogService.showDialog(
          title: _l10n.saveError,
          description: _l10n.saveErrorDescription(e.toString()));
      return false;
    } finally {
      setBusy(false);
    }
  }

  Future<Product> _findOrCreateProduct(String name, String description) async {
    if (name.trim().isEmpty) throw Exception(_l10n.productNameRequired);

    Product? existingProduct =
        await _productRepo.findByName(name);

    if (existingProduct != null) {
      final bool needsUpdate = description.trim().isNotEmpty &&
          existingProduct.description != description;

      if (needsUpdate) {
        final productToUpdate = Product(
          id: existingProduct.id!,
          name: existingProduct.name,
          description: description,
        );
        await _productRepo.update(productToUpdate);
        return productToUpdate;
      } else {
        return existingProduct;
      }
    } else {
      final newProduct = Product(name: name, description: description);
      int newProductId =
          await _productRepo.insert(newProduct);
      return Product(id: newProductId, name: name, description: description);
    }
  }

  Future<Lot> _findOrCreateLot(String name, Product product) async {
    if (name.trim().isEmpty) throw Exception(_l10n.lotNameRequired);
    Lot? existingLot = await _lotRepo.findByName(name);
    if (existingLot != null) return existingLot;
    int newLotId = await _lotRepo
        .insert(Lot(name: name, product: product));
    return Lot(id: newLotId, name: name, product: product);
  }

  Future<void> _generatePallets(
      int numberOfPallets, int lotId, Warehouse warehouse) async {
    Random random = Random();
    for (int i = 0; i < numberOfPallets; i++) {
      String palletReference =
          'Pallet-${random.nextInt(999999).toString().padLeft(6, '0')}';
      Pallet pallet =
          Pallet(name: palletReference, date: null, warehouse: warehouse);
      await _palletRepo.createAndLinkToLot(pallet, lotId);
    }
  }

  void navigateToHome() {
    _navigationService.clearStackAndShow(Routes.homeView);
  }

  @override
  void dispose() {
    _textRecognizer?.close();
    _productNameController.dispose();
    _productDescriptionController.dispose();
    _lotController.dispose();
    _numPalletController.dispose();
    super.dispose();
  }
}
