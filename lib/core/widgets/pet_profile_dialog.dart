import 'package:adaptive_commerce/core/resources/app_strings.dart';
import 'package:adaptive_commerce/features/onboarding/pet_profile.dart';
import 'package:adaptive_commerce/theme/styles/app_colors.dart';
import 'package:flutter/material.dart';

/// Shows read-only pet profile from onboarding ([PetProfile]).
void showPetProfileDialog(BuildContext context, PetProfile profile) {
  final isEmpty = profile.petType == null &&
      profile.name.trim().isEmpty &&
      profile.dateOfBirth == null &&
      profile.breed.trim().isEmpty &&
      profile.gender == null;

  showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text(
          AppStrings.petProfileDialogTitle,
          style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                color: AppColors.headline,
                fontWeight: FontWeight.w600,
              ),
        ),
        content: SingleChildScrollView(
          child: isEmpty
              ? Text(
                  AppStrings.petProfileEmpty,
                  style: Theme.of(ctx).textTheme.bodyLarge?.copyWith(
                        color: AppColors.deepBrown,
                        height: 1.4,
                      ),
                )
              : _PetProfileBody(profile: profile),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(AppStrings.petProfileClose),
          ),
        ],
      );
    },
  );
}

class _PetProfileBody extends StatelessWidget {
  const _PetProfileBody({required this.profile});

  final PetProfile profile;

  @override
  Widget build(BuildContext context) {
    final dobText = profile.dateOfBirth != null
        ? MaterialLocalizations.of(context).formatFullDate(profile.dateOfBirth!)
        : '—';
    final ageText = profile.dateOfBirth != null
        ? formatAgeInMonthsLabel(profile.dateOfBirth!)
        : '—';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _line(context, 'Type', profile.petType?.name ?? '—'),
        _line(context, 'Name', profile.name.trim().isNotEmpty ? profile.name : '—'),
        _line(context, 'Date of birth', dobText),
        _line(context, 'Age', ageText),
        _line(context, 'Breed', profile.breed.trim().isNotEmpty ? profile.breed : '—'),
        _line(
          context,
          'Gender',
          profile.gender != null
              ? (profile.gender == PetGender.male ? 'Male' : 'Female')
              : '—',
        ),
      ],
    );
  }

  Widget _line(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 124,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.deepBrown,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.headline,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
