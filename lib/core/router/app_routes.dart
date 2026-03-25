/// Canonical paths and names for [GoRouter].
enum AppRoute {
  onboarding('/onboarding'),
  foodToys('/food-toys'),
  vet('/vet'),
  medication('/medication');

  const AppRoute(this.path);

  final String path;

  /// Tabs in [StatefulShellRoute] (same order as branches).
  static const List<AppRoute> shellTabRoutes = [
    foodToys,
    vet,
    medication,
  ];

  /// First main tab (default after onboarding / error recovery).
  static AppRoute get defaultShellTab => shellTabRoutes.first;
}
