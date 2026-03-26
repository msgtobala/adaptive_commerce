import 'package:adaptive_commerce/core/router/app_routes.dart';
import 'package:adaptive_commerce/features/onboarding/pet_profile.dart';
import 'package:adaptive_commerce/features/onboarding/pet_profile_provider.dart';
import 'package:adaptive_commerce/theme/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

/// Merged core catalog + onboarding-specific [CatalogItem]s for GenUI.
final Catalog onboardingCatalog = CoreCatalogItems.asCatalog().copyWith([
  petTypeDropdown,
  petNameInput,
  petDobCalendar,
  petBreedDropdown,
  petGenderRadio,
  petProfileCard,
]);

// --- Schemas (json_schema_builder) ---

final Schema _petTypeDropdownSchema = S.object(
  description: 'Dropdown to choose dog or cat.',
  properties: {'label': S.string(description: 'Heading label for the step.')},
);

final Schema _petNameInputSchema = S.object(
  description: 'Single-line text field for the pet name.',
  properties: {
    'label': S.string(description: 'Label above the field.'),
    'hint': S.string(description: 'Placeholder text.'),
  },
);

final Schema _petDobCalendarSchema = S.object(
  description: 'Opens a date picker for pet date of birth.',
  properties: {'label': S.string(description: 'Label for the step.')},
);

final Schema _petBreedDropdownSchema = S.object(
  description: 'Breed dropdown; options depend on pet type from app state.',
  properties: {'label': S.string(description: 'Label above the dropdown.')},
);

final Schema _petGenderRadioSchema = S.object(
  description: 'Male / female selection.',
  properties: {'label': S.string(description: 'Label for the step.')},
);

final Schema _petProfileCardSchema = S.object(
  description:
      'Summary card with a Continue button. Profile text comes from app state.',
  properties: {'title': S.string(description: 'Card title.')},
);

// --- Catalog items ---

/// `PetTypeDropdown`: dog/cat dropdown.
final CatalogItem petTypeDropdown = CatalogItem(
  name: 'PetTypeDropdown',
  dataSchema: _petTypeDropdownSchema,
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    final label = (data['label'] as String?) ?? 'Pet type';
    return _PetTypeDropdownBody(label: label, itemContext: itemContext);
  },
);

/// `PetNameInput`: text field for name.
final CatalogItem petNameInput = CatalogItem(
  name: 'PetNameInput',
  dataSchema: _petNameInputSchema,
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    final label = (data['label'] as String?) ?? 'Pet name';
    final hint = (data['hint'] as String?) ?? 'Enter name';
    return _PetNameInputBody(
      label: label,
      hint: hint,
      itemContext: itemContext,
    );
  },
);

/// `PetDobCalendar`: date picker for DOB.
final CatalogItem petDobCalendar = CatalogItem(
  name: 'PetDobCalendar',
  dataSchema: _petDobCalendarSchema,
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    final label = (data['label'] as String?) ?? 'Date of birth';
    return _PetDobCalendarBody(label: label, itemContext: itemContext);
  },
);

/// `PetBreedDropdown`: breed list from [breedsForKind].
final CatalogItem petBreedDropdown = CatalogItem(
  name: 'PetBreedDropdown',
  dataSchema: _petBreedDropdownSchema,
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    final label = (data['label'] as String?) ?? 'Breed';
    return _PetBreedDropdownBody(label: label, itemContext: itemContext);
  },
);

/// `PetGenderRadio`: male/female.
final CatalogItem petGenderRadio = CatalogItem(
  name: 'PetGenderRadio',
  dataSchema: _petGenderRadioSchema,
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    final label = (data['label'] as String?) ?? 'Gender';
    return _PetGenderRadioBody(label: label, itemContext: itemContext);
  },
);

/// `PetProfileCard`: summary + Continue → main shell.
final CatalogItem petProfileCard = CatalogItem(
  name: 'PetProfileCard',
  dataSchema: _petProfileCardSchema,
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    final title = (data['title'] as String?) ?? 'Your pet profile';
    return _PetProfileCardBody(title: title);
  },
);

// --- Widget bodies ---

void _dispatchSubmit(
  CatalogItemContext itemContext,
  String field,
  Object? value,
) {
  itemContext.dispatchEvent(
    UserActionEvent(
      surfaceId: itemContext.surfaceId,
      name: 'onboardingFieldSubmitted',
      sourceComponentId: itemContext.id,
      context: {'field': field, 'value': value},
    ),
  );
}

/// Menu panel below the field. [menuWidth] must match the anchor (LayoutBuilder).
/// Without min/max width, M3 menus use [IntrinsicWidth] and shrink to label size.
MenuStyle _onboardingAnchorMenuStyle({
  required double menuWidth,
  double? maxHeight,
}) {
  return MenuStyle(
    alignment: AlignmentDirectional.bottomStart,
    minimumSize: WidgetStatePropertyAll(Size(menuWidth, 0)),
    maximumSize: WidgetStatePropertyAll(
      Size(menuWidth, maxHeight ?? double.infinity),
    ),
    backgroundColor: const WidgetStatePropertyAll(AppColors.surface),
    elevation: const WidgetStatePropertyAll(6.0),
    shadowColor: WidgetStatePropertyAll(
      AppColors.burgundy.withValues(alpha: 0.12),
    ),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.divider),
      ),
    ),
    padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 4)),
  );
}

double _menuWidthFromConstraints(
  BoxConstraints constraints,
  BuildContext context,
) {
  if (constraints.hasBoundedWidth) {
    return constraints.maxWidth;
  }
  return MediaQuery.sizeOf(context).width;
}

class _PetTypeDropdownBody extends ConsumerStatefulWidget {
  const _PetTypeDropdownBody({required this.label, required this.itemContext});

  final String label;
  final CatalogItemContext itemContext;

  @override
  ConsumerState<_PetTypeDropdownBody> createState() =>
      _PetTypeDropdownBodyState();
}

class _PetTypeDropdownBodyState extends ConsumerState<_PetTypeDropdownBody> {
  final MenuController _menuController = MenuController();

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(petProfileProvider);
    final display = profile.petType == null
        ? 'Select type'
        : (profile.petType == PetKind.dog ? 'Dog' : 'Cat');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.headline,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final menuW = _menuWidthFromConstraints(constraints, context);
              final itemStyle = MenuItemButton.styleFrom(
                foregroundColor: AppColors.headline,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                minimumSize: Size(menuW, 48),
                alignment: AlignmentDirectional.centerStart,
              );
              return MenuAnchor(
                controller: _menuController,
                crossAxisUnconstrained: false,
                alignmentOffset: const Offset(0, 4),
                style: _onboardingAnchorMenuStyle(menuWidth: menuW),
                menuChildren: [
                  MenuItemButton(
                    style: itemStyle,
                    onPressed: () {
                      _menuController.close();
                      ref
                          .read(petProfileProvider.notifier)
                          .setPetType(PetKind.dog);
                      _dispatchSubmit(widget.itemContext, 'petType', 'dog');
                    },
                    child: const Text('Dog'),
                  ),
                  MenuItemButton(
                    style: itemStyle,
                    onPressed: () {
                      _menuController.close();
                      ref
                          .read(petProfileProvider.notifier)
                          .setPetType(PetKind.cat);
                      _dispatchSubmit(widget.itemContext, 'petType', 'cat');
                    },
                    child: const Text('Cat'),
                  ),
                ],
                builder: (context, controller, child) {
                  return InputDecorator(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: () {
                        if (controller.isOpen) {
                          controller.close();
                        } else {
                          controller.open();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                display,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: profile.petType == null
                                          ? Theme.of(context).hintColor
                                          : AppColors.headline,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down_rounded,
                              color: Theme.of(context).hintColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PetNameInputBody extends ConsumerStatefulWidget {
  const _PetNameInputBody({
    required this.label,
    required this.hint,
    required this.itemContext,
  });

  final String label;
  final String hint;
  final CatalogItemContext itemContext;

  @override
  ConsumerState<_PetNameInputBody> createState() => _PetNameInputBodyState();
}

class _PetNameInputBodyState extends ConsumerState<_PetNameInputBody> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(petProfileProvider).name,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    ref.read(petProfileProvider.notifier).setName(name);
    _dispatchSubmit(widget.itemContext, 'name', name);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.headline,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: widget.hint,
              border: const OutlineInputBorder(),
              filled: true,
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 8),
          FilledButton(onPressed: _submit, child: const Text('Next')),
        ],
      ),
    );
  }
}

class _PetDobCalendarBody extends ConsumerWidget {
  const _PetDobCalendarBody({required this.label, required this.itemContext});

  final String label;
  final CatalogItemContext itemContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(petProfileProvider);
    final dob = profile.dateOfBirth;
    final text = dob != null
        ? MaterialLocalizations.of(context).formatFullDate(dob)
        : 'Choose date';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.headline,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: dob ?? DateTime(now.year - 1),
                firstDate: DateTime(1990),
                lastDate: now,
              );
              if (picked == null || !context.mounted) return;
              ref.read(petProfileProvider.notifier).setDateOfBirth(picked);
              _dispatchSubmit(
                itemContext,
                'dateOfBirth',
                picked.toIso8601String(),
              );
            },
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(text),
          ),
        ],
      ),
    );
  }
}

class _PetBreedDropdownBody extends ConsumerStatefulWidget {
  const _PetBreedDropdownBody({required this.label, required this.itemContext});

  final String label;
  final CatalogItemContext itemContext;

  @override
  ConsumerState<_PetBreedDropdownBody> createState() =>
      _PetBreedDropdownBodyState();
}

class _PetBreedDropdownBodyState extends ConsumerState<_PetBreedDropdownBody> {
  final MenuController _menuController = MenuController();

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(petProfileProvider);
    final kind = profile.petType;
    final options = breedsForKind(kind);
    final current = profile.breed.isNotEmpty ? profile.breed : null;
    final selected = options.contains(current) ? current : null;
    final display =
        selected ?? (profile.breed.isNotEmpty ? profile.breed : 'Select breed');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.headline,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (kind == null)
            Text(
              'Select pet type first.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.deepBrown),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final menuW = _menuWidthFromConstraints(constraints, context);
                final itemStyle = MenuItemButton.styleFrom(
                  foregroundColor: AppColors.headline,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  minimumSize: Size(menuW, 48),
                  alignment: AlignmentDirectional.centerStart,
                );
                return MenuAnchor(
                  controller: _menuController,
                  crossAxisUnconstrained: false,
                  alignmentOffset: const Offset(0, 4),
                  style: _onboardingAnchorMenuStyle(
                    menuWidth: menuW,
                    maxHeight: 280,
                  ),
                  menuChildren: [
                    for (final b in options)
                      MenuItemButton(
                        style: itemStyle,
                        onPressed: () {
                          _menuController.close();
                          ref.read(petProfileProvider.notifier).setBreed(b);
                          _dispatchSubmit(widget.itemContext, 'breed', b);
                        },
                        child: Text(b),
                      ),
                  ],
                  builder: (context, controller, child) {
                    return InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  display,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color:
                                            selected == null &&
                                                profile.breed.isEmpty
                                            ? Theme.of(context).hintColor
                                            : AppColors.headline,
                                        fontWeight: FontWeight.w500,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down_rounded,
                                color: Theme.of(context).hintColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

class _PetGenderRadioBody extends ConsumerWidget {
  const _PetGenderRadioBody({required this.label, required this.itemContext});

  final String label;
  final CatalogItemContext itemContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(petProfileProvider);
    final group = profile.gender;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.headline,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<PetGender>(
            multiSelectionEnabled: false,
            segments: const [
              ButtonSegment(
                value: PetGender.male,
                label: Text('Male'),
                icon: Icon(Icons.male_outlined),
              ),
              ButtonSegment(
                value: PetGender.female,
                label: Text('Female'),
                icon: Icon(Icons.female_outlined),
              ),
            ],
            selected: group != null ? {group} : <PetGender>{},
            emptySelectionAllowed: true,
            onSelectionChanged: (Set<PetGender> next) {
              if (next.isEmpty) return;
              final g = next.first;
              ref.read(petProfileProvider.notifier).setGender(g);
              _dispatchSubmit(
                itemContext,
                'gender',
                g == PetGender.male ? 'male' : 'female',
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PetProfileCardBody extends ConsumerWidget {
  const _PetProfileCardBody({required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(petProfileProvider);
    final dobText = p.dateOfBirth != null
        ? MaterialLocalizations.of(context).formatFullDate(p.dateOfBirth!)
        : '—';
    final ageText = p.dateOfBirth != null
        ? formatAgeInMonthsLabel(p.dateOfBirth!)
        : '—';

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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.headline,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _line('Type', p.petType?.name ?? '—'),
            _line('Name', p.name.isNotEmpty ? p.name : '—'),
            _line('Date of birth', dobText),
            _line('Age', ageText),
            _line('Breed', p.breed.isNotEmpty ? p.breed : '—'),
            _line(
              'Gender',
              p.gender != null
                  ? (p.gender == PetGender.male ? 'Male' : 'Female')
                  : '—',
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go(AppRoute.defaultShellTab.path),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _line(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              k,
              style: const TextStyle(
                color: AppColors.deepBrown,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Text(v)),
        ],
      ),
    );
  }
}
