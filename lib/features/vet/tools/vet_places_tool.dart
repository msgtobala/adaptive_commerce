import 'dart:convert';

import 'package:adaptive_commerce/core/config/logging_config.dart';
import 'package:genui/genui.dart';
import 'package:http/http.dart' as http;
import 'package:json_schema_builder/json_schema_builder.dart' as dsb;

/// Searches real vet clinics using the Google Places API.
///
/// Requires a `--dart-define=GOOGLE_PLACES_API_KEY=...` at build/run time.
DynamicAiTool<JsonMap> createVetPlacesTool() {
  return DynamicAiTool<JsonMap>(
    name: 'search_nearest_vets',
    description:
        'Find real veterinary clinics in an area using Google Places API. Returns places[] with name/address/phone and a clickable Google Maps link.',
    parameters: dsb.S.object(
      properties: {
        'area_query': dsb.S.string(
          description:
              'Area/location query, e.g. "RS Puram, Coimbatore" or "in RS Puram".',
        ),
      },
      required: ['area_query'],
    ),
    invokeFunction: (args) async {
      final areaQuery = args['area_query']?.toString().trim() ?? '';
      if (areaQuery.isEmpty) {
        return {'places': <Object>[], 'error': 'area_query is required'};
      }

      const apiKey = String.fromEnvironment(
        'GOOGLE_PLACES_API_KEY',
        defaultValue: 'AIzaSyCTH97ArFkSSzVGvhPUNNFnn22zZ2sn2TM',
      );

      if (apiKey.isEmpty) {
        appLog.warning('GOOGLE_PLACES_API_KEY missing.');
        return {
          'places': <Object>[],
          'error': 'Missing GOOGLE_PLACES_API_KEY. Provide via --dart-define.',
        };
      }

      // Use text search to avoid needing lat/long geocoding.
      // The query is intentionally conservative to reduce irrelevant results.
      final query = 'veterinary clinic near $areaQuery';
      final textSearchUri = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/textsearch/json'
        '?query=${Uri.encodeComponent(query)}&key=$apiKey',
      );

      try {
        appLog.info('search_nearest_vets: $query');
        final res = await http.get(textSearchUri);
        if (res.statusCode != 200) {
          appLog.warning(
            'Places API textsearch failed: ${res.statusCode}. Body: ${res.body}',
          );
          return {
            'places': <Object>[],
            'error': 'Places textsearch failed: ${res.statusCode}',
          };
        }

        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final results = (data['results'] as List<dynamic>? ?? [])
            .take(5)
            .cast<Map<String, dynamic>>();

        // Fetch details for phone/website when possible.
        final places = <Map<String, Object?>>[];
        for (final r in results) {
          final placeId = r['place_id']?.toString();
          final placeName = r['name']?.toString() ?? '';
          final address = r['formatted_address']?.toString() ?? '';
          final rating = r['rating'];
          final ratingCount = r['user_ratings_total'];
          // Google Maps link that reliably opens the place by place_id.
          final mapUrl = placeId == null || placeId.isEmpty
              ? ''
              : 'https://www.google.com/maps/place/?q=place_id:$placeId';

          String phone = '';
          String website = '';
          if (placeId != null && placeId.isNotEmpty) {
            final detailsUri = Uri.parse(
              'https://maps.googleapis.com/maps/api/place/details/json'
              '?place_id=$placeId'
              '&fields=name,formatted_address,formatted_phone_number,website'
              '&key=$apiKey',
            );
            try {
              final detRes = await http.get(detailsUri);
              if (detRes.statusCode == 200) {
                final det = jsonDecode(detRes.body) as Map<String, dynamic>;
                final resultObj = det['result'] as Map<String, dynamic>?;
                phone = resultObj?['formatted_phone_number']?.toString() ?? '';
                website = resultObj?['website']?.toString() ?? '';
              } else {
                appLog.warning(
                  'Places API details failed: ${detRes.statusCode}. Body: ${detRes.body}',
                );
              }
            } catch (_) {
              // If details fail, still return name/address.
            }
          }

          if (placeName.isEmpty || address.isEmpty) continue;

          places.add({
            'placeName': placeName,
            'address': address,
            'phone': phone,
            'rating': rating is num ? rating.toDouble() : null,
            'ratingCount': ratingCount is num ? ratingCount.toInt() : null,
            'mapUrl': mapUrl,
            'websiteUrl': website,
          });
        }

        return {'places': places};
      } catch (e, st) {
        appLog.warning('search_nearest_vets failed', e, st);
        return {'places': <Object>[], 'error': 'Search failed: $e'};
      }
    },
  );
}
