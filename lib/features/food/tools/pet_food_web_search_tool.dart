import 'dart:convert';

import 'package:adaptive_commerce/core/config/logging_config.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:genui/genui.dart' hide TextPart;
import 'package:json_schema_builder/json_schema_builder.dart' as dsb;

DynamicAiTool<JsonMap> createPetFoodWebSearchTool(FirebaseAI firebaseAI) {
  return DynamicAiTool<JsonMap>(
    name: 'search_web_for_pet_food',
    description:
        'Search the live web for pet food products to buy. Call when the user wants '
        'recommendations, where to buy, or verified store links.',
    parameters: dsb.S.object(
      properties: {
        'search_query': dsb.S.string(
          description:
              'A natural language search query. E.g., "buy small breed puppy food online in India"',
        ),
      },
      required: ['search_query'],
    ),
    invokeFunction: (args) async {
      final query = args['search_query']?.toString().trim();
      if (query == null || query.isEmpty) {
        return {'error': 'search_query is required', 'results': <Object>[]};
      }

      appLog.info('search_web_for_pet_food: $query');

      final researchModel = firebaseAI.generativeModel(
        model: 'gemini-2.5-flash',
        tools: [Tool.googleSearch()],
        generationConfig: GenerationConfig(
          maxOutputTokens: 2048,
          temperature: 0.1,
          thinkingConfig: ThinkingConfig.withThinkingBudget(0),
        ),
      );

      final prompt = '''
Use Google Search to find buyable pet food products for: "$query"

You must fulfill BOTH steps below exactly:

STEP 1: Write a 1-sentence summary of what you found. You MUST include inline grounding citations here (e.g., [1]).
STEP 2: Provide a JSON block containing up to 5 products.
- Extract the price in INR (Rs). Look closely at the snippets for "Rs". If not found, write "Check site".
- Extract the rating. If not found, write "Check site for ratings".
- Provide a short 1-sentence description.
- For the URL, DO NOT GUESS product paths or ASINs! Just output the retailer's base domain (e.g., "amazon.in" or "supertails.com").

CRITICAL: Do NOT include citation markers inside the JSON block.

Output EXACTLY this format:
```json
{
  "results": [
    {
      "product_name": "Full name of product",
      "url": "amazon.in",
      "price": "Rs 1,200",
      "rating": "4.5/5",
      "description": "A short description.",
      "retailer": "Amazon India"
    }
  ]
}
```
''';

      try {
        final response = await researchModel.generateContent([
          Content.text(prompt),
        ]);

        final textContent =
            response.text ?? response.candidates.firstOrNull?.text ?? '';

        final start = textContent.indexOf('{');
        final end = textContent.lastIndexOf('}');

        if (start >= 0 && end > start) {
          final jsonString = textContent.substring(start, end + 1);
          try {
            final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
            final results = List<Map<String, dynamic>>.from(
              (decoded['results'] as List).map(
                (e) => Map<String, dynamic>.from(e as Map),
              ),
            );

            // Build safe search URLs in Dart.
            for (var i = 0; i < results.length; i++) {
              final productName =
                  results[i]['product_name']?.toString() ?? 'dog food';
              final retailerDomain =
                  results[i]['url']?.toString().toLowerCase() ?? 'amazon.in';

              final safeQuery = Uri.encodeComponent(productName);

              if (retailerDomain.contains('supertails')) {
                results[i]['url'] = 'https://supertails.com/search?q=$safeQuery';
              } else if (retailerDomain.contains('thepetproject')) {
                results[i]['url'] = 'https://thepetproject.in/search?q=$safeQuery';
              } else {
                results[i]['url'] = 'https://www.amazon.in/s?k=$safeQuery';
              }
            }

            return {'results': results};
          } catch (_) {
            appLog.warning('JSON Decode Failed:\n$jsonString');
            return {
              'error': 'Invalid JSON formatting from model',
              'results': <Object>[],
            };
          }
        }

        return {
          'error': 'Failed to find JSON block in response',
          'results': <Object>[],
        };
      } catch (e, st) {
        appLog.warning('search_web_for_pet_food failed', e, st);
        return {'error': 'Search failed: $e', 'results': <Object>[]};
      }
    },
  );
}
