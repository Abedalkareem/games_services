import 'dart:async';

import '../games_services.dart';

export 'package:games_services_platform_interface/models.dart';

/// A helper class that contains all of the library's functions.
/// This is a support class for apps that use pre-3.0 versions of the library.
/// Please consider using [GameAuth] for authentication, [Achievements] for anything related to Achievements,
/// [Leaderboards] for anything related to Leaderboards, [Player] for anything related to Player,
/// and [SaveGame] for anything related to game saves.
class GamesServices {
  /// Sign the user into Game Center or Google Play Games. This must be called before
  /// taking any action (such as submitting a score or unlocking an achievement).
  static Future<String?> signIn() async {
    return await GameAuth.signIn();
  }

  /// Check to see if the user is currently signed into Game Center or Google Play Games.
  static Future<bool> get isSignedIn => GameAuth.isSignedIn;

  /// Open the device's default achievements screen.
  static Future<String?> showAchievements() async {
    return await Achievements.showAchievements();
  }

  /// Get achievements as a list. Use this to build a custom UI.
  /// To show the device's default achievements screen use [showAchievements].
  static Future<List<AchievementItemData>?> loadAchievements() async {
    return await Achievements.loadAchievements();
  }

  /// Unlock an [achievement].
  /// [Achievement] takes three parameters:
  /// [androidID] the achievement ID for Google Play Games.
  /// [iOSID] the achievement ID for Game Center.
  /// [percentComplete] the completion percentage of the achievement,
  /// this parameter is optional on iOS/macOS.
  static Future<String?> unlock({required Achievement achievement}) async {
    return await Achievements.unlock(achievement: achievement);
  }

  /// Increment an [achievement].
  /// [Achievement] takes two parameters:
  /// [androidID] the achievement ID for Google Play Games.
  /// [steps] If the achievement is of the incremental type
  /// you can use this method to increment the steps.
  /// * only for Android (see https://developers.google.com/games/services/android/achievements#unlocking_achievements).
  static Future<String?> increment({required Achievement achievement}) async {
    return await Achievements.increment(achievement: achievement);
  }

  /// Open the device's default leaderboards screen. If a leaderboard ID is provided,
  /// it will display the specific leaderboard, otherwise it will show the list of all leaderboards.
  static Future<String?> showLeaderboards(
      {iOSLeaderboardID = "", androidLeaderboardID = ""}) async {
    return await Leaderboards.showLeaderboards(
        iOSLeaderboardID: iOSLeaderboardID,
        androidLeaderboardID: androidLeaderboardID);
  }

  /// Get leaderboard scores as a list. Use this to build a custom UI.
  /// To show the device's default leaderboards screen use [showLeaderboards].
  static Future<List<LeaderboardScoreData>?> loadLeaderboardScores(
      {iOSLeaderboardID = "",
      androidLeaderboardID = "",
      required PlayerScope scope,
      required TimeScope timeScope,
      required int maxResults}) async {
    return await Leaderboards.loadLeaderboardScores(
        iOSLeaderboardID: iOSLeaderboardID,
        androidLeaderboardID: androidLeaderboardID,
        scope: scope,
        timeScope: timeScope,
        maxResults: maxResults);
  }

  /// Submit a [score] to specific leaderboard.
  /// [Score] takes three parameters:
  /// [androidLeaderboardID] the leaderboard ID for Google Play Games.
  /// [iOSLeaderboardID] the leaderboard ID for Game Center.
  /// [value] the score.
  static Future<String?> submitScore({required Score score}) async {
    return await Leaderboards.submitScore(score: score);
  }

  /// Get the current player's ID.
  /// On iOS/macOS the player ID is unique for your game but not other games.
  static Future<String?> getPlayerID() async {
    return await Player.getPlayerID();
  }

  /// Get the current player's score for a specific leaderboard.
  static Future<int?> getPlayerScore(
      {iOSLeaderboardID = "", androidLeaderboardID = ""}) async {
    return await Player.getPlayerScore(
        iOSLeaderboardID: iOSLeaderboardID,
        androidLeaderboardID: androidLeaderboardID);
  }

  /// Get the current player's name.
  /// On iOS/macOS the player's alias is provided.
  static Future<String?> getPlayerName() async {
    return await Player.getPlayerName();
  }

  /// Get the player's icon-size profile image as a base64 encoded String.
  static Future<String?> getPlayerIconImage() async {
    return await Player.getPlayerIconImage();
  }

  /// Get the player's hi-res profile image as a base64 encoded String.
  static Future<String?> getPlayerHiResImage() async {
    return await Player.getPlayerHiResImage();
  }

  /// Check if the current player is underage (always false on Android).
  static Future<bool?> get playerIsUnderage async {
    return await Player.isUnderage;
  }

  /// Check if the current player is restricted from joining multiplayer games (always false on Android).
  static Future<bool?> get playerIsMultiplayerGamingRestricted async {
    return await Player.isMultiplayerGamingRestricted;
  }

  /// Check if the current player is restricted from using personalized communication on
  /// the device (always false on Android).
  static Future<bool?> get playerIsPersonalizedCommunicationRestricted async {
    return await Player.isPersonalizedCommunicationRestricted;
  }

  /// Show the Game Center Access Point for the current player.
  static Future<String?> showAccessPoint(AccessPointLocation location) async {
    return await Player.showAccessPoint(location);
  }

  /// Hide the Game Center Access Point.
  static Future<String?> hideAccessPoint() async {
    return await Player.hideAccessPoint();
  }

  /// Save game with [data] and a unique [name].
  /// The [name] must be between 1 and 100 non-URL-reserved characters (a-z, A-Z, 0-9, or the symbols "-", ".", "_", or "~").
  static Future<String?> saveGame(
      {required String data, required String name}) async {
    return await SaveGame.saveGame(data: data, name: name);
  }

  /// Load game with [name].
  static Future<String?> loadGame({required String name}) async {
    return await SaveGame.loadGame(name: name);
  }

  /// Get all saved games.
  static Future<List<SavedGame>?> getSavedGames() async {
    return await SaveGame.getSavedGames();
  }

  /// Delete game with [name].
  static Future<String?> deleteGame({required String name}) async {
    return await SaveGame.deleteGame(name: name);
  }
}
