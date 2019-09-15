import 'dart:async';
import 'dart:ffi';

import 'package:flutter/services.dart';

class GamesServices {
  static const MethodChannel _channel =
      const MethodChannel('games_services');

  static Future<String> unlock({achievementID: String, percentComplete: Double}) async {
    return await _channel.invokeMethod("unlock", [achievementID, percentComplete]);
  }

  static Future<String> submitScore({leaderboardID: String, score: int}) async {
    return await _channel.invokeMethod("submitScore", [leaderboardID, score]);
  }

  static Future<String> showAchievements() async {
    return await _channel.invokeMethod("showAchievements");
  }

  static Future<String> showLeaderboards({leaderboardID: String}) async {
    return await _channel.invokeMethod("showLeaderboards", leaderboardID);
  }

  static Future<String> silentSignIn() async {
    return await _channel.invokeMethod("silentSignIn");
  }

  static Future<String> signIn() async {
    return await _channel.invokeMethod("signIn");
  }

}
