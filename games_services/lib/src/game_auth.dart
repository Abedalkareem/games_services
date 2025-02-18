import 'dart:async';

import 'package:games_services/games_services.dart';
import 'package:games_services_platform_interface/game_services_platform_interface.dart';

abstract class GameAuth {
  /// Stream of the currently authenticated player. If not null, the player
  /// is signed in & games_services functionality is available.
  static Stream<PlayerData?> get player =>
      GamesServicesPlatform.instance.player;

  /// Sign the user into Game Center or Google Play Games. This must be called before
  /// taking any action (such as submitting a score or unlocking an achievement).
  static Future<String?> signIn() => GamesServicesPlatform.instance.signIn();

  /// Check to see if the user is currently signed into Game Center or Google Play Games.
  static Future<bool> get isSignedIn async {
    // resuses player stream to reduce code and platform channel communciation
    final completer = Completer<bool>();
    StreamSubscription? sub;
    sub = GamesServicesPlatform.instance.player.listen((data) {
      completer.complete(data != null);
      sub?.cancel();
    }, onError: (_) {
      completer.complete(false);
      sub?.cancel();
    });
    return completer.future;
  }

  /// Retrieve a Google Play Games `server_auth_code` to be used by a backend,
  /// such as Firebase, to authenticate the user. `null` on other platforms.
  static Future<String?> getAuthCode(String clientID,
          {bool forceRefreshToken = false}) =>
      GamesServicesPlatform.instance
          .getAuthCode(clientID, forceRefreshToken: forceRefreshToken);
}
