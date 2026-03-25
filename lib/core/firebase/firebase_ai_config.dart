/// Defaults for [Firebase AI Logic](https://firebase.google.com/docs/ai-logic).
///
/// Match the model id to what you enable in the Firebase console.
abstract final class FirebaseAiConfig {
  FirebaseAiConfig._();

  /// Text generation model (change if your project uses another tier).
  static const String generativeModel = 'gemini-2.0-flash';
}
