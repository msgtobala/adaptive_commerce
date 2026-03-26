import 'package:adaptive_commerce/core/resources/app_strings.dart';
import 'package:adaptive_commerce/core/widgets/app_brand_header.dart';
import 'package:adaptive_commerce/features/food/food_page.dart';
import 'package:adaptive_commerce/features/toys/checkout_page.dart';
import 'package:adaptive_commerce/features/toys/toys_page.dart';
import 'package:adaptive_commerce/features/onboarding/onboarding_page.dart';
import 'package:adaptive_commerce/layout/main_layout.dart';
import 'package:adaptive_commerce/features/vet/vet_page.dart';
import 'package:adaptive_commerce/theme/styles/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoute.onboarding.path,
    debugLogDiagnostics: kDebugMode,
    routes: [
      GoRoute(
        path: AppRoute.onboarding.path,
        name: AppRoute.onboarding.name,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoute.checkout.path,
        name: AppRoute.checkout.name,
        builder: (context, state) {
          final q = state.uri.queryParameters;
          return CheckoutPage(
            productName: q['name'] ?? '',
            price: q['price'] ?? '',
            seller: q['seller'] ?? '',
            productUrl: q['url'] ?? '',
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.food.path,
                name: AppRoute.food.name,
                builder: (context, state) => const FoodPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.vet.path,
                name: AppRoute.vet.name,
                builder: (context, state) => const VetPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.toys.path,
                name: AppRoute.toys.name,
                builder: (context, state) => const ToysPage(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => RouterErrorPage(state: state),
  );
});

/// Full-screen fallback for unknown deep links or malformed routes.
class RouterErrorPage extends StatelessWidget {
  const RouterErrorPage({super.key, required this.state});

  final GoRouterState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppBrandHeader(),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.routeNotFoundTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppStrings.routeNotFoundBody,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (state.matchedLocation.isNotEmpty ||
                          state.uri.path.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        SelectableText(
                          state.uri.toString(),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.mutedText),
                        ),
                      ],
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: () =>
                            context.go(AppRoute.defaultShellTab.path),
                        child: const Text(AppStrings.routeNotFoundBack),
                      ),
                    ],
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
