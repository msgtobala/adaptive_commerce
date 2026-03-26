/// Canonical paths and names for [GoRouter].
enum AppRoute {
  onboarding('/onboarding'),
  food('/food'),
  vet('/vet'),
  toys('/toys'),
  /// Full-screen mock checkout (outside tab shell).
  checkout('/checkout');

  const AppRoute(this.path);

  final String path;

  /// Tabs in [StatefulShellRoute] (same order as branches).
  static const List<AppRoute> shellTabRoutes = [food, vet, toys];

  /// First main tab (default after onboarding / error recovery).
  static AppRoute get defaultShellTab => shellTabRoutes.first;
}
