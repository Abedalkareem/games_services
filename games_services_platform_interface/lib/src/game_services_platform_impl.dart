import 'dart:async';

import 'package:flutter/services.dart';

import '../game_services_platform_interface.dart';
import 'models/access_point_location.dart';
import 'models/achievement.dart';
import 'models/leaderboard_scope.dart';
import 'models/leaderboard_time_scope.dart';
import 'models/score.dart';
import 'util/device.dart';

const MethodChannel _channel = MethodChannel("games_services");

class MethodChannelGamesServices extends GamesServicesPlatform {
  @override
  Future<String?> unlock({required Achievement achievement}) async {
    return await _channel.invokeMethod("unlock", {
      "achievementID": achievement.id,
      "percentComplete": achievement.percentComplete,
      "showsCompletionBanner": achievement.showsCompletionBanner
    });
  }

  @override
  Future<String?> submitScore({required Score score}) async {
    return await _channel.invokeMethod("submitScore",
        {"leaderboardID": score.leaderboardID, "value": score.value, "token": score.token});
  }

  @override
  Future<String?> increment({required Achievement achievement}) async {
    return await _channel.invokeMethod("increment", {
      "achievementID": achievement.id,
      "steps": achievement.steps,
    });
  }

  @override
  Future<String?> showAchievements() async {
    return await _channel.invokeMethod("showAchievements");
  }

  @override
  Future<String?> showLeaderboards({iOSLeaderboardID = "", androidLeaderboardID = ""}) async {
    return await _channel.invokeMethod("showLeaderboards",
        {"leaderboardID": Device.isPlatformAndroid ? androidLeaderboardID : iOSLeaderboardID});
  }

  @override
  Future<String?> loadAchievements() async {
    return await _channel.invokeMethod("loadAchievements");
  }

  @override
  Future<String?> resetAchievements() async {
    return await _channel.invokeMethod("resetAchievements");
  }

  @override
  Future<String?> loadLeaderboardScores(
      {iOSLeaderboardID = "",
      androidLeaderboardID = "",
      bool playerCentered = false,
      required PlayerScope scope,
      required TimeScope timeScope,
      required int maxResults}) async {
    return await _channel.invokeMethod("loadLeaderboardScores", {
      "leaderboardID": Device.isPlatformAndroid ? androidLeaderboardID : iOSLeaderboardID,
      "playerCentered": playerCentered,
      "leaderboardCollection": scope.value,
      "span": timeScope.value,
      "maxResults": maxResults
    });
  }

  @override
  Future<int?> getPlayerScore({iOSLeaderboardID = "", androidLeaderboardID = ""}) async {
    return await _channel.invokeMethod("getPlayerScore",
        {"leaderboardID": Device.isPlatformAndroid ? androidLeaderboardID : iOSLeaderboardID});
  }

  @override
  Future<String?> getPlayerScoreObject(
      {iOSLeaderboardID = "",
      androidLeaderboardID = "",
      required PlayerScope scope,
      required TimeScope timeScope}) async {
    return await _channel.invokeMethod("getPlayerScoreObject", {
      "leaderboardID": Device.isPlatformAndroid ? androidLeaderboardID : iOSLeaderboardID,
      "leaderboardCollection": scope.value,
      "span": timeScope.value
    });
  }

  @override
  Future<String?> signIn() async {
    return await _channel.invokeMethod("signIn");
  }

  @override
  Future<bool?> get isSignedIn => _channel.invokeMethod("isSignedIn");

  @override
  Future<String?> getAuthCode(String clientID, {bool forceRefreshToken = false}) =>
      Device.isPlatformAndroid
          ? _channel.invokeMethod(
              "getAuthCode", {"clientID": clientID, "forceRefreshToken": forceRefreshToken})
          : Future.value(null);

  @override
  Future<bool?> get playerIsUnderage async {
    if (Device.isPlatformAndroid) {
      return Future.value(false);
    }
    return await _channel.invokeMethod("playerIsUnderage");
  }

  @override
  Future<bool?> get playerIsMultiplayerGamingRestricted async {
    if (Device.isPlatformAndroid) {
      return Future.value(false);
    }
    return await _channel.invokeMethod("playerIsMultiplayerGamingRestricted");
  }

  @override
  Future<bool?> get playerIsPersonalizedCommunicationRestricted async {
    if (Device.isPlatformAndroid) {
      return Future.value(false);
    }
    return await _channel.invokeMethod("playerIsPersonalizedCommunicationRestricted");
  }

  @override
  Future<String?> showAccessPoint(AccessPointLocation location) async {
    return await _channel
        .invokeMethod("showAccessPoint", {"location": location.toString().split(".").last});
  }

  @override
  Future<String?> hideAccessPoint() async {
    return await _channel.invokeMethod("hideAccessPoint");
  }

  @override
  Future<String?> getPlayerID() async {
    return await _channel.invokeMethod("getPlayerID");
  }

  @override
  Future<String?> getPlayerName() async {
    return await _channel.invokeMethod("getPlayerName");
  }

  @override
  Future<String?> getPlayerIconImage() async {
    return await _channel.invokeMethod("getPlayerIconImage");
  }

  @override
  Future<String?> getPlayerHiResImage() async {
    return await _channel.invokeMethod("getPlayerHiResImage");
  }

  @override
  Future<String?> saveGame({required String data, required String name}) async {
    return await _channel.invokeMethod("saveGame", {"data": data, "name": name});
  }

  @override
  Future<String?> loadGame({required String name}) async {
    return await _channel.invokeMethod("loadGame", {"name": name});
  }

  @override
  Future<String?> getSavedGames() async {
    return await _channel.invokeMethod("getSavedGames");
  }

  @override
  Future<String?> deleteGame({required String name}) async {
    return await _channel.invokeMethod("deleteGame", {"name": name});
  }
}
