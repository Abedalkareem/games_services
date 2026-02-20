import 'dart:async';

import '../games_services.dart';

export 'package:games_services_platform_interface/models.dart';

/// A helper class that contains all of the library's functions.
/// This is a support class for apps that use pre-3.0 versions of the library.
/// Please consider using the following specialized classes as needed:
/// [GameAuth], [Achievements], [Leaderboards], [Player], [SaveGame], and [Friends].
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
  static Future<String?> getAuthCode(String clientID) =>
      GameAuth.getAuthCode(clientID);

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
  }) =>
      Achievements.loadAchievements(
          forceRefresh: forceRefresh, ignoreImages: ignoreImages);

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
  static Future<String?> showLeaderboards({
    String iOSLeaderboardID = "",
    String androidLeaderboardID = "",
  }) =>
      Leaderboards.showLeaderboards(
          iOSLeaderboardID: iOSLeaderboardID,
          androidLeaderboardID: androidLeaderboardID);

  /// Get leaderboard scores as a list. Use this to build a custom UI.
  /// To show the device's default leaderboards screen use [showLeaderboards].
  ///
  /// The `forceRefresh` argument will invalidate the cache on Android, fetching
  /// the latest results. It has no affect on iOS.
  static Future<List<LeaderboardScoreData>?> loadLeaderboardScores({
    String iOSLeaderboardID = "",
    String androidLeaderboardID = "",
    bool playerCentered = false,
    required PlayerScope scope,
    required TimeScope timeScope,
    bool forceRefresh = false,
    required int maxResults,
  }) =>
      Leaderboards.loadLeaderboardScores(
          iOSLeaderboardID: iOSLeaderboardID,
          androidLeaderboardID: androidLeaderboardID,
          playerCentered: playerCentered,
          scope: scope,
          timeScope: timeScope,
          maxResults: maxResults,
          forceRefresh: forceRefresh);

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
  }) =>
      Player.getPlayerScore(
          iOSLeaderboardID: iOSLeaderboardID,
          androidLeaderboardID: androidLeaderboardID);

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
  static Future<String?> saveGame(
          {required String data, required String name}) =>
      SaveGame.saveGame(data: data, name: name);

  /// Load game with [name].
  static Future<String?> loadGame({required String name}) =>
      SaveGame.loadGame(name: name);

  /// Get all saved games.
  ///
  /// The `forceRefresh` argument will invalidate the cache on Android, fetching
  /// the latest results. It has no affect on iOS.
  static Future<List<SavedGame>?> getSavedGames({bool forceRefresh = false}) =>
      SaveGame.getSavedGames(forceRefresh: forceRefresh);

  /// Delete game with [name].
  static Future<String?> deleteGame({required String name}) =>
      SaveGame.deleteGame(name: name);

  /// Open the default friends list screen on iOS/MacOS. Does nothing on Android.
  static Future<String?> showFriendsList() => Friends.showFriendsList();

  /// Check for access to the player's friends list. Useful for presenting
  /// differing UIs based on access. Calling [loadFriends] automatically request
  /// access if needed and will throw an error if access is denied.
  static Future<FriendsAccess> get friendsAccess => Friends.access;

  /// Get the current player's friends list.
  ///
  /// The `forceRefresh` argument will invalidate the cache on Android, fetching
  /// the latest results. It has no affect on iOS.
  static Future<List<PlayerData>?> loadFriends({
    required int maxResults,
    bool forceRefresh = false,
  }) =>
      Friends.loadFriends(pageSize: maxResults, forceRefresh: forceRefresh);

  /// View a player's profile. Passing in the current player's ID will display
  /// their profile.
  ///
  /// On Android, this presents a player comparison profile
  /// between the current player and the player identified by the `playerID`. The
  /// `playerInGameName` and `localInGameName` will be presented on this screen to
  /// allow in game nicknames to carry over to Google Play Games, and any friend
  /// request sent from this view will include the `localInGameName`.
  static Future<String?> viewPlayerProfile(
          {required String playerID,
          String? playerInGameName,
          String? localInGameName}) =>
      Friends.viewPlayerProfile(
          playerID: playerID,
          playerInGameName: playerInGameName,
          localInGameName: localInGameName);

  /// Launch a player search UI. Only available on Android. Throws an
  /// [UnimplementedError] on other platforms.
  static Future<PlayerData?> searchForPlayer() => Friends.searchForPlayer();

  /// Launch the friend request UI. Only available on iOS/MacOS. Throws an
  /// [UnimplementedError] on other platforms.
  static Future<String?> sendFriendRequest() => Friends.sendFriendRequest();
}
