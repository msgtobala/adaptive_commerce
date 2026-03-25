/// Image and vector **paths** bundled under `assets/`.
///
/// Lives in `core/resources` alongside copy ([AppStrings]) and patterns
/// ([AppPatterns]) so static app content has one home.
///
/// **PNG:** use [Image.asset]. **SVG:** use `SvgPicture.asset` from `package:flutter_svg/flutter_svg.dart`.
///
/// Source: Happy Paws Figma frame ([Figma — node 1:3](https://www.figma.com/design/q28CrmRWnz85eekjk31kZv/Landing-page-for-Pet-food-store--Community-?node-id=1-3)).
abstract final class AppAssets {
  AppAssets._();

  static const String _dir = 'assets/images';

  // --- Raster (PNG) ---

  /// Large hero dog photo (main organic-shape crop).
  static const String heroDog = '$_dir/d017f31c5d993708887e28086c1663b82838e25f.png';

  /// Rottweiler with bowl (right collage).
  static const String dogRottweiler = '$_dir/4628902418e96670d71c47532a64922771d76fa8.png';

  /// Small dog (Chihuahua-style) with bowl.
  static const String dogSmall = '$_dir/b5603c6492eba6664386b3d43857ae82f4f778cc.png';

  /// Kibble / food bowl (repeated decorative bowls in the mockup).
  static const String foodBowl = '$_dir/a1ba1a597c96b7e7dfc77cf1ebe84f1e65d34d25.png';

  // --- Vectors (SVG) ---

  /// Brown organic blob behind the dogs (`Ellipse 1` in Figma).
  static const String heroBlob = '$_dir/728e2ef911e5333e57796a1dbcb68290d875841b.svg';

  /// Paw print emoji graphic near the logo.
  static const String pawPrints = '$_dir/715fc173ac0cac1cca296b1c2ecd29235a871954.svg';

  static const String iconFacebook = '$_dir/327e4cc18187a702ec7de0b7ac8ac55d64ea1880.svg';
  static const String iconInstagram = '$_dir/bf7da06de74fe02fb2905d719f3c5b7b37f3defa.svg';
  static const String iconWhatsapp = '$_dir/df34b4923c3f215399574436b31f0d5227a73c46.svg';
  static const String iconTwitter = '$_dir/7434a9267c1e3d0df9a95033ace5ca7ccc176e14.svg';
}
