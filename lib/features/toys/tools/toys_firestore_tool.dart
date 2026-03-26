import 'package:adaptive_commerce/core/config/logging_config.dart';
import 'package:adaptive_commerce/core/firebase/firebase_paths.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart' as dsb;

/// Loads toy rows from Firestore collection [FirestorePaths.toysCollection].
DynamicAiTool<JsonMap> createToysFetchTool(FirebaseFirestore firestore) {
  return DynamicAiTool<JsonMap>(
    name: 'fetch_toys_from_firestore',
    description:
        'REQUIRED before showing shop-able toys in the UI. Reads the live '
        '`toys` Firestore collection and returns toys[] (id, name, price, seller, url). '
        'Optional search_query filters by substring on name/seller/url. If no row matches '
        'the filter but documents exist, the full catalog is returned and filter_fallback '
        'is true (product titles rarely contain words like "teething").',
    parameters: dsb.S.object(
      properties: {
        'search_query': dsb.S.string(
          description:
              'Filter hint, e.g. "teething", "chew", "ball". Use empty string to fetch all.',
        ),
      },
    ),
    invokeFunction: (args) async {
      final q = args['search_query']?.toString().trim() ?? '';
      try {
        appLog.info('fetch_toys_from_firestore: query="$q"');
        final snap =
            await firestore.collection(FirestorePaths.toysCollection).get();
        final all = <Map<String, Object?>>[];
        for (final d in snap.docs) {
          final m = d.data();
          final name = m['name']?.toString() ?? '';
          final price = m['price']?.toString() ?? '';
          final seller = m['seller']?.toString() ?? '';
          final url = m['url']?.toString() ?? '';
          all.add({
            'id': d.id,
            'name': name,
            'price': price,
            'seller': seller,
            'url': url,
          });
        }
        if (q.isEmpty) {
          return {'toys': all};
        }
        final lower = q.toLowerCase();
        final filtered = all.where((t) {
          final hay =
              '${t['name'] ?? ''} ${t['seller'] ?? ''} ${t['url'] ?? ''}'
                  .toLowerCase();
          return hay.contains(lower);
        }).toList();
        if (filtered.isEmpty && all.isNotEmpty) {
          return {
            'toys': all,
            'filter_fallback': true,
            'filter_fallback_reason':
                'No product rows matched the search text; returned full catalog so the shopper still sees listings.',
          };
        }
        return {'toys': filtered};
      } catch (e, st) {
        appLog.warning('fetch_toys_from_firestore failed: $e\n$st');
        return {
          'toys': <Object>[],
          'error': e.toString(),
        };
      }
    },
  );
}
