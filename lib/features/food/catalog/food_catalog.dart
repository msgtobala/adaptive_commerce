import 'package:adaptive_commerce/theme/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

/// Slim core + Food-tab [CatalogItem]s (strict schemas).
///
/// Keeping only essential core primitives significantly reduces the generated
/// tool schema size while preserving strict custom schemas.
final Catalog foodCatalog = Catalog(
  [
    CoreCatalogItems.column,
    CoreCatalogItems.row,
    CoreCatalogItems.text,
    CoreCatalogItems.card,
    CoreCatalogItems.divider,
    foodProductResults,
    productComparisonTable,
    feedingQuantityGuide,
    petFoodSafetyAnswer,
    petHabitTips,
    petTopicAdvice,
  ],
  // Keep the standard catalog ID so beginRendering/surfaceUpdate payloads that
  // reference the default ID can still resolve this catalog in the processor.
  catalogId: 'a2ui.org:standard_catalog_0_8_0',
);

// --- Shared schemas ---

final Schema _foodProductEntrySchema = S.object(
  properties: {
    'name': S.string(),
    'priceDisplay': S.string(),
    'rating': S.string(),
    'description': S.string(),
    'ingredients': S.list(items: S.string()),
    'sourceUrl': S.string(),
    'retailer': S.string(),
  },
  required: ['name', 'priceDisplay', 'rating', 'description', 'sourceUrl'],
);

final Schema _comparisonRowSchema = S.object(
  properties: {
    'label': S.string(),
    'values': S.list(items: S.string()),
  },
  required: ['label', 'values'],
);

final Schema _feedingRowSchema = S.object(
  properties: {'band': S.string(), 'amount': S.string()},
  required: ['band', 'amount'],
);

final Schema _foodProductResultsSchema = S.object(
  properties: {
    'title': S.string(),
    'products': S.list(items: _foodProductEntrySchema),
  },
  required: ['title', 'products'],
);

final Schema _productComparisonTableSchema = S.object(
  properties: {
    'title': S.string(),
    'columnLabels': S.list(items: S.string()),
    'rows': S.list(items: _comparisonRowSchema),
    'footnote': S.string(),
    'sources': S.list(items: S.string()),
  },
  required: ['title', 'columnLabels', 'rows'],
);

final Schema _feedingQuantityGuideSchema = S.object(
  properties: {
    'productName': S.string(),
    'summary': S.string(),
    'rows': S.list(items: _feedingRowSchema),
    'caution': S.string(),
    'sourceUrl': S.string(),
  },
  required: ['productName', 'summary', 'rows'],
);

final Schema _petFoodSafetyAnswerSchema = S.object(
  properties: {
    'questionSummary': S.string(),
    'safeLevel': S.string(),
    'explanation': S.string(),
    'bullets': S.list(items: S.string()),
    'sources': S.list(items: S.string()),
  },
  required: ['questionSummary', 'safeLevel', 'explanation'],
);

final Schema _petHabitTipsSchema = S.object(
  properties: {
    'title': S.string(),
    'dos': S.list(items: S.string()),
    'donts': S.list(items: S.string()),
    'sources': S.list(items: S.string()),
  },
  required: ['title', 'dos', 'donts'],
);

final Schema _petTopicAdviceSchema = S.object(
  properties: {
    'title': S.string(),
    'topic': S.string(),
    'summary': S.string(),
    'bullets': S.list(items: S.string()),
    'dos': S.list(items: S.string()),
    'donts': S.list(items: S.string()),
    'sources': S.list(items: S.string()),
  },
  required: ['title', 'topic', 'summary'],
);

// --- Catalog items ---

final CatalogItem foodProductResults = CatalogItem(
  name: 'FoodProductResults',
  dataSchema: _foodProductResultsSchema,
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    final title = _str(data, 'title', 'Recommendations');
    final products = _mapList(data['products']);
    return _FoodProductResultsBody(title: title, products: products);
  },
);

final CatalogItem productComparisonTable = CatalogItem(
  name: 'ProductComparisonTable',
  dataSchema: _productComparisonTableSchema,
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    return _ProductComparisonTableBody(
      title: _str(data, 'title', 'Comparison'),
      columnLabels: _stringList(data['columnLabels']),
      rows: _mapList(data['rows']),
      footnote: _optionalStr(data['footnote']),
      sources: _stringList(data['sources']),
    );
  },
);

final CatalogItem feedingQuantityGuide = CatalogItem(
  name: 'FeedingQuantityGuide',
  dataSchema: _feedingQuantityGuideSchema,
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    return _FeedingQuantityGuideBody(
      productName: _str(data, 'productName', 'Product'),
      summary: _str(data, 'summary', ''),
      rows: _mapList(data['rows']),
      caution: _optionalStr(data['caution']),
      sourceUrl: _optionalStr(data['sourceUrl']),
    );
  },
);

final CatalogItem petFoodSafetyAnswer = CatalogItem(
  name: 'PetFoodSafetyAnswer',
  dataSchema: _petFoodSafetyAnswerSchema,
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    return _PetFoodSafetyAnswerBody(
      questionSummary: _str(data, 'questionSummary', ''),
      safeLevel: _str(data, 'safeLevel', 'unknown'),
      explanation: _str(data, 'explanation', ''),
      bullets: _stringList(data['bullets']),
      sources: _stringList(data['sources']),
    );
  },
);

final CatalogItem petHabitTips = CatalogItem(
  name: 'PetHabitTips',
  dataSchema: _petHabitTipsSchema,
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    return _PetHabitTipsBody(
      title: _str(data, 'title', 'Tips'),
      dos: _stringList(data['dos']),
      donts: _stringList(data['donts']),
      sources: _stringList(data['sources']),
    );
  },
);

final CatalogItem petTopicAdvice = CatalogItem(
  name: 'PetTopicAdvice',
  dataSchema: _petTopicAdviceSchema,
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    return _PetTopicAdviceBody(
      title: _str(data, 'title', ''),
      topic: _str(data, 'topic', 'general'),
      summary: _str(data, 'summary', ''),
      bullets: _stringList(data['bullets']),
      dos: _stringList(data['dos']),
      donts: _stringList(data['donts']),
      sources: _stringList(data['sources']),
    );
  },
);

// --- Parsing helpers ---

String _str(JsonMap map, String key, [String fallback = '']) {
  final v = map[key];
  if (v == null) return fallback;
  final s = v.toString().trim();
  return s.isEmpty ? fallback : s;
}

String? _optionalStr(Object? v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
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

// --- Widget bodies ---

class _FoodProductResultsBody extends StatelessWidget {
  const _FoodProductResultsBody({required this.title, required this.products});

  final String title;
  final List<JsonMap> products;

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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.headline,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...products.map((p) {
              final ingredients = _stringList(p['ingredients']);
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _str(p, 'name', 'Product'),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: AppColors.headline,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_str(p, 'priceDisplay', '—')} · ${_str(p, 'rating', '—')}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.deepBrown,
                          ),
                        ),
                        if (_optionalStr(p['retailer']) != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            _str(p, 'retailer', ''),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.mutedText,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          _str(p, 'description', ''),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.deepBrown,
                          ),
                        ),
                        if (ingredients.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Ingredients',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: AppColors.headline,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ingredients.join(', '),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.bodySecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        SelectableText(
                          _str(p, 'sourceUrl', ''),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
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

class _ProductComparisonTableBody extends StatelessWidget {
  const _ProductComparisonTableBody({
    required this.title,
    required this.columnLabels,
    required this.rows,
    this.footnote,
    this.sources = const [],
  });

  final String title;
  final List<String> columnLabels;
  final List<JsonMap> rows;
  final String? footnote;
  final List<String> sources;

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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.headline,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                defaultColumnWidth: const IntrinsicColumnWidth(),
                border: TableBorder.all(color: AppColors.divider, width: 1),
                children: [
                  TableRow(
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceContainer,
                    ),
                    children: columnLabels
                        .map(
                          (label) => Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              label,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: AppColors.headline,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  ...rows.map((row) {
                    final label = _str(row, 'label', '—');
                    final vals = _stringList(row['values']);
                    final cells = <String>[
                      label,
                      ...List.generate(
                        columnLabels.length - 1,
                        (i) => i < vals.length ? vals[i] : '—',
                      ),
                    ];
                    return TableRow(
                      children: cells
                          .map(
                            (c) => Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                c,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.deepBrown,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  }),
                ],
              ),
            ),
            if (footnote != null) ...[
              const SizedBox(height: 10),
              Text(
                footnote!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedText,
                ),
              ),
            ],
            if (sources.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Sources',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.headline,
                ),
              ),
              ...sources.map(
                (u) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: SelectableText(
                    u,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FeedingQuantityGuideBody extends StatelessWidget {
  const _FeedingQuantityGuideBody({
    required this.productName,
    required this.summary,
    required this.rows,
    this.caution,
    this.sourceUrl,
  });

  final String productName;
  final String summary;
  final List<JsonMap> rows;
  final String? caution;
  final String? sourceUrl;

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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Feeding guide: $productName',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.headline,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              summary,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.deepBrown,
              ),
            ),
            const SizedBox(height: 12),
            ...rows.map((r) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        _str(r, 'band', '—'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.headline,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        _str(r, 'amount', '—'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.deepBrown,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (caution != null) ...[
              const SizedBox(height: 8),
              Text(
                caution!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.warning,
                ),
              ),
            ],
            if (sourceUrl != null) ...[
              const SizedBox(height: 8),
              SelectableText(
                sourceUrl!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PetFoodSafetyAnswerBody extends StatelessWidget {
  const _PetFoodSafetyAnswerBody({
    required this.questionSummary,
    required this.safeLevel,
    required this.explanation,
    this.bullets = const [],
    this.sources = const [],
  });

  final String questionSummary;
  final String safeLevel;
  final String explanation;
  final List<String> bullets;
  final List<String> sources;

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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              questionSummary,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.headline,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Chip(
              label: Text(
                safeLevel.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.onPrimary,
                ),
              ),
              backgroundColor: AppColors.primary,
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            const SizedBox(height: 10),
            Text(
              explanation,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.deepBrown,
              ),
            ),
            if (bullets.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...bullets.map(
                (b) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          b,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.deepBrown,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (sources.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Sources',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.headline,
                ),
              ),
              ...sources.map(
                (u) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: SelectableText(
                    u,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PetHabitTipsBody extends StatelessWidget {
  const _PetHabitTipsBody({
    required this.title,
    required this.dos,
    required this.donts,
    this.sources = const [],
  });

  final String title;
  final List<String> dos;
  final List<String> donts;
  final List<String> sources;

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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.headline,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Do',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
            ...dos.map(
              (t) => Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Text(
                  '• $t',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.deepBrown,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Don't",
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            ...donts.map(
              (t) => Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Text(
                  '• $t',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.deepBrown,
                  ),
                ),
              ),
            ),
            if (sources.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Sources',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.headline,
                ),
              ),
              ...sources.map(
                (u) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: SelectableText(
                    u,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PetTopicAdviceBody extends StatelessWidget {
  const _PetTopicAdviceBody({
    required this.title,
    required this.topic,
    required this.summary,
    this.bullets = const [],
    this.dos = const [],
    this.donts = const [],
    this.sources = const [],
  });

  final String title;
  final String topic;
  final String summary;
  final List<String> bullets;
  final List<String> dos;
  final List<String> donts;
  final List<String> sources;

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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.headline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Chip(
                  label: Text(
                    topic,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                  backgroundColor: AppColors.primary,
                  side: BorderSide.none,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              summary,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.deepBrown,
              ),
            ),
            if (bullets.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...bullets.map(
                (b) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          b,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.deepBrown,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (dos.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Do',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ...dos.map(
                (t) => Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Text(
                    '• $t',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.deepBrown,
                    ),
                  ),
                ),
              ),
            ],
            if (donts.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                "Don't",
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ...donts.map(
                (t) => Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Text(
                    '• $t',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.deepBrown,
                    ),
                  ),
                ),
              ),
            ],
            if (sources.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Sources',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.headline,
                ),
              ),
              ...sources.map(
                (u) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: SelectableText(
                    u,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
