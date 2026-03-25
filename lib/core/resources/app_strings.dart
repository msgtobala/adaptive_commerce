/// User-visible and developer-facing **string constants** (no i18n yet).
abstract final class AppStrings {
  AppStrings._();

  static const String appName = 'Happy Paws';

  // --- Global error UX (see [configureGlobalErrorHandling]) ---
  static const String errorGenericTitle = 'Something went wrong';
  static const String errorGenericBody =
      'Please try again. If the problem continues, restart the app '
      'or contact support.';

  // --- Onboarding (placeholder) ---
  static const String onboardingTitle = 'Welcome';
  static const String onboardingSubtitle =
      'Pet details will go here — name, birth date, breed, gender.';
  static const String onboardingContinue = 'Continue';

  // --- Shell prompt bar (fixed bottom on tab pages) ---
  static const String shellPromptHint = 'Ask anything…';
  static const String shellPromptSendTooltip = 'Send';

  // --- Pet profile (shell header) ---
  static const String petProfile = 'Pet Profile';
  static const String petProfileDialogTitle = 'Pet profile';
  static const String petProfileClose = 'Close';
  static const String petProfileEmpty =
      'No details yet. Finish onboarding to fill your pet profile.';

  // --- Main shell (top tab bar) ---
  static const String navFoodToys = 'Food & toys';
  static const String navVeterinary = 'Veterinary';
  static const String navMedication = 'Medication';

  // --- Routing ---
  static const String routeNotFoundTitle = 'Page not found';
  static const String routeNotFoundBody =
      'This link is invalid or the page was removed.';
  static const String routeNotFoundBack = 'Back to app';
}
