import 'dart:ui';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:jar/app/app.locator.dart';
import 'package:jar/services/ai_label_parser_service.dart';
import 'package:jar/models/parsed_label_data.dart';

class LabelParserService {
  ParsedLabelData parseRecognizedText(RecognizedText recognizedText) {
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

    List<TextLine> allLines = _getAllLines(recognizedText);

    String? foundProduct;
    String? foundLot;
    String? foundDescription;
    String? foundPallets;
    Rect? productLabelRect;

    final productResult = _findValueSmart(allLines, productKeys);
    foundProduct = productResult?.value;
    productLabelRect = productResult?.labelRect;

    final lotResult = _findValueSmart(allLines, lotKeys);
    foundLot = lotResult?.value;

    if (productLabelRect != null) {
      foundDescription =
          _findTextBelow(allLines, productLabelRect, maxDistanceLines: 3);
    }
    if (foundDescription == null) {
      final descResult = _findValueSmart(allLines, descKeys);
      foundDescription = descResult?.value;
    }

    foundPallets = _findPalletsGlobal(recognizedText);

    return ParsedLabelData(
      product: _cleanValue(foundProduct),
      description: _cleanDescription(foundDescription),
      lot: _cleanValue(foundLot),
      pallets: _cleanValue(foundPallets),
    );
  }

  Future<ParsedLabelData?> parseWithAi(String rawText) async {
    final aiService = locator<AiLabelParserService>();
    return await aiService.parseWithAi(rawText);
  }

  _ResultWithRect? _findValueSmart(List<TextLine> lines, List<String> keys) {
    for (var line in lines) {
      String text = line.text.trim();

      bool isKey =
          keys.any((k) => text.toLowerCase().contains(k.toLowerCase()));

      if (isKey) {
        String cleanText = text;
        for (var k in keys) {
          cleanText = cleanText.replaceAll(RegExp(k, caseSensitive: false), '');
        }
        cleanText = cleanText.replaceAll(RegExp(r'[:\.\-]'), '').trim();

        if (cleanText.length > 2) {
          return _ResultWithRect(cleanText, line.boundingBox);
        }

        TextLine? rightNeighbor =
            _findNearestNeighbor(line, lines, SearchDirection.right);
        if (rightNeighbor != null) {
          return _ResultWithRect(rightNeighbor.text, line.boundingBox);
        }

        TextLine? bottomNeighbor =
            _findNearestNeighbor(line, lines, SearchDirection.below);
        if (bottomNeighbor != null) {
          return _ResultWithRect(bottomNeighbor.text, line.boundingBox);
        }
      }
    }
    return null;
  }

  TextLine? _findNearestNeighbor(
      TextLine target, List<TextLine> allLines, SearchDirection direction) {
    TextLine? bestMatch;
    double minDistance = double.infinity;
    Rect tRect = target.boundingBox;

    final double relativeHeight = tRect.height;

    for (var candidate in allLines) {
      if (candidate == target) continue;
      Rect cRect = candidate.boundingBox;

      bool isCandidate = false;
      double distance = double.infinity;

      if (direction == SearchDirection.right) {
        bool sameRow =
            (cRect.center.dy - tRect.center.dy).abs() < (relativeHeight * 1.5);
        bool isRight = cRect.left > tRect.left;

        if (sameRow && isRight) {
          isCandidate = true;
          distance = cRect.left - tRect.right;
        }
      } else {
        bool sameCol =
            (cRect.center.dx - tRect.center.dx).abs() < (tRect.width * 2.0);
        bool isBelow = cRect.top > tRect.bottom;

        if (sameCol && isBelow) {
          isCandidate = true;
          distance = cRect.top - tRect.bottom;
        }
      }
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

  String? _findTextBelow(List<TextLine> lines, Rect topRect,
      {int maxDistanceLines = 2}) {
    TextLine? bestMatch;
    double minDistance = double.infinity;
    final double relativeHeight = topRect.height;

    for (var candidate in lines) {
      Rect cRect = candidate.boundingBox;

      if (cRect.top <= topRect.bottom) continue;

      bool alignedLeft =
          (cRect.left - topRect.left).abs() < (relativeHeight * 2);
      bool alignedCenter =
          (cRect.center.dx - topRect.center.dx).abs() < topRect.width;

      if (alignedLeft || alignedCenter) {
        double distance = cRect.top - topRect.bottom;
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

  List<TextLine> _getAllLines(RecognizedText text) {
    List<TextLine> lines = [];
    for (var block in text.blocks) {
      lines.addAll(block.lines);
    }
    return lines;
  }

  String? _cleanValue(String? text) {
    if (text == null) return null;
    return text.replaceAll(RegExp(r'[^\w\d\-\.\s]'), '').trim();
  }

  String? _cleanDescription(String? text) {
    if (text == null) return null;
    return text.trim();
  }
}

enum SearchDirection { right, below }

class _ResultWithRect {
  final String value;
  final Rect labelRect;
  _ResultWithRect(this.value, this.labelRect);
}
