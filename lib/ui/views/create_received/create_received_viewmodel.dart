import 'dart:math';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:jar/app/app.locator.dart';
import 'package:jar/app/app.router.dart';
import 'package:jar/models/lot.dart';
import 'package:jar/models/product.dart';
import 'package:jar/models/pallet.dart';
import 'package:jar/models/warehouse.dart';
import 'package:jar/ui/common/database_helper.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

enum SearchDirection { after, before }

class CreateReceivedViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();

  final _productController = TextEditingController();
  final _lotController = TextEditingController();
  final _numPalletController = TextEditingController();

  TextEditingController get productController => _productController;
  TextEditingController get lotController => _lotController;
  TextEditingController get numPalletController => _numPalletController;

  late Warehouse _warehouse;

  void init(Warehouse warehouse) {
    _warehouse = warehouse;
  }

  Future<void> captureAndRecognizeText() async {
    setBusy(true);
    try {
      final List<String> pictures = await CunningDocumentScanner.getPictures() ?? [];
      if (pictures.isEmpty) {
        setBusy(false);
        return;
      }
      
      final imagePath = pictures.first;
      final inputImage = InputImage.fromFilePath(imagePath);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      textRecognizer.close();

      _parseRecognizedText(recognizedText);

    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error de Escaneo',
        description: 'No se pudo procesar el documento. Error: ${e.toString()}',
      );
    } finally {
      setBusy(false);
    }
  }

  void _parseRecognizedText(RecognizedText recognizedText) {
    String? foundProduct;
    String? foundLot;
    String? foundPallets;

    final productPattern = RegExp(r'Materia[l]?\s*Code[:\s]*([\w\d]+)', caseSensitive: false);
    
    final lotPattern = RegExp(r'B?atch[:\s]*(\d+)', caseSensitive: false);
    
    final palletPattern = RegExp(r'(\d+)\s*\/?\s*pal', caseSensitive: false);

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        final lineText = line.text;

        if (foundProduct == null) {
          final match = productPattern.firstMatch(lineText);
          if (match != null && match.group(1) != null) {
            foundProduct = match.group(1)!.toUpperCase();
          }
        }
        
        if (foundLot == null) {
          final match = lotPattern.firstMatch(lineText);
          if (match != null && match.group(1) != null) {
            foundLot = match.group(1);
          }
        }

        if (foundPallets == null) {
          final match = palletPattern.firstMatch(lineText.toLowerCase());
          if (match != null && match.group(1) != null) {
            foundPallets = match.group(1);
          }
        }
      }
    }

    if (foundProduct != null) _productController.text = foundProduct;
    if (foundLot != null) _lotController.text = foundLot;
    if (foundPallets != null) _numPalletController.text = foundPallets;
  }
  
  
  Future<bool> createLot() async {
    setBusy(true);
    try {
      Product product = await _findOrCreateProduct(productController.text);
      Lot lot = await _findOrCreateLot(lotController.text, product);
      int numPallets = int.tryParse(numPalletController.text) ?? 0;
      if (numPallets <= 0) throw Exception("El número de palets debe ser mayor que cero.");
      await _generatePallets(numPallets, lot.id!, _warehouse);
      return true;
    } catch (e) {
      await _dialogService.showDialog(title: 'Error al Guardar', description: 'Ocurrió un problema al guardar los datos. Error: ${e.toString()}');
      return false;
    } finally {
      setBusy(false);
    }
  }

  Future<Product> _findOrCreateProduct(String name) async {
    if (name.trim().isEmpty) throw Exception("El nombre del producto no puede estar vacío.");
    Product? existingProduct = await DatabaseHelper.instance.findProductByName(name);
    if (existingProduct != null) return existingProduct;
    int newProductId = await DatabaseHelper.instance.insertProduct(Product(name: name));
    return Product(id: newProductId, name: name);
  }

  Future<Lot> _findOrCreateLot(String name, Product product) async {
    if (name.trim().isEmpty) throw Exception("El nombre del lote no puede estar vacío.");
    Lot? existingLot = await DatabaseHelper.instance.findLotByName(name);
    if (existingLot != null) return existingLot;
    int newLotId = await DatabaseHelper.instance.insertLot(Lot(name: name, product: product));
    return Lot(id: newLotId, name: name, product: product);
  }

  Future<void> _generatePallets(int numberOfPallets, int lotId, Warehouse warehouse) async {
    Random random = Random();
    for (int i = 0; i < numberOfPallets; i++) {
      String palletReference = 'Pallet-${random.nextInt(999999).toString().padLeft(6, '0')}';
      Pallet pallet = Pallet(name: palletReference, date: null, warehouse: warehouse);
      await DatabaseHelper.instance.createPalletAndLinkToLot(pallet, lotId);
    }
  }

  void navigateToHome() {
    _navigationService.clearStackAndShow(Routes.homeView);
  }

  @override
  void dispose() {
    _productController.dispose();
    _lotController.dispose();
    _numPalletController.dispose();
    super.dispose();
  }
}