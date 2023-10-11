import 'dart:async';

import '../games_services.dart';

export 'package:games_services_platform_interface/models.dart';

/// A helper class that has all the library functions in one class.
/// This class to support apps that uses pre 3.0 versions.
/// Please consider using [GameAuth] for authintication, [Achievements] for anything related to Achievements,
/// [Leaderboards] for anything related to Leaderboards, [Player] for anything related to Player,
/// [SaveGame] for anything related to save game.
class GamesServices {
  /// To sign in the user.
  /// You need to call the sign in before making any action,
  /// (like sending a score or unlocking an achievement).
  static Future<String?> signIn() async {
    return await GameAuth.signIn();
  }

  /// Check to see if the user is currently signed into
  /// Game Center or Google Play Services
  static Future<bool> get isSignedIn => GameAuth.isSignedIn;

  /// It will open the achievements screen.
  static Future<String?> showAchievements() async {
    return await Achievements.showAchievements();
  }

  /// Get achievements as a list. Use this to build your own custom UI.
  /// To show the prebuilt system UI use [showAchievements]
  static Future<List<AchievementItemData>?> loadAchievements() async {
    return await Achievements.loadAchievements();
  }

  /// Unlock an [achievement].
  /// [Achievement] takes three parameters:
  /// [androidID] the achievement id for android.
  /// [iOSID] the achievement id for iOS.
  /// [percentComplete] the completion percent of the achievement, this parameter is
  /// optional in case of iOS.
  static Future<String?> unlock({required Achievement achievement}) async {
    return await Achievements.unlock(achievement: achievement);
  }

  /// Increment an [achievement].
  /// [Achievement] takes two parameters:
  /// [androidID] the achievement id for android.
  /// [steps] If the achievement is of the incremental type
  /// you can use this method to increment the steps.
  /// * only for Android (see https://developers.google.com/games/services/android/achievements#unlocking_achievements).
  static Future<String?> increment({required Achievement achievement}) async {
    return await Achievements.increment(achievement: achievement);
  }

  /// It will open the leaderboards screen.
  static Future<String?> showLeaderboards(
      {iOSLeaderboardID = "", androidLeaderboardID = ""}) async {
    return await Leaderboards.showLeaderboards(
        iOSLeaderboardID: iOSLeaderboardID,
        androidLeaderboardID: androidLeaderboardID);
  }

  /// Get leaderboard scores as a list. Use this to build your own custom UI.
  /// To show the prebuilt system screen use [showLeaderboards].
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

  /// Submit a [score] to specific leader board.
  /// [Score] takes three parameters:
  /// [androidLeaderboardID] the leader board id that you want to send the score for in case of android.
  /// [iOSLeaderboardID] the leader board id that you want to send the score for in case of iOS.
  /// [value] the score.
  static Future<String?> submitScore({required Score score}) async {
    return await Leaderboards.submitScore(score: score);
  }

  /// Get the player id.
  /// On iOS the player id is unique for your game but not other games.
  static Future<String?> getPlayerID() async {
    return await Player.getPlayerID();
  }

  /// Get player score for a specific leaderboard.
  static Future<int?> getPlayerScore(
      {iOSLeaderboardID = "", androidLeaderboardID = ""}) async {
    return await Player.getPlayerScore(
        iOSLeaderboardID: iOSLeaderboardID,
        androidLeaderboardID: androidLeaderboardID);
  }

  /// Get the player name.
  /// On iOS the player alias is the name used by the Player visible in the leaderboard
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

  /// Check if player is underage (iOS & MacOS only).
  static Future<bool?> get playerIsUnderage async {
    return await Player.isUnderage;
  }

  /// Check if player is restricted from joining multiplayer games (always false on Android).
  static Future<bool?> get playerIsMultiplayerGamingRestricted async {
    return await Player.isMultiplayerGamingRestricted;
  }

  /// Check if player is restricted from using personalized communication on
  /// the device (always false on Android).
  static Future<bool?> get playerIsPersonalizedCommunicationRestricted async {
    return await Player.isPersonalizedCommunicationRestricted;
  }

  /// Show the iOS Access Point.
  static Future<String?> showAccessPoint(AccessPointLocation location) async {
    return await Player.showAccessPoint(location);
  }

  /// Hide the iOS Access Point.
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
