import 'package:games_services_platform_interface/models.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'src/game_services_platform_impl.dart';

const _unimplementedMessage = "not implemented.";

abstract class GamesServicesPlatform extends PlatformInterface {
  /// Constructs a GamesServicesPlatform.
  GamesServicesPlatform() : super(token: _token);

  static final Object _token = Object();

  static GamesServicesPlatform _instance = MethodChannelGamesServices();

  /// The default instance of [GamesServicesPlatform] to use.
  /// Defaults to [MethodChannelGamesServices].
  static GamesServicesPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [GamesServicesPlatform] when they register themselves.
  static set instance(GamesServicesPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Stream of the currently authenticated player. If not null, the player
  /// is signed in & games_services functionality is available.
  Stream<PlayerData?> get player => throw UnimplementedError();

  /// Increment an [achievement].
  /// [Achievement] takes two parameters:
  /// [androidID] the achievement ID for Google Play Games.
  /// [steps] If the achievement is of the incremental type
  /// you can use this method to increment the steps.
  /// * only for Android (see https://developers.google.com/games/services/android/achievements#unlocking_achievements).
  Future<String?> increment({required Achievement achievement}) =>
      throw UnimplementedError(_unimplementedMessage);

  /// Unlock an [achievement].
  /// [Achievement] takes three parameters:
  /// [androidID] the achievement ID for Google Play Games.
  /// [iOSID] the achievement ID for Game Center.
  /// [percentComplete] the completion percentage of the achievement,
  /// this parameter is optional on iOS/macOS.
  Future<String?> unlock({required Achievement achievement}) =>
      throw UnimplementedError(_unimplementedMessage);

  /// Submit a [score] to a specific leaderboard.
  /// [Score] takes three parameters:
  /// [androidLeaderboardID] the leaderboard ID for Google Play Games.
  /// [iOSLeaderboardID] the leaderboard ID for Game Center.
  /// [value] the score.
  Future<String?> submitScore({required Score score}) =>
      throw UnimplementedError(_unimplementedMessage);

  /// Open the device's default achievements screen.
  Future<String?> showAchievements() =>
      throw UnimplementedError(_unimplementedMessage);

  /// Open the device's default leaderboards screen. If a leaderboard ID is provided,
  /// it will display the specific leaderboard, otherwise it will show the list of all leaderboards.
  Future<String?> showLeaderboards({
    String iOSLeaderboardID = "",
    String androidLeaderboardID = "",
  }) =>
      throw UnimplementedError(_unimplementedMessage);

  /// Get achievements as json data.
  /// To show the device's default achievements screen use [showAchievements].
  Future<String?> loadAchievements({
    bool forceRefresh = false,
    bool ignoreImages = false,
  }) =>
      throw UnimplementedError(_unimplementedMessage);

  /// Reset achievements.
  Future<String?> resetAchievements() =>
      throw UnimplementedError(_unimplementedMessage);

  /// Get leaderboard scores as json data.
  /// To show the device's default leaderboards screen use [showLeaderboards].
  Future<String?> loadLeaderboardScores({
    String iOSLeaderboardID = "",
    String androidLeaderboardID = "",
    bool playerCentered = false,
    required PlayerScope scope,
    required TimeScope timeScope,
    required int maxResults,
    bool forceRefresh = false,
  }) =>
      throw UnimplementedError(_unimplementedMessage);

  /// Get leaderboard scores as a json data for current player.
  /// To show the prebuilt system screen use [showLeaderboards].
  Future<String?> getPlayerScoreObject({
    String iOSLeaderboardID = "",
    String androidLeaderboardID = "",
    required PlayerScope scope,
    required TimeScope timeScope,
  }) =>
      throw UnimplementedError(_unimplementedMessage);

  /// Load the previous occurrence of the player's score from a leaderboard.
  /// Returns the score data that precedes the player's current best score.
  /// [iOSLeaderboardID] the leaderboard ID for Game Center.
  /// [androidLeaderboardID] the leaderboard ID for Google Play Games.
  /// [timeScope] the time scope for the leaderboard.
  Future<String?> loadPreviousOccurrence({
    String iOSLeaderboardID = "",
    String androidLeaderboardID = "",
    required TimeScope timeScope,
  }) =>
      throw UnimplementedError(_unimplementedMessage);

  /// Get the current player's score for a specific leaderboard.
  Future<int?> getPlayerScore({
    String iOSLeaderboardID = "",
    String androidLeaderboardID = "",
  }) =>
      throw UnimplementedError(_unimplementedMessage);

  /// Sign the user into Game Center or Google Play Games. This must be called before
  /// taking any action (such as submitting a score or unlocking an achievement).
  Future<String?> signIn() => throw UnimplementedError(_unimplementedMessage);

  /// Retrieve Google Play Games [server_auth_code] to be used by an auth provider,
  /// such as Firebase, to authenticate the user. [null] on other platforms.
  Future<String?> getAuthCode(
    String clientID, {
    bool forceRefreshToken = false,
  }) =>
      throw UnimplementedError(_unimplementedMessage);

  /// Show the Game Center Access Point for the current player.
  Future<String?> showAccessPoint(AccessPointLocation location) =>
      throw UnimplementedError(_unimplementedMessage);

  /// Hide the Game Center Access Point.
  Future<String?> hideAccessPoint() =>
      throw UnimplementedError(_unimplementedMessage);

  /// Get the current player's hi-res profile image as a base64 encoded String.
  Future<String?> getPlayerHiResImage() =>
      throw UnimplementedError(_unimplementedMessage);

  /// Save game with [data] and a unique [name].
  /// The [name] must be between 1 and 100 non-URL-reserved characters (a-z, A-Z, 0-9, or the symbols "-", ".", "_", or "~").
  Future<String?> saveGame({required String data, required String name}) =>
      throw UnimplementedError(_unimplementedMessage);

  /// Load game with [name].
  Future<String?> loadGame({required String name}) =>
      throw UnimplementedError(_unimplementedMessage);

  /// Delete game with [name].
  Future<String?> deleteGame({required String name}) =>
      throw UnimplementedError(_unimplementedMessage);

  /// Get all saved games.
  Future<String?> getSavedGames({bool forceRefresh = false}) =>
      throw UnimplementedError(_unimplementedMessage);

  /// Fetch identity verification signature from Game Center (iOS and MacOS).
  /// Returns identity verification data including public key URL, signature, salt, and timestamp.
  /// Only available on iOS and MacOS, returns null on other platforms.
  Future<IdentityVerificationSignature?> fetchIdentityVerificationSignature() =>
      throw UnimplementedError(_unimplementedMessage);

  /// Open the default friends list screen on iOS/MacOS. Does nothing on Android.
  Future<String?> showFriendsList() =>
      throw UnimplementedError(_unimplementedMessage);

  /// Check for access to the player's friends list. Useful for presenting
  /// differing UIs based on access. Calling [loadFriends] automatically request
  /// access if needed and will throw an error if access is denied.
  Future<FriendsAccess> get friendsAccess =>
      throw UnimplementedError(_unimplementedMessage);

  /// Get the current player's friends list.
  ///
  /// The `forceRefresh` argument will invalidate the cache on Android, fetching
  /// the latest results. It has no affect on iOS.
  Future<String?> loadFriends({
    required int pageSize,
    bool forceRefresh = false,
  }) =>
      throw UnimplementedError(_unimplementedMessage);

  /// View a player's profile.
  ///
  /// On Android, this presents a player comparison profile
  /// between the current player and the player identified by the `playerID`. The
  /// `playerInGameName` and `localInGameName` will be presented on this screen to
  /// allow in game nicknames to carry over to Google Play Games, and any friend
  /// request sent from this view will include the `localInGameName`.
  Future<String?> viewPlayerProfile({
    required String playerID,
    String? playerInGameName,
    String? localInGameName,
  }) =>
      throw UnimplementedError(_unimplementedMessage);

  /// Launch a player search UI. Only available on Android. Throws an
  /// [UnimplementedError] on other platforms.
  Future<PlayerData?> searchForPlayer() =>
      throw UnimplementedError(_unimplementedMessage);

  /// Launch the friend request UI. Only available on iOS/MacOS. Throws an
  /// [UnimplementedError] on other platforms.
  Future<String?> sendFriendRequest() =>
      throw UnimplementedError(_unimplementedMessage);
}
