/// Canonical Firestore collection / document path segments.
///
/// Keep names aligned with [Security Rules](https://firebase.google.com/docs/rules).
abstract final class FirestorePaths {
  FirestorePaths._();

  /// Example: `products/{productId}`
  static const String productsCollection = 'products';

  static String product(String productId) => '$productsCollection/$productId';
}

/// Canonical Cloud Storage object prefixes.
abstract final class StoragePaths {
  StoragePaths._();

  /// General binary uploads (images, PDFs, etc.).
  static String assets(String segment) => 'assets/$segment';

  /// Per-user uploads when you have an auth uid.
  static String userAsset(String uid, String fileName) => 'users/$uid/assets/$fileName';

  /// Public shop media (hero images, catalog).
  static String shopMedia(String category, String fileName) =>
      'shop/$category/$fileName';
}
