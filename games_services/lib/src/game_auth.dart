import 'package:games_services_platform_interface/game_services_platform_interface.dart';

abstract class GameAuth {
  /// Sign the user into Game Center or Google Play Games. This must be called before
  /// taking any action (such as submitting a score or unlocking an achievement).
  static Future<String?> signIn() async {
    return await GamesServicesPlatform.instance.signIn();
  }

  /// Check to see if the user is currently signed into Game Center or Google Play Games.
  static Future<bool> get isSignedIn async =>
      await GamesServicesPlatform.instance.isSignedIn ?? false;

  /// Retrieve a Google Play Games `server_auth_code` to be used by a backend,
  /// such as Firebase, to authenticate the user. `null` on other platforms.
  static Future<String?> getAuthCode(String clientID) async =>
      await GamesServicesPlatform.instance.getAuthCode(clientID);
}
