import 'package:adaptive_commerce/core/router/app_routes.dart';
import 'package:adaptive_commerce/theme/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:go_router/go_router.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

/// Toys tab catalog: strict schemas + custom widgets for GenUI.
final Catalog toysCatalog = Catalog(
  [
    CoreCatalogItems.column,
    CoreCatalogItems.row,
    CoreCatalogItems.text,
    CoreCatalogItems.card,
    CoreCatalogItems.divider,
    toySuggestionResults,
    toyTopicAdvice,
  ],
  catalogId: 'a2ui.org:standard_catalog_0_8_0',
);

const EdgeInsets _toysCardPadding = EdgeInsets.fromLTRB(20, 20, 20, 18);
const EdgeInsets _toysPanelPadding = EdgeInsets.all(16);

final Schema _stringListSchema = S.list(items: S.string());

final Schema _toyProductEntrySchema = S.object(
  properties: {
    'name': S.string(),
    'price': S.string(),
    'seller': S.string(),
    'url': S.string(),
    'productId': S.string(),
  },
  required: ['name', 'price', 'seller', 'url'],
);

final Schema _toySuggestionResultsSchema = S.object(
  properties: {
    'title': S.string(),
    'summary': S.string(),
    'products': S.list(items: _toyProductEntrySchema),
  },
  required: ['title', 'summary', 'products'],
);

/// Matches Vet welcome: title, summary, "You can ask about:", bullet examples.
final Schema _toyTopicAdviceSchema = S.object(
  properties: {
    'title': S.string(),
    'summary': S.string(),
    'bullets': _stringListSchema,
  },
  required: ['title', 'summary', 'bullets'],
);

final CatalogItem toySuggestionResults = CatalogItem(
  name: 'ToySuggestionResults',
  dataSchema: _toySuggestionResultsSchema,
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    return _ToySuggestionResultsBody(
      title: _str(data, 'title', 'Toy ideas'),
      summary: _str(data, 'summary', ''),
      products: _mapList(data['products']),
    );
  },
);

final CatalogItem toyTopicAdvice = CatalogItem(
  name: 'ToyTopicAdvice',
  dataSchema: _toyTopicAdviceSchema,
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    return ToyTopicAdviceLayout(
      title: _str(data, 'title', 'Toys'),
      summary: _str(data, 'summary', ''),
      bullets: _stringList(data['bullets']),
    );
  },
);

String _str(JsonMap map, String key, [String fallback = '']) {
  final v = map[key];
  if (v == null) return fallback;
  final s = v.toString().trim();
  return s.isEmpty ? fallback : s;
}

List<String> _stringList(Object? value) {
  if (value is! List) return [];
  return value
      .map((e) => e?.toString().trim() ?? '')
      .where((s) => s.isNotEmpty)
      .toList();
}

List<JsonMap> _mapList(Object? value) {
  if (value is! List) return [];
  return value
      .whereType<Map>()
      .map((m) => m.map((k, v) => MapEntry(k.toString(), v)))
      .toList();
}

class _ToySuggestionResultsBody extends StatelessWidget {
  const _ToySuggestionResultsBody({
    required this.title,
    required this.summary,
    required this.products,
  });

  final String title;
  final String summary;
  final List<JsonMap> products;

  void _buyNow(BuildContext context, JsonMap p) {
    final name = _str(p, 'name', '');
    final price = _str(p, 'price', '');
    final seller = _str(p, 'seller', '');
    final url = _str(p, 'url', '');
    final uri = Uri(
      path: AppRoute.checkout.path,
      queryParameters: {
        'name': name,
        'price': price,
        'seller': seller,
        'url': url,
      },
    );
    context.push(uri.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: _toysCardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppColors.headline,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              summary,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.deepBrown,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            ...products.map((p) {
              final name = _str(p, 'name', 'Item');
              final price = _str(p, 'price', '');
              final seller = _str(p, 'seller', '');
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: _toysPanelPadding,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.headline,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (price.isNotEmpty)
                        Text(
                          price,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.deepBrown,
                          ),
                        ),
                      if (seller.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          seller,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedText,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: FilledButton(
                          onPressed: () => _buyNow(context, p),
                          child: const Text('Buy now'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Shared layout for [ToyTopicAdvice] (GenUI).
/// Matches Veterinary welcome: title, intro, **You can ask about:**, bullets.
class ToyTopicAdviceLayout extends StatelessWidget {
  const ToyTopicAdviceLayout({
    super.key,
    required this.title,
    required this.summary,
    required this.bullets,
  });

  final String title;
  final String summary;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: _toysCardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppColors.headline,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              summary,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.deepBrown,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'You can ask about:',
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.headline,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...bullets.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '• $s',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.deepBrown,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
