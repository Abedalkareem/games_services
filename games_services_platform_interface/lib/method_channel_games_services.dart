import 'dart:async';
import 'package:flutter/services.dart';
import 'package:games_services_platform_interface/helpers.dart';
import 'package:games_services_platform_interface/models/achievement.dart';
import 'package:games_services_platform_interface/models/score.dart';
import 'game_services_platform_interface.dart';

const MethodChannel _channel = const MethodChannel('games_services_interface');

class MethodChannelGamesServices extends GamesServicesPlatform {
  static Future<String> unlock({achievement: Achievement}) async {
    return await _channel.invokeMethod("unlock", {
      "achievementID": achievement.id,
      "percentComplete": achievement.percentComplete,
    });
  }

  static Future<String> submitScore({score: Score}) async {
    return await _channel.invokeMethod("submitScore", {
      "leaderboardID": score.leaderboardID,
      "value": score.value,
    });
  }

  static Future<String> showAchievements() async {
    return await _channel.invokeMethod("showAchievements");
  }

  static Future<String> showLeaderboards({iOSLeaderboardID = ""}) async {
    return await _channel.invokeMethod(
        "showLeaderboards", {"iOSLeaderboardID": iOSLeaderboardID});
  }

  static Future<String> signIn() async {
    if (Helpers.isPlatformAndroid) {
      return await _channel.invokeMethod("silentSignIn");
    } else {
      return await _channel.invokeMethod("signIn");
    }
  }
}
