import 'dart:async';

import 'package:games_services_platform_interface/models.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'src/game_services_platform_impl.dart';

abstract class GamesServicesPlatform extends PlatformInterface {
  /// Constructs a GamesServicesPlatform.
  GamesServicesPlatform() : super(token: _token);

  static final Object _token = Object();

  static GamesServicesPlatform _instance = MethodChannelGamesServices();

  /// The default instance of [GamesServicesPlatform] to use.
  ///
  /// Defaults to [MethodChannelGamesServices].
  static GamesServicesPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [GamesServicesPlatform] when they register themselves.
  static set instance(GamesServicesPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Increment an [achievement].
  /// [Achievement] takes two parameters:
  /// [androidID] the achievement ID for Google Play Games.
  /// [steps] If the achievement is of the incremental type
  /// you can use this method to increment the steps.
  /// * only for Android (see https://developers.google.com/games/services/android/achievements#unlocking_achievements).
  Future<String?> increment({required Achievement achievement}) async {
    throw UnimplementedError("not implemented.");
  }

  /// Unlock an [achievement].
  /// [Achievement] takes three parameters:
  /// [androidID] the achievement ID for Google Play Games.
  /// [iOSID] the achievement ID for Game Center.
  /// [percentComplete] the completion percentage of the achievement,
  /// this parameter is optional on iOS/macOS.
  Future<String?> unlock({required Achievement achievement}) async {
    throw UnimplementedError("not implemented.");
  }

  /// Submit a [score] to a specific leaderboard.
  /// [Score] takes three parameters:
  /// [androidLeaderboardID] the leaderboard ID for Google Play Games.
  /// [iOSLeaderboardID] the leaderboard ID for Game Center.
  /// [value] the score.
  Future<String?> submitScore({required Score score}) async {
    throw UnimplementedError("not implemented.");
  }

  /// Open the device's default achievements screen.
  Future<String?> showAchievements() async {
    throw UnimplementedError("not implemented.");
  }

  /// Open the device's default leaderboards screen. If a leaderboard ID is provided,
  /// it will display the specific leaderboard, otherwise it will show the list of all leaderboards.
  Future<String?> showLeaderboards(
      {iOSLeaderboardID = "", androidLeaderboardID = ""}) async {
    throw UnimplementedError("not implemented.");
  }

  /// Get achievements as json data.
  /// To show the device's default achievements screen use [showAchievements].
  Future<String?> loadAchievements({bool forceRefresh = false}) async {
    throw UnimplementedError("not implemented.");
  }

  /// Reset achievements.
  Future<String?> resetAchievements() async {
    throw UnimplementedError("not implemented.");
  }

  /// Get leaderboard scores as json data.
  /// To show the device's default leaderboards screen use [showLeaderboards].
  Future<String?> loadLeaderboardScores(
      {iOSLeaderboardID = "",
      androidLeaderboardID = "",
      bool playerCentered = false,
      required PlayerScope scope,
      required TimeScope timeScope,
      required int maxResults,
      bool forceRefresh = false}) async {
    throw UnimplementedError("not implemented.");
  }

  /// Get leaderboard scores as a json data for current player.
  /// To show the prebuilt system screen use [showLeaderboards].
  Future<String?> getPlayerScoreObject(
      {iOSLeaderboardID = "",
      androidLeaderboardID = "",
      required PlayerScope scope,
      required TimeScope timeScope}) async {
    throw UnimplementedError("not implemented.");
  }

  /// Get the current player's score for a specific leaderboard.
  Future<int?> getPlayerScore(
      {iOSLeaderboardID = "", androidLeaderboardID = ""}) async {
    throw UnimplementedError("not implemented.");
  }

  /// Check if the current player is underage (always false on Android).
  Future<bool?> get playerIsUnderage =>
      throw UnimplementedError("not implemented.");

  /// Check if the current player is restricted from joining multiplayer games (always false on Android).
  Future<bool?> get playerIsMultiplayerGamingRestricted =>
      throw UnimplementedError("not implemented.");

  /// Check if the current player is restricted from using personalized communication on
  /// the device (always false on Android).
  Future<bool?> get playerIsPersonalizedCommunicationRestricted =>
      throw UnimplementedError("not implemented.");

  /// Sign the user into Game Center or Google Play Games. This must be called before
  /// taking any action (such as submitting a score or unlocking an achievement).
  Future<String?> signIn() async {
    throw UnimplementedError("not implemented.");
  }

  /// Check to see if the user is currently signed into Game Center or Google Play Games.
  Future<bool?> get isSignedIn => throw UnimplementedError("not implemented.");

  /// Retrieve Google Play Games [server_auth_code] to be used by an auth provider,
  /// such as Firebase, to authenticate the user. [null] on other platforms.
  Future<String?> getAuthCode(String clientID) =>
      throw UnimplementedError("not implemented.");

  /// Show the Game Center Access Point for the current player.
  Future<String?> showAccessPoint(AccessPointLocation location) async {
    throw UnimplementedError("not implemented.");
  }

  /// Hide the Game Center Access Point.
  Future<String?> hideAccessPoint() async {
    throw UnimplementedError("not implemented.");
  }

  /// Get the current player's ID.
  /// On iOS/macOS the player ID is unique for your game but not other games.
  Future<String?> getPlayerID() async {
    throw UnimplementedError("not implemented.");
  }

  /// Get the current player's name.
  /// On iOS/macOS the player's alias is provided.
  Future<String?> getPlayerName() async {
    throw UnimplementedError("not implemented.");
  }

  /// Get the current player's icon-size profile image as a base64 encoded String.
  Future<String?> getPlayerIconImage() async {
    throw UnimplementedError("not implemented");
  }

  /// Get the current player's hi-res profile image as a base64 encoded String.
  Future<String?> getPlayerHiResImage() async {
    throw UnimplementedError("not implemented.");
  }

  /// Save game with [data] and a unique [name].
  /// The [name] must be between 1 and 100 non-URL-reserved characters (a-z, A-Z, 0-9, or the symbols "-", ".", "_", or "~").
  Future<String?> saveGame({required String data, required String name}) async {
    throw UnimplementedError("not implemented.");
  }

  /// Load game with [name].
  Future<String?> loadGame({required String name}) async {
    throw UnimplementedError("not implemented.");
  }

  /// Delete game with [name].
  Future<String?> deleteGame({required String name}) async {
    throw UnimplementedError("not implemented.");
  }

  /// Get all saved games.
  Future<String?> getSavedGames() async {
    throw UnimplementedError("not implemented.");
  }
}
