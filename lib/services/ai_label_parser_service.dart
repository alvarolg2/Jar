import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:jar/models/parsed_label_data.dart';
import 'package:jar/app/secrets.dart';

class AiLabelParserService {
  late final GenerativeModel _model;
  bool _isInitialized = false;

  AiLabelParserService() {
    if (geminiApiKey != 'YOUR_API_KEY_HERE') {
      initialize(geminiApiKey);
    }
  }

  void initialize(String apiKey) {
    _model = GenerativeModel(
      model: 'gemini-flash-latest',
      apiKey: apiKey,
    );
    _isInitialized = true;
  }

  Future<ParsedLabelData?> parseWithAi(String rawText) async {
    if (!_isInitialized) {
      throw Exception('AiLabelParserService not initialized with API Key');
    }

    final prompt = '''
    Act as an expert OCR data extractor for warehouse logistics. 
    Analyze the raw OCR text below and extract the following product details into a strict JSON format.

    **Guidelines:**
    1.  **Product**: Look for codes like "REF:", "ART:", "ITEM:", or alphanumerics (e.g., "123-ABC", "A555").
        - **Constraint**: Must NOT contain spaces. Remove any spaces found in the candidate text.
    2.  **Description**: Look for the product name or description. It is usually the longest text block, often near the product code. It might NOT have a label like "Desc:". Examples: "MANZANA ROJA", "CAJA PLASTICO 20KG", "tubería pvc". 
        - **Critical**: Do NOT use the product code as the description.
        - **Critical**: Do NOT use the lot number as the description.
    3.  **Lot**: Look for "Lote", "Lot", "Batch", "L:", "B:" followed by numbers/letters.
        - **Constraint**: Must NOT contain spaces. Remove any spaces found in the candidate text.
    4.  **Pallets**: Look for numbers near "PAL", "PLT", "PALE". Default to null if unsure.

    **OCR TEXT:**
    """
    $rawText
    """

    **Output Format (JSON Only):**
    {
      "product": "extracted_code_or_name",
      "description": "extracted_description_text",
      "lot": "extracted_lot",
      "pallets": "extracted_pallet_count"
    }
    
    If a field is definitely not found, use null.
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      final cleanJson = _cleanJson(response.text);
      if (cleanJson == null) return null;

      final Map<String, dynamic> data = jsonDecode(cleanJson);

      return ParsedLabelData(
        product: data['product']?.toString(),
        description: data['description']?.toString(),
        lot: data['lot']?.toString(),
        pallets: data['pallets']?.toString(),
      );
    } catch (e) {
      print('AI Parsing Error: $e');
      return null;
    }
  }

  String? _cleanJson(String? text) {
    if (text == null) return null;
    // Remove markdown code blocks if present
    final pattern =
        RegExp(r'```json\s*(.*?)\s*```', multiLine: true, dotAll: true);
    final match = pattern.firstMatch(text);
    if (match != null) {
      return match.group(1);
    }
    return text.trim();
  }
}
