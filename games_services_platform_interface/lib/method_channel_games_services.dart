import 'dart:async';

import 'package:flutter/services.dart';
import 'package:games_services_platform_interface/helpers.dart';
import 'package:games_services_platform_interface/models/access_point_location.dart';
import 'package:games_services_platform_interface/models/achievement.dart';
import 'package:games_services_platform_interface/models/score.dart';
import 'game_services_platform_interface.dart';

const MethodChannel _channel = MethodChannel("games_services");

class MethodChannelGamesServices extends GamesServicesPlatform {
  @override
  Future<String?> unlock({required Achievement achievement}) async {
    return await _channel.invokeMethod("unlock", {
      "achievementID": achievement.id,
      "percentComplete": achievement.percentComplete,
    });
  }

  @override
  Future<String?> submitScore({required Score score}) async {
    return await _channel.invokeMethod("submitScore", {
      "leaderboardID": score.leaderboardID,
      "value": score.value,
    });
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
  Future<String?> showLeaderboards(
      {iOSLeaderboardID = "", androidLeaderboardID = ""}) async {
    return await _channel.invokeMethod("showLeaderboards", {
      "leaderboardID":
          Helpers.isPlatformAndroid ? androidLeaderboardID : iOSLeaderboardID
    });
  }

  @override
  Future<int?> getPlayerScore(
      {iOSLeaderboardID = "", androidLeaderboardID = ""}) async {
    return await _channel.invokeMethod("getPlayerScore", {
      "leaderboardID":
          Helpers.isPlatformAndroid ? androidLeaderboardID : iOSLeaderboardID
    });
  }

  @override
  Future<String?> signIn() async {
    if (Helpers.isPlatformAndroid) {
      return await _channel.invokeMethod("silentSignIn");
    } else {
      return await _channel.invokeMethod("signIn");
    }
  }

  @override
  Future<bool?> get isSignedIn => _channel.invokeMethod("isSignedIn");

  @override
  Future<String?> signOut() async {
    return await _channel.invokeMethod("signOut");
  }

  @override
  Future<String?> showAccessPoint(AccessPointLocation location) async {
    return await _channel.invokeMethod(
        "showAccessPoint", {"location": location.toString().split(".").last});
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
  Future<String?> saveGame({required String data, required String name}) async {
    return await _channel
        .invokeMethod("saveGame", {"data": data, "name": name});
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
