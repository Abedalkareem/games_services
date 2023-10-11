import 'package:games_services_platform_interface/game_services_platform_interface.dart';
import 'package:games_services_platform_interface/models.dart';

abstract class Player {
  /// Show the Game Center Access Point for the current player.
  static Future<String?> showAccessPoint(AccessPointLocation location) async {
    return await GamesServicesPlatform.instance.showAccessPoint(location);
  }

  /// Hide the Game Center Access Point.
  static Future<String?> hideAccessPoint() async {
    return await GamesServicesPlatform.instance.hideAccessPoint();
  }

  /// Get the current player's ID.
  /// On iOS/macOS the player ID is unique for your game but not other games.
  static Future<String?> getPlayerID() async {
    return await GamesServicesPlatform.instance.getPlayerID();
  }

  /// Get the current player's name.
  /// On iOS/macOS the player's alias is provided.
  static Future<String?> getPlayerName() async {
    return await GamesServicesPlatform.instance.getPlayerName();
  }

  /// Get the player's icon-size profile image as a base64 encoded String.
  static Future<String?> getPlayerIconImage() async {
    return (await GamesServicesPlatform.instance.getPlayerIconImage())
        ?.replaceAll("\n", "");
  }

  /// Get the player's hi-res profile image as a base64 encoded String.
  static Future<String?> getPlayerHiResImage() async {
    return (await GamesServicesPlatform.instance.getPlayerHiResImage())
        ?.replaceAll("\n", "");
  }

  /// Get the current player's score for a specific leaderboard.
  static Future<int?> getPlayerScore(
      {iOSLeaderboardID = "", androidLeaderboardID = ""}) async {
    return await GamesServicesPlatform.instance.getPlayerScore(
        iOSLeaderboardID: iOSLeaderboardID,
        androidLeaderboardID: androidLeaderboardID);
  }

  /// Check if the current player is underage (always false on Android).
  static Future<bool?> get isUnderage async {
    return await GamesServicesPlatform.instance.playerIsUnderage;
  }

  /// Check if the current player is restricted from joining multiplayer games (always false on Android).
  static Future<bool?> get isMultiplayerGamingRestricted async {
    return await GamesServicesPlatform
        .instance.playerIsMultiplayerGamingRestricted;
  }

  /// Check if the current player is restricted from using personalized communication on
  /// the device (always false on Android).
  static Future<bool?> get isPersonalizedCommunicationRestricted async {
    return await GamesServicesPlatform
        .instance.playerIsPersonalizedCommunicationRestricted;
  }
}
