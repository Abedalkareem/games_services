import 'dart:async';

import 'package:flutter/services.dart' show PlatformException;
import 'package:games_services/games_services.dart';
import 'package:games_services_platform_interface/game_services_platform_interface.dart';

abstract class Player {
  /// Helper for retrieving current player form the Player stream
  static Future<PlayerData?> get _currentPlayer async {
    // resuses player stream to reduce code and platform channel communciation
    final completer = Completer<PlayerData?>();
    StreamSubscription? sub;
    sub = GameAuth.player.listen((data) {
      completer.complete(data);
      sub?.cancel();
    });
    return completer.future;
  }

  static final _notAuthenticatedError = PlatformException(
    code: 'not_authenticated',
    message: 'Player not signed in.',
  );

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
    final player = await _currentPlayer;
    if (player == null) {
      throw _notAuthenticatedError;
    } else {
      return player.playerID;
    }
  }

  /// Get the current player's name.
  /// On iOS/macOS the player's alias is provided.
  static Future<String?> getPlayerName() async {
    final player = await _currentPlayer;
    if (player == null) {
      throw _notAuthenticatedError;
    } else {
      return player.displayName;
    }
  }

  /// Get the player's icon-size profile image as a base64 encoded String.
  static Future<String?> getPlayerIconImage() async {
    final player = await _currentPlayer;
    if (player == null) {
      throw _notAuthenticatedError;
    } else {
      return player.iconImage;
    }
  }

  /// Get the player's hi-res profile image as a base64 encoded String.
  static Future<String?> getPlayerHiResImage() async =>
      (await GamesServicesPlatform.instance.getPlayerHiResImage())
          ?.replaceAll("\n", "");

  /// Get the current player's score for a specific leaderboard.
  static Future<int?> getPlayerScore(
      {iOSLeaderboardID = "", androidLeaderboardID = ""}) async {
    return await GamesServicesPlatform.instance.getPlayerScore(
        iOSLeaderboardID: iOSLeaderboardID,
        androidLeaderboardID: androidLeaderboardID);
  }

  /// Check if the current player is underage (always false on Android).
  static Future<bool?> get isUnderage async {
    final player = await _currentPlayer;
    if (player == null) {
      throw _notAuthenticatedError;
    } else {
      return player.isUnderage;
    }
  }

  /// Check if the current player is restricted from joining multiplayer games (always false on Android).
  static Future<bool?> get isMultiplayerGamingRestricted async {
    final player = await _currentPlayer;
    if (player == null) {
      throw _notAuthenticatedError;
    } else {
      return player.isMultiplayerGamingRestricted;
    }
  }

  /// Check if the current player is restricted from using personalized communication on
  /// the device (always false on Android).
  static Future<bool?> get isPersonalizedCommunicationRestricted async {
    final player = await _currentPlayer;
    if (player == null) {
      throw _notAuthenticatedError;
    } else {
      return player.isPersonalizedCommunicationRestricted;
    }
  }
}
