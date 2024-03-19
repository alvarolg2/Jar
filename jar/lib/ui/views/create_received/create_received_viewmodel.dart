import 'dart:math';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:jar/app/app.locator.dart';
import 'package:jar/app/app.router.dart';
import 'package:jar/ui/common/database_helper.dart';
import 'package:jar/models/lot.dart';
import 'package:jar/models/product.dart';
import 'package:jar/models/pallet.dart';
import 'package:jar/models/warehouse.dart';
import 'package:stacked/stacked.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked_services/stacked_services.dart';

class CreateReceivedViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _snackbarService = SnackbarService();

  final _dateController = TextEditingController();
  final _productController = TextEditingController();
  final _lotController = TextEditingController();
  final _numPalletController = TextEditingController();

  TextEditingController get dateController => _dateController;
  TextEditingController get productController => _productController;
  TextEditingController get lotController => _lotController;
  TextEditingController get numPalletController => _numPalletController;

  String? scannedDocumentPath;

  int? currentLot;

  // Método para inicializar cualquier dato si es necesario
  void init(Warehouse warehouse) {
    // Inicializa tus controladores o realiza alguna lógica inicial aquí
  }

  Future<void> scanDocument() async {
    try {
        List<String> pictures;
        // Configuración opcional para el escáner
        // Iniciar el escáner de documentos con la configuración deseada
        pictures = await CunningDocumentScanner.getPictures(crop: true) ?? [];

        if (pictures != null) {
          print("Ruta del documento escaneado: $pictures");

          scannedDocumentPath = pictures[0];
          notifyListeners();
        }
      } catch (e) {
        print("Error al escanear el documento: $e");
      }
    }

    // Función adaptada para usar image_picker
    Future<void> captureAndRecognizeText() async {
    try {
      // Abrir la cámara y capturar una foto
      await scanDocument();

      if (scannedDocumentPath == null) {
        print('No se tomó ninguna foto.');
        return;
      }

      // Reconocer texto en la foto capturada
      final inputImage = InputImage.fromFilePath(scannedDocumentPath!);
      final textDetector = GoogleMlKit.vision.textRecognizer();
      final RecognizedText recognizedText =
          await textDetector.processImage(inputImage);

      // Inicializar un String vacío para concatenar todo el texto
      String text = '';

      // Procesar el texto reconocido y concatenarlo
      for (TextBlock block in recognizedText.blocks) {
        // Expresión regular para capturar el número completo
        RegExp patternCheck = RegExp(r'(?<!\w)(\d+\s*\w+\s*\d*\w*)(?!\w)');

        // Intentar hacer coincidir el patrón con el texto del bloque
        final matches = patternCheck.allMatches(block.text);
          for (final match in matches) {
              String numero = match.group(1)!;
              if (numero != null) {
                  // Eliminar los espacios en blanco del número capturado
                  numero = numero.replaceAll(' ', '');

                  // Decide a qué controlador asignar el valor basado en el contexto
                  if (block.text.contains('Batch')) {
                      lotController.text = numero;
                  } else if (block.text.contains('Material Code')) {
                      productController.text = numero;
                  }
                  print("Dato extraído: $numero");
              }
          }

        if (block.text.contains('PAL')) {
          numPalletController.text = block.text.split('/')[0].trim();
        }
        text += block.text + '\n'; // Añade un salto de línea entre bloques de texto
      }

      // Imprimir el texto completo
      print(text); // Aquí puedes hacer algo con el texto completo

      // Cerrar el textDetector cuando termines
      textDetector.close();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<String> recognizeText(XFile imageFile) async {
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final textDetector = GoogleMlKit.vision.textRecognizer();
    final RecognizedText recognizedText =
        await textDetector.processImage(inputImage);
    String text = '';
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        text += line.text + '\n';
      }
    }
    textDetector.close();
    return text;
  }

  Future<void> createLot(Warehouse warehouse) async {
    setBusy(true);
    try {
      int currentProductID;
      print("Product Name: ${productController.text}");
      Product? currentProduct = await DatabaseHelper.instance
          .findProductByName(productController.text);
      if (currentProduct == null) {
        print("Product Name: ${productController.text}");
        currentProductID = await DatabaseHelper.instance
            .insertProduct(Product(name: productController.text));
      } else {
        currentProductID = currentProduct.id!;
      }
      Lot? repeatLot =
          await DatabaseHelper.instance.findLotByName(lotController.text);
      if (repeatLot == null) {
        currentLot = await DatabaseHelper.instance.insertLot(Lot(
            name: lotController.text,
            product: currentProduct ?? Product(id: currentProductID)));
        await generatePallets(
            int.tryParse(_numPalletController.text)!, currentLot!, warehouse);
        setBusy(false);
      } else {
        await generatePallets(
            int.tryParse(_numPalletController.text)!, repeatLot.id!, warehouse);
      }
    } catch (e) {
      setBusy(false);
      // Maneja cualquier error que ocurra
    }
  }

  Future<List<Pallet>> generatePallets(
      int numberOfPallets, int lotId, Warehouse warehouse) async {
    List<Pallet> pallets = [];
    Random random = Random();

    for (int i = 0; i < numberOfPallets; i++) {
      String palletReference =
          'Pallet-${random.nextInt(999999).toString().padLeft(6, '0')}-Date-${DateTime.now().toIso8601String()}';

      Pallet pallet =
          Pallet(name: palletReference, date: null, warehouse: warehouse);

      await DatabaseHelper.instance.createPalletAndLinkToLot(pallet, lotId);
    }

    return pallets;
  }

  void navigateToHome() {
    _navigationService.clearStackAndShow(Routes.homeView);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _productController.dispose();
    _lotController.dispose();
    super.dispose();
  }
}
