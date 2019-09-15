import 'dart:async';
import 'dart:ffi';

import 'package:flutter/services.dart';

class GamesServices {
  static const MethodChannel _channel =
      const MethodChannel('games_services');

  static void unlock({achievementID: String, percentComplete: Double}) async {
    await _channel.invokeMethod("unlock", [achievementID, percentComplete]);
  }

  static void submitScore({leaderboardID: String, score: int}) async {
    await _channel.invokeMethod("submitScore", [leaderboardID, score]);
  }

  static void showAchievements() async {
    await _channel.invokeMethod("showAchievements");
  }

  static void showLeaderboards({leaderboardID: String}) async {
    await _channel.invokeMethod("showLeaderboards", leaderboardID);
  }

  static void silentSignIn() async {
    await _channel.invokeMethod("silentSignIn");
  }

  static void signIn() async {
    await _channel.invokeMethod("signIn");
  }

}
