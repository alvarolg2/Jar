import 'dart:ui';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class LabelParserService {
  /// Analiza el texto reconocido y extrae los datos relevantes.
  /// Retorna un mapa con las claves: 'product', 'description', 'lot', 'pallets'.
  ParsedLabelData parseRecognizedText(RecognizedText recognizedText) {
    String? foundProduct;
    String? foundDescription;
    String? foundLot;
    String? foundPallets;

    Rect? productLineRect;

    // Patrones mejorados y más flexibles (multilingües)
    // Busca: Material Code, Material, Mat, Código, Code, seguido de : o espacio y alfanuméricos
    final productPattern = RegExp(
        r'(?:Material|Mat\.?|Código|Code|Ref\.?)\s*(?:Code)?[:\.\s]*([\w\d\-]+)',
        caseSensitive: false);

    // Busca: Batch, Lote, Lot, B., seguido de : o espacio y alfanuméricos
    final lotPattern = RegExp(r'(?:Batch|Lote|Lot|B\.)[:\.\s]*([\w\d]+)',
        caseSensitive: false);

    // Busca: Cantidad numérica seguida de "pal" o "pallets" o "palets"
    final palletPattern =
        RegExp(r'(\d+)\s*[\/]?\s*(?:pal|plts?|pallets?)', caseSensitive: false);

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        final lineText = line.text;
        final lowerText = lineText.toLowerCase();

        // 1. Buscar Producto
        // Prioridad: Si encontramos "Material Code: XXX", es un candidato fuerte.
        if (foundProduct == null) {
          // Intentar match con etiqueta explícita
          final match = productPattern.firstMatch(lineText);
          if (match != null && match.group(1) != null) {
            foundProduct = match.group(1)!.trim().toUpperCase();
            productLineRect = line.boundingBox;
          } else {
            // Heurística de respaldo: Si la línea es solitaria y parece un código (ej: A123-BC)
            // Esto es arriesgado, mejor confiar en etiquetas por ahora.
          }
        }

        // 2. Buscar Lote
        if (foundLot == null) {
          final match = lotPattern.firstMatch(lineText);
          if (match != null && match.group(1) != null) {
            foundLot = match.group(1)!.trim();
          }
        }

        // 3. Buscar Palets
        if (foundPallets == null) {
          final match = palletPattern.firstMatch(lowerText);
          if (match != null && match.group(1) != null) {
            foundPallets = match.group(1)!.trim();
          }
        }
      }
    }

    // 4. Buscar Descripción (Heurística Espacial)
    // Si encontramos el producto, buscamos texto que esté alineado verticalmente debajo o cerca.
    if (productLineRect != null) {
      double minVerticalDist = double.infinity;

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          // Ignorar la propia línea del producto y líneas con palabras clave de "código"
          if (line.boundingBox == productLineRect) continue;
          if (productPattern.hasMatch(line.text)) continue;

          // Verificar alineación vertical (centros cercanos en X)
          // Permitimos un margen de error horizontal
          bool isHorizontallyAligned =
              (line.boundingBox.center.dx - productLineRect.center.dx).abs() <
                  (productLineRect.width * 0.8);

          // Verificar que esté DEBAJO del producto (Y mayor)
          bool isBelow = line.boundingBox.top > productLineRect.bottom;

          // Verificar que esté CERCA (no al final del ticket)
          double verticalDist = line.boundingBox.top - productLineRect.bottom;
          bool isCloseEnough = verticalDist <
              (productLineRect.height * 4); // Max 4 líneas de distancia

          if (isHorizontallyAligned && isBelow && isCloseEnough) {
            // Nos quedamos con la línea más cercana que cumpla los requisitos
            if (verticalDist < minVerticalDist) {
              minVerticalDist = verticalDist;
              foundDescription = line.text.trim();
            }
          }
        }
      }
    }

    // Normalización final
    foundProduct = _cleanText(foundProduct);
    foundDescription = _cleanText(foundDescription);
    foundLot = _cleanText(foundLot);
    foundPallets = _cleanText(foundPallets);

    return ParsedLabelData(
      product: foundProduct,
      description: foundDescription,
      lot: foundLot,
      pallets: foundPallets,
    );
  }

  String? _cleanText(String? text) {
    if (text == null) return null;
    return text
        .replaceAll(RegExp(r'[^\w\d\s\-\.\/]'), '')
        .trim(); // Eliminar caracteres extraños
  }
}

class ParsedLabelData {
  final String? product;
  final String? description;
  final String? lot;
  final String? pallets;

  ParsedLabelData({this.product, this.description, this.lot, this.pallets});
}
