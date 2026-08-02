import 'dart:async';

import '../games_services.dart';

export 'package:games_services_platform_interface/models.dart';

/// A helper class that contains all of the library's functions.
/// This is a support class for apps that use pre-3.0 versions of the library.
/// Please consider using [GameAuth] for authentication, [Achievements] for anything related to Achievements,
/// [Leaderboards] for anything related to Leaderboards, [Player] for anything related to Player,
/// and [SaveGame] for anything related to game saves.
class GamesServices {
  /// Stream of the currently authenticated player. If not null, the player
  /// is signed in & games_services functionality is available.
  static Stream<PlayerData?> get player => GameAuth.player;

  /// Check if the current player is underage (always false on Android).
  static Future<bool?> get playerIsUnderage => Player.isUnderage;

  /// Check if the current player is restricted from joining multiplayer games (always false on Android).
  static Future<bool?> get playerIsMultiplayerGamingRestricted =>
      Player.isMultiplayerGamingRestricted;

  /// Check if the current player is restricted from using personalized communication on
  /// the device (always false on Android).
  static Future<bool?> get playerIsPersonalizedCommunicationRestricted =>
      Player.isPersonalizedCommunicationRestricted;

  /// Sign the user into Game Center or Google Play Games. This must be called before
  /// taking any action (such as submitting a score or unlocking an achievement).
  static Future<String?> signIn() => GameAuth.signIn();

  /// Check to see if the user is currently signed into Game Center or Google Play Games.
  static Future<bool> get isSignedIn => GameAuth.isSignedIn;

  /// Retrieve a Google Play Games `server_auth_code` to be used by a backend,
  /// such as Firebase, to authenticate the user. `null` on other platforms.
  static Future<String?> getAuthCode(String clientID) async =>
      await GameAuth.getAuthCode(clientID);

  /// Open the device's default achievements screen.
  static Future<String?> showAchievements() => Achievements.showAchievements();

  /// Get achievements as a list. Use this to build a custom UI.
  /// To show the device's default achievements screen use [showAchievements].
  ///
  /// The `forceRefresh` argument will invalidate the cache on Android, fetching
  /// the latest results. It has no affect on iOS.
  static Future<List<AchievementItemData>?> loadAchievements({
    bool forceRefresh = false,
    bool ignoreImages = false,
  }) => Achievements.loadAchievements(
    forceRefresh: forceRefresh,
    ignoreImages: ignoreImages,
  );

  /// It will reset the achievements.
  static Future<String?> resetAchievements() =>
      Achievements.resetAchievements();

  /// Unlock an [achievement].
  /// [Achievement] takes three parameters:
  /// [Achievement.androidID] the achievement ID for Google Play Games.
  /// [Achievement.iOSID] the achievement ID for Game Center.
  /// [Achievement.percentComplete] the completion percentage of the achievement,
  /// this parameter is optional on iOS/macOS.
  /// [Achievement.showsCompletionBanner] for iOS only, defaults to true
  static Future<String?> unlock({required Achievement achievement}) =>
      Achievements.unlock(achievement: achievement);

  /// Increment an [achievement].
  /// [Achievement] takes two parameters:
  /// [Achievement.androidID] the achievement ID for Google Play Games.
  /// [Achievement.steps] If the achievement is of the incremental type
  /// you can use this method to increment the steps.
  /// * only for Android (see https://developers.google.com/games/services/android/achievements#unlocking_achievements).
  static Future<String?> increment({required Achievement achievement}) =>
      Achievements.increment(achievement: achievement);

  /// Open the device's default leaderboards screen. If a leaderboard ID is provided,

  /// it will display the specific leaderboard, otherwise it will show the list of all leaderboards.
  ///
  /// The `timeScope` parameter allows you to specify the time range for the leaderboard scores,
  /// only supported on Android. It has no effect on iOS.
  static Future<String?> showLeaderboards({
    String iOSLeaderboardID = "",
    String androidLeaderboardID = "",
    TimeScope timeScope = TimeScope.allTime,
    PlayerScope playerScope = PlayerScope.global,
  }) => Leaderboards.showLeaderboards(
    iOSLeaderboardID: iOSLeaderboardID,
    androidLeaderboardID: androidLeaderboardID,
    timeScope: timeScope,
    playerScope: playerScope,
  );

  /// Get leaderboard scores as a list. Use this to build a custom UI.
  /// To show the device's default leaderboards screen use [showLeaderboards].
  ///
  /// The `forceRefresh` argument will invalidate the cache on Android, fetching
  /// the latest results. It has no affect on iOS.
  ///
  /// A failed request throws a `PlatformException`. Its code is one of the
  /// constants in [LeaderboardScoresErrorCode].
  static Future<List<LeaderboardScoreData>?> loadLeaderboardScores({
    String iOSLeaderboardID = "",
    String androidLeaderboardID = "",
    bool playerCentered = false,
    required PlayerScope scope,
    required TimeScope timeScope,
    bool forceRefresh = false,
    required int maxResults,
  }) => Leaderboards.loadLeaderboardScores(
    iOSLeaderboardID: iOSLeaderboardID,
    androidLeaderboardID: androidLeaderboardID,
    playerCentered: playerCentered,
    scope: scope,
    timeScope: timeScope,
    maxResults: maxResults,
    forceRefresh: forceRefresh,
  );

  /// Submit a [score] to specific leaderboard.
  /// [Score] takes three parameters:
  /// [Score.androidID] the leaderboard ID for Google Play Games.
  /// [Score.iOSID] the leaderboard ID for Game Center.
  /// [Score.value] the score.
  static Future<String?> submitScore({required Score score}) =>
      Leaderboards.submitScore(score: score);

  /// Get the current player's ID.
  /// On iOS/macOS the player ID is unique for your game but not other games.
  static Future<String?> getPlayerID() => Player.getPlayerID();

  /// Get the current player's score for a specific leaderboard.
  static Future<int?> getPlayerScore({
    String iOSLeaderboardID = "",
    String androidLeaderboardID = "",
  }) => Player.getPlayerScore(
    iOSLeaderboardID: iOSLeaderboardID,
    androidLeaderboardID: androidLeaderboardID,
  );

  /// Get the current player's name.
  /// On iOS/macOS the player's alias is provided.
  static Future<String?> getPlayerName() => Player.getPlayerName();

  /// Get the player's icon-size profile image as a base64 encoded String.
  static Future<String?> getPlayerIconImage() => Player.getPlayerIconImage();

  /// Get the player's hi-res profile image as a base64 encoded String.
  static Future<String?> getPlayerHiResImage() => Player.getPlayerHiResImage();

  /// Show the Game Center Access Point for the current player.
  static Future<String?> showAccessPoint(AccessPointLocation location) =>
      Player.showAccessPoint(location);

  /// Hide the Game Center Access Point.
  static Future<String?> hideAccessPoint() => Player.hideAccessPoint();

  /// Save game with [data] and a unique [name].
  /// The [name] must be between 1 and 100 non-URL-reserved characters (a-z, A-Z, 0-9, or the symbols "-", ".", "_", or "~").
  static Future<String?> saveGame({
    required String data,
    required String name,
  }) => SaveGame.saveGame(data: data, name: name);

  /// Load game with [name].
  static Future<String?> loadGame({required String name}) =>
      SaveGame.loadGame(name: name);

  /// Open the device's default game selection screen. (Android only.)
  ///
  /// The `title` will be displayed at the top of the UI. If `maxResults` is
  /// `null`, all game saves will be shown.
  ///
  /// If `allowNew` is `true` and the user chooses to create a new save, a
  /// `NewSave` object will be returned. It can be modified to upload a new save
  /// to the cloud when ready.
  static Future<SavedGame?> showSavedGames({
    required String title,
    bool allowNew = true,
    bool allowDelete = true,
    int? maxResults,
  }) => SaveGame.showSavedGames(
    title: title,
    allowNew: allowNew,
    allowDelete: allowDelete,
    maxResults: maxResults,
  );

  /// Get all saved games.
  ///
  /// The `forceRefresh` argument will invalidate the cache on Android, fetching
  /// the latest results. It has no affect on iOS.
  static Future<List<SavedGame>?> getSavedGames({
    bool forceRefresh = false,
    bool ignoreImages = false,
  }) => SaveGame.getSavedGames(
    forceRefresh: forceRefresh,
    ignoreImages: ignoreImages,
  );

  /// Delete game with [name].
  Future<String?> deleteGame({required String name}) =>
      SaveGame.deleteGame(name: name);
}
