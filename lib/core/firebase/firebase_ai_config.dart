/// Defaults for [Firebase AI Logic](https://firebase.google.com/docs/ai-logic).
///
/// Match the model id to what you enable in the Firebase console.
abstract final class FirebaseAiConfig {
  FirebaseAiConfig._();

  /// Text generation model (change if your project uses another tier).
  ///
  /// `gemini-2.0-flash` is not offered to new Firebase AI / Google AI users;
  /// use a current id such as `gemini-2.5-flash` (see Firebase console → AI Logic).
  static const String generativeModel = 'gemini-2.5-flash';
}
