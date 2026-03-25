/// User-visible and developer-facing **string constants** (no i18n yet).
abstract final class AppStrings {
  AppStrings._();

  static const String appName = 'Happy Paws';

  // --- Global error UX (see [configureGlobalErrorHandling]) ---
  static const String errorGenericTitle = 'Something went wrong';
  static const String errorGenericBody =
      'Please try again. If the problem continues, restart the app '
      'or contact support.';

  // --- Home (placeholder) ---
  static const String homeCounterHint =
      'You have pushed the button this many times:';
  static const String homeFabIncrementTooltip = 'Increment';

  // --- Routing ---
  static const String routeNotFoundTitle = 'Page not found';
  static const String routeNotFoundBody =
      'This link is invalid or the page was removed.';
  static const String routeNotFoundBackHome = 'Back to home';
}
