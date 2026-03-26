import 'package:adaptive_commerce/theme/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:url_launcher/url_launcher.dart';

/// Veterinary tab catalog: strict schemas + custom widgets rendered by GenUI.

final Catalog vetCatalog = Catalog(
  [
    CoreCatalogItems.column,
    CoreCatalogItems.row,
    CoreCatalogItems.text,
    CoreCatalogItems.card,
    CoreCatalogItems.divider,
    vetVaccinationSchedule,
    vetRemediesAnswer,
    vetNearestVetFinder,
    vetTopicAdvice,
  ],
  catalogId: 'a2ui.org:standard_catalog_0_8_0',
);

const EdgeInsets _vetCardPadding = EdgeInsets.fromLTRB(20, 20, 20, 18);
const EdgeInsets _vetPanelPadding = EdgeInsets.all(16);

// --- Shared schemas ---

final Schema _stringListSchema = S.list(items: S.string());

// --- Custom widget schemas ---

final Schema _vaccinationRowSchema = S.object(
  properties: {
    'ageBand': S.string(),
    'vaccine': S.string(),
    'timing': S.string(),
    'notes': S.string(),
  },
  required: ['ageBand', 'vaccine'],
);

final Schema _vetVaccinationScheduleSchema = S.object(
  properties: {
    'title': S.string(),
    'summary': S.string(),
    'schedule': S.list(items: _vaccinationRowSchema),
    'safetyNote': S.string(),
    'whenToCallVet': _stringListSchema,
  },
  required: ['title', 'summary', 'schedule'],
);

final Schema _vetRemediesAnswerSchema = S.object(
  properties: {
    'title': S.string(),
    'suspectedCondition': S.string(),
    'homeCare': _stringListSchema,
    'treatmentOptions': _stringListSchema,
    'redFlags': _stringListSchema,
    'whenToSeeVetNow': _stringListSchema,
    'noteToConsult': S.string(),
  },
  required: [
    'title',
    'suspectedCondition',
    'homeCare',
    'treatmentOptions',
    'redFlags',
  ],
);

final Schema _vetNearestVetFinderSchema = S.object(
  properties: {
    'title': S.string(),
    'query': S.string(),
    'shortAnswer': S.string(),
    'mapSearchUrl': S.string(),
    'places': S.list(
      items: S.object(
        properties: {
          'placeName': S.string(),
          'address': S.string(),
          'phone': S.string(),
          'mapUrl': S.string(),
          'websiteUrl': S.string(),
        },
        required: ['placeName', 'address'],
      ),
    ),
    'tips': _stringListSchema,
    'urgentSigns': _stringListSchema,
  },
  required: ['title', 'query', 'shortAnswer', 'places'],
);

final Schema _vetTopicAdviceSchema = S.object(
  properties: {
    'title': S.string(),
    'summary': S.string(),
    'bullets': _stringListSchema,
  },
  required: ['title', 'summary', 'bullets'],
);

// --- Catalog items ---

final CatalogItem vetVaccinationSchedule = CatalogItem(
  name: 'VetVaccinationSchedule',
  dataSchema: _vetVaccinationScheduleSchema,
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    return _VetVaccinationScheduleBody(
      title: _str(data, 'title', 'Vaccination schedule'),
      summary: _str(data, 'summary', ''),
      schedule: _mapList(data['schedule']),
      safetyNote: _optionalStr(data['safetyNote']),
      whenToCallVet: _stringList(data['whenToCallVet']),
    );
  },
);

final CatalogItem vetRemediesAnswer = CatalogItem(
  name: 'VetRemediesAnswer',
  dataSchema: _vetRemediesAnswerSchema,
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    return _VetRemediesAnswerBody(
      title: _str(data, 'title', 'Remedies'),
      suspectedCondition: _str(data, 'suspectedCondition', ''),
      homeCare: _stringList(data['homeCare']),
      treatmentOptions: _stringList(data['treatmentOptions']),
      redFlags: _stringList(data['redFlags']),
      whenToSeeVetNow: _stringList(data['whenToSeeVetNow']),
      noteToConsult: _optionalStr(data['noteToConsult']),
    );
  },
);

final CatalogItem vetNearestVetFinder = CatalogItem(
  name: 'VetNearestVetFinder',
  dataSchema: _vetNearestVetFinderSchema,
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    return _VetNearestVetFinderBody(
      title: _str(data, 'title', 'Nearest veterinary help'),
      query: _str(data, 'query', ''),
      shortAnswer: _str(data, 'shortAnswer', ''),
      mapSearchUrl: _str(data, 'mapSearchUrl', ''),
      places: _mapList(data['places']),
      tips: _stringList(data['tips']),
      urgentSigns: _stringList(data['urgentSigns']),
    );
  },
);

final CatalogItem vetTopicAdvice = CatalogItem(
  name: 'VetTopicAdvice',
  dataSchema: _vetTopicAdviceSchema,
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    return _VetTopicAdviceBody(
      title: _str(data, 'title', 'Veterinary'),
      summary: _str(data, 'summary', ''),
      bullets: _stringList(data['bullets']),
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

class _VetVaccinationScheduleBody extends StatelessWidget {
  const _VetVaccinationScheduleBody({
    required this.title,
    required this.summary,
    required this.schedule,
    this.safetyNote,
    required this.whenToCallVet,
  });

  final String title;
  final String summary;
  final List<JsonMap> schedule;
  final String? safetyNote;
  final List<String> whenToCallVet;

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
        padding: _vetCardPadding,
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
            ...schedule.map((row) {
              final ageBand = _str(row, 'ageBand', '—');
              final vaccine = _str(row, 'vaccine', '—');
              final timing = _optionalStr(row['timing']);
              final notes = _optionalStr(row['notes']);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Padding(
                    padding: _vetPanelPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$ageBand: $vaccine',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.headline,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                        ),
                        if (timing != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Timing: $timing',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.bodySecondary,
                              height: 1.35,
                            ),
                          ),
                        ],
                        if (notes != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            notes,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.deepBrown,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
            if (safetyNote != null) ...[
              const SizedBox(height: 14),
              Text(
                safetyNote!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.warning,
                  height: 1.4,
                ),
              ),
            ],
            if (whenToCallVet.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'When to call your vet',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.headline,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...whenToCallVet.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    s,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.deepBrown,
                      height: 1.35,
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

class _VetRemediesAnswerBody extends StatelessWidget {
  const _VetRemediesAnswerBody({
    required this.title,
    required this.suspectedCondition,
    required this.homeCare,
    required this.treatmentOptions,
    required this.redFlags,
    required this.whenToSeeVetNow,
    this.noteToConsult,
  });

  final String title;
  final String suspectedCondition;
  final List<String> homeCare;
  final List<String> treatmentOptions;
  final List<String> redFlags;
  final List<String> whenToSeeVetNow;
  final String? noteToConsult;

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
        padding: _vetCardPadding,
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
              'What this could be: $suspectedCondition',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.deepBrown,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Padding(
                padding: _vetPanelPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Home care',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.headline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...homeCare.map(
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
                    const SizedBox(height: 12),
                    Text(
                      'Treatment options (discuss with your vet)',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.headline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...treatmentOptions.map(
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
            ),
            const SizedBox(height: 12),
            Text(
              'Red flags (seek help soon)',
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.headline,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...redFlags.map(
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
            if (whenToSeeVetNow.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'When to see a vet immediately',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.headline,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...whenToSeeVetNow.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '• $s',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.warning,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
            ],
            if (noteToConsult != null) ...[
              const SizedBox(height: 12),
              Text(
                noteToConsult!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.mutedText,
                  height: 1.45,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VetNearestVetFinderBody extends StatelessWidget {
  const _VetNearestVetFinderBody({
    required this.title,
    required this.query,
    required this.mapSearchUrl,
    required this.shortAnswer,
    required this.places,
    required this.tips,
    required this.urgentSigns,
  });

  final String title;
  final String query;
  final String mapSearchUrl;
  final String shortAnswer;
  final List<JsonMap> places;
  final List<String> tips;
  final List<String> urgentSigns;

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
        padding: _vetCardPadding,
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
              shortAnswer,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.deepBrown,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            if (places.isNotEmpty) ...[
              Text(
                'Recommended clinics (verify on maps)',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.headline,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              ...places.map((p) {
                final placeName = _str(p, 'placeName', '').trim();
                final address = _str(p, 'address', '').trim();
                final phone = _str(p, 'phone', '').trim();
                final mapUrl = _str(p, 'mapUrl', '').trim();
                final websiteUrl = _str(p, 'websiteUrl', '').trim();
                final linkToOpen = mapUrl.isNotEmpty ? mapUrl : websiteUrl;
                final linkUri = Uri.tryParse(linkToOpen);
                final canOpen = linkUri != null && linkUri.hasScheme;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Padding(
                      padding: _vetPanelPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            placeName.isNotEmpty ? placeName : 'Clinic',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppColors.headline,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                          ),
                          if (address.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              address,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.deepBrown,
                                height: 1.35,
                              ),
                            ),
                          ],
                          if (phone.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              phone,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.deepBrown,
                                height: 1.35,
                              ),
                            ),
                          ],
                          if (linkToOpen.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Builder(
                              builder: (context) {
                                return InkWell(
                                  onTap: !canOpen
                                      ? null
                                      : () async {
                                          final uri = linkUri;
                                          final ok = await launchUrl(
                                            uri,
                                            mode: LaunchMode.externalApplication,
                                          );
                                          if (!ok && context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Could not open link',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                  child: SelectableText(
                                    linkToOpen,
                                    style:
                                        theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.primary,
                                      height: 1.35,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ] else ...[
              Text(
                'Map search for: $query',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.headline,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Builder(
                builder: (context) {
                  final uri = Uri.tryParse(mapSearchUrl);
                  final canOpen = uri != null && uri.hasScheme;
                  return InkWell(
                    onTap: !canOpen
                        ? null
                        : () async {
                            final ok = await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                            if (!ok && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Could not open map search'),
                                ),
                              );
                            }
                          },
                    child: Text(
                      mapSearchUrl,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.primary,
                        height: 1.35,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  );
                },
              ),
            ],
            if (tips.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'Quick tips',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.headline,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...tips.map(
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
            if (urgentSigns.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Urgent signs (go sooner)',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.headline,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...urgentSigns.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '• $s',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.warning,
                      height: 1.35,
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

class _VetTopicAdviceBody extends StatelessWidget {
  const _VetTopicAdviceBody({
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
        padding: _vetCardPadding,
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
              'You can ask about',
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

