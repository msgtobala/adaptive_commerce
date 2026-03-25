import 'package:adaptive_commerce/core/resources/app_strings.dart';
import 'package:adaptive_commerce/features/home/home_page.dart';
import 'package:adaptive_commerce/theme/styles/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoute.home.path,
    debugLogDiagnostics: kDebugMode,
    routes: [
      GoRoute(
        path: AppRoute.home.path,
        name: AppRoute.home.name,
        builder: (context, state) => const HomePage(),
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
      appBar: AppBar(title: const Text(AppStrings.routeNotFoundTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedText,
                      ),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go(AppRoute.home.path),
                child: const Text(AppStrings.routeNotFoundBackHome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
