import 'package:adaptive_commerce/core/resources/app_strings.dart';
import 'package:adaptive_commerce/core/widgets/pet_profile_dialog.dart';
import 'package:adaptive_commerce/features/onboarding/pet_profile_provider.dart';
import 'package:adaptive_commerce/theme/styles/app_colors.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// **Happy Paws** title — use at the top of every screen (above the tab bar on main shell).
///
/// When [showPetProfileAction] is true (main shell), shows **Pet Profile** next to the title.
class AppBrandHeader extends StatelessWidget {
  const AppBrandHeader({
    super.key,
    this.showPetProfileAction = false,
  });

  final bool showPetProfileAction;

  @override
  Widget build(BuildContext context) {
    // Extra top + bottom padding so the tab bar sits lower with more air above it.
    final top = kIsWeb ? 28.0 : 20.0;
    final title = Text(
      AppStrings.appName,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.headline,
            fontWeight: FontWeight.w700,
          ),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(16, top, 16, 16),
      child: showPetProfileAction
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: title),
                const _PetProfileHeaderChip(),
              ],
            )
          : Align(
              alignment: Alignment.centerLeft,
              child: title,
            ),
    );
  }
}

class _PetProfileHeaderChip extends ConsumerWidget {
  const _PetProfileHeaderChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final profile = ref.read(petProfileProvider);
          showPetProfileDialog(context, profile);
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.account_circle,
                size: 28,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                AppStrings.petProfile,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.deepBrown,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

