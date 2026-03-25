import 'package:adaptive_commerce/core/resources/app_strings.dart';
import 'package:adaptive_commerce/core/router/app_routes.dart';
import 'package:adaptive_commerce/core/widgets/app_brand_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Collects pet profile (name, birth date, breed, gender) — UI in a later task.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppBrandHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Text(
                AppStrings.onboardingTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AppStrings.onboardingSubtitle,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () =>
                          context.go(AppRoute.defaultShellTab.path),
                      child: const Text(AppStrings.onboardingContinue),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
