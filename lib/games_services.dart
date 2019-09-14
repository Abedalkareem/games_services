import 'dart:async';
import 'dart:ffi';

import 'package:flutter/services.dart';

class GamesServices {
  static const MethodChannel _channel =
      const MethodChannel('games_services');

  static void unlock({achievementID: String}) async {
    await _channel.invokeMethod("unlock", [achievementID]);
  }

  static void submitScore({leaderboardID: String, score: int}) async {
    await _channel.invokeMethod("unlock", [leaderboardID, int]);
  }

  static void showAchievements() async {
    await _channel.invokeMethod("showAchievements");
  }

  static void showLeaderboards() async {
    await _channel.invokeMethod("showLeaderboards");
  }

  static void silentSignIn() async {
    await _channel.invokeMethod("silentSignIn");
  }

  static void signIn() async {
    await _channel.invokeMethod("signIn");
  }

}
