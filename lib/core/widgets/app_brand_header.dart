import 'package:adaptive_commerce/core/resources/app_strings.dart';
import 'package:adaptive_commerce/theme/styles/app_colors.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// **Happy Paws** title — use at the top of every screen (above the tab bar on main shell).
class AppBrandHeader extends StatelessWidget {
  const AppBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // Extra top + bottom padding so the tab bar sits lower with more air above it.
    final top = kIsWeb ? 28.0 : 20.0;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, top, 16, 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          AppStrings.appName,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.headline,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}
