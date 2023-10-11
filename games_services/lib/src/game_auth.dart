import 'package:games_services_platform_interface/game_services_platform_interface.dart';

abstract class GameAuth {
  /// To sign in the user.
  /// You need to call the sign in before making any action,
  /// (like sending a score or unlocking an achievement).
  static Future<String?> signIn() async {
    return await GamesServicesPlatform.instance.signIn();
  }

  /// Check to see if the user is currently signed into
  /// Game Center or Google Play Services
  static Future<bool> get isSignedIn async =>
      await GamesServicesPlatform.instance.isSignedIn ?? false;
}
