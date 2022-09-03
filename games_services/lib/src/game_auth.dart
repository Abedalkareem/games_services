import 'package:games_services_platform_interface/game_services_platform_interface.dart';

abstract class GameAuth {
  /// To sign in the user.
  /// If you pass [shouldEnableSavedGame], a drive scope will be will be added to GoogleSignInOptions. This will happed just
  /// android as for iOS/macOS nothing is required to be sent when authenticate.
  /// You need to call the sign in before making any action,
  /// (like sending a score or unlocking an achievement).
  static Future<String?> signIn({bool shouldEnableSavedGame = false}) async {
    return await GamesServicesPlatform.instance
        .signIn(shouldEnableSavedGame: shouldEnableSavedGame);
  }

  /// Check to see if the user is currently signed into
  /// Game Center or Google Play Services
  static Future<bool> get isSignedIn async =>
      await GamesServicesPlatform.instance.isSignedIn ?? false;

  /// To sign the user out of Goole Play Services.
  /// After calling, you can no longer make any actions
  /// on the user's account.
  static Future<String?> signOut() async {
    return await GamesServicesPlatform.instance.signOut();
  }
}
