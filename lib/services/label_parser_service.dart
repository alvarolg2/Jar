import 'dart:ui';
import 'dart:math' as math; // Importante para cálculos de distancia
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class LabelParserService {
  /// Analiza el texto reconocido y extrae los datos relevantes usando geometría y proximidad.
  ParsedLabelData parseRecognizedText(RecognizedText recognizedText) {
    // 1. Diccionarios de palabras clave (Multilingüe y robusto)
    final productKeys = [
      'Material Code',
      'Material',
      'Código',
      'Code',
      'Ref',
      'Art.'
    ];
    final lotKeys = ['Batch', 'Lote', 'Lot', 'Partida', 'Serie', 'B.'];
    final descKeys = ['Description', 'Desc', 'Descripción', 'Denominación'];

    // 2. Usamos TextLine en lugar de TextElement para preservar palabras juntas
    // Esto evita cortar "Manzanas Rojas" en solo "Manzanas"
    List<TextLine> allLines = _getAllLines(recognizedText);

    String? foundProduct;
    String? foundLot;
    String? foundDescription;
    String? foundPallets;
    Rect?
        productLabelRect; // Guardamos dónde encontramos la etiqueta del producto

    // --- A. BÚSQUEDA GEOMÉTRICA INTELIGENTE ---

    // Buscar Producto
    final productResult = _findValueSmart(allLines, productKeys);
    foundProduct = productResult?.value;
    productLabelRect = productResult?.labelRect;

    // Buscar Lote
    final lotResult = _findValueSmart(allLines, lotKeys);
    foundLot = lotResult?.value;

    // Buscar Descripción
    // Estrategia: Si tenemos la posición del producto, buscamos texto debajo.
    // Si no, buscamos la etiqueta "Description" explícita.
    if (productLabelRect != null) {
      foundDescription =
          _findTextBelow(allLines, productLabelRect, maxDistanceLines: 3);
    }
    if (foundDescription == null) {
      final descResult = _findValueSmart(allLines, descKeys);
      foundDescription = descResult?.value;
    }

    // --- B. BÚSQUEDA POR REGEX GLOBAL (Caso Pallets) ---
    // Para pallets, suele ser "26 / PAL". Es mejor buscar en todo el texto líneas completas
    // que coincidan con este patrón específico.
    if (foundPallets == null) {
      foundPallets = _findPalletsGlobal(recognizedText);
    }

    // --- C. LIMPIEZA ---
    return ParsedLabelData(
      product: _cleanValue(foundProduct),
      description: _cleanDescription(
          foundDescription), // Limpieza menos agresiva para descripción
      lot: _cleanValue(foundLot),
      pallets: _cleanValue(foundPallets),
    );
  }

  // --- MÉTODOS PRIVADOS DE LÓGICA GEOMÉTRICA ---

  /// Busca una etiqueta y devuelve el valor más cercano (en la misma línea, a la derecha o abajo)
  _ResultWithRect? _findValueSmart(List<TextLine> lines, List<String> keys) {
    for (var line in lines) {
      String text = line.text.trim();

      // ¿Esta línea contiene una de nuestras etiquetas clave?
      bool isKey =
          keys.any((k) => text.toLowerCase().contains(k.toLowerCase()));

      if (isKey) {
        // Opción 1: El valor está pegado en la misma línea (ej: "Lote: 12345")
        // Intentamos quitar la clave y ver si queda algo útil.
        String cleanText = text;
        for (var k in keys) {
          cleanText = cleanText.replaceAll(RegExp(k, caseSensitive: false), '');
        }
        cleanText = cleanText.replaceAll(RegExp(r'[:\.\-]'), '').trim();

        if (cleanText.length > 2) {
          // Si queda texto largo, asumimos que es el valor
          return _ResultWithRect(cleanText, line.boundingBox);
        }

        // Opción 2: Buscar vecino a la DERECHA (poco común con TextLine, pero posible si son columnas muy separadas)
        TextLine? rightNeighbor =
            _findNearestNeighbor(line, lines, SearchDirection.right);
        if (rightNeighbor != null) {
          return _ResultWithRect(rightNeighbor.text, line.boundingBox);
        }

        // Opción 3: Buscar vecino ABAJO
        TextLine? bottomNeighbor =
            _findNearestNeighbor(line, lines, SearchDirection.below);
        if (bottomNeighbor != null) {
          return _ResultWithRect(bottomNeighbor.text, line.boundingBox);
        }
      }
    }
    return null;
  }

  /// Encuentra la línea visual más cercana en una dirección
  TextLine? _findNearestNeighbor(
      TextLine target, List<TextLine> allLines, SearchDirection direction) {
    TextLine? bestMatch;
    double minDistance = double.infinity;
    Rect tRect = target.boundingBox;

    // Usamos distancias relativas al tamaño del texto, no píxeles absolutos
    // Esto hace que funcione igual en imágenes 4K o VGA
    final double relativeHeight = tRect.height;

    for (var candidate in allLines) {
      if (candidate == target) continue;
      Rect cRect = candidate.boundingBox;

      bool isCandidate = false;
      double distance = double.infinity;

      if (direction == SearchDirection.right) {
        // Alineado verticalmente (centers Y parecidos) y está a la derecha
        bool sameRow = (cRect.center.dy - tRect.center.dy).abs() <
            (relativeHeight * 1.5); // Tolerancia 1.5x altura
        bool isRight =
            cRect.left > tRect.left; // Estrictamente a la derecha del inicio

        if (sameRow && isRight) {
          isCandidate = true;
          distance = cRect.left - tRect.right; // Distancia horizontal
        }
      } else {
        // SearchDirection.below
        // Alineado horizontalmente (centers X parecidos) y está abajo
        // Aumentamos tolerancia en X porque la indentación puede variar
        bool sameCol =
            (cRect.center.dx - tRect.center.dx).abs() < (tRect.width * 2.0);
        bool isBelow = cRect.top > tRect.bottom; // Estrictamente abajo

        if (sameCol && isBelow) {
          isCandidate = true;
          distance = cRect.top - tRect.bottom; // Distancia vertical
        }
      }

      // Filtros de distancia máxima relativos
      // Max distancia: 3 saltos de línea aprox (3.0 * height)
      if (isCandidate &&
          distance >= 0 &&
          distance < (relativeHeight * 3.5) &&
          distance < minDistance) {
        minDistance = distance;
        bestMatch = candidate;
      }
    }
    return bestMatch;
  }

  /// Busca texto alineado debajo de un rectángulo dado (para descripciones sin etiqueta)
  String? _findTextBelow(List<TextLine> lines, Rect topRect,
      {int maxDistanceLines = 2}) {
    TextLine? bestMatch;
    double minDistance = double.infinity;
    final double relativeHeight = topRect.height;

    for (var candidate in lines) {
      Rect cRect = candidate.boundingBox;

      // Está debajo
      if (cRect.top <= topRect.bottom) continue;

      // Alineación izquierda similar (útil para listas) o centro
      // Tolerancia: medio ancho del caracter aprox, o porcentual
      bool alignedLeft =
          (cRect.left - topRect.left).abs() < (relativeHeight * 2);
      bool alignedCenter =
          (cRect.center.dx - topRect.center.dx).abs() < topRect.width;

      if (alignedLeft || alignedCenter) {
        double distance = cRect.top - topRect.bottom;
        // Buscamos el más cercano que no esté lejísimos
        if (distance < (relativeHeight * maxDistanceLines * 1.8) &&
            distance < minDistance) {
          minDistance = distance;
          bestMatch = candidate;
        }
      }
    }
    return bestMatch?.text;
  }

  String? _findPalletsGlobal(RecognizedText text) {
    // Busca patrones como "26 PAL", "26 / PAL", "26 pallets"
    // El (\d+) captura el número antes
    final palletPattern =
        RegExp(r'(\d+)\s*[\/\|\\]?\s*(?:PAL|PLT)', caseSensitive: false);

    for (var block in text.blocks) {
      for (var line in block.lines) {
        final match = palletPattern.firstMatch(line.text);
        if (match != null && match.group(1) != null) {
          return match.group(1);
        }
      }
    }
    return null;
  }

  // Devolvemos TextLine directamente
  List<TextLine> _getAllLines(RecognizedText text) {
    List<TextLine> lines = [];
    for (var block in text.blocks) {
      lines.addAll(block.lines);
    }
    return lines;
  }

  String? _cleanValue(String? text) {
    if (text == null) return null;
    // Permitimos espacios ahora, para códigos como "Lote A 55"
    // Siguen eliminándose caracteres raros
    return text.replaceAll(RegExp(r'[^\w\d\-\.\s]'), '').trim();
  }

  String? _cleanDescription(String? text) {
    if (text == null) return null;
    return text.trim();
  }
}

// Clases de ayuda
enum SearchDirection { right, below }

class _ResultWithRect {
  final String value;
  final Rect labelRect;
  _ResultWithRect(this.value, this.labelRect);
}

class ParsedLabelData {
  final String? product;
  final String? description;
  final String? lot;
  final String? pallets;

  ParsedLabelData({this.product, this.description, this.lot, this.pallets});
}
