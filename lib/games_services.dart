import 'dart:async';
import 'package:flutter/services.dart';
import 'package:games_services/models/achievement.dart';
import 'package:games_services/helpers.dart';
import 'package:games_services/models/score.dart';

class GamesServices {
  static const MethodChannel _channel = const MethodChannel('games_services');

  /// Unlock an [achievement].
  /// [Achievement] takes three parameters:
  /// [androidID] the achievement id for android.
  /// [iOSID] the achievement id for iOS.
  /// [percentComplete] the completion percent of the achievement, this parameter is
  /// optional in case of iOS.
  static Future<String> unlock({achievement: Achievement}) async {
    return await _channel.invokeMethod("unlock", {
      "achievementID": achievement.id,
      "percentComplete": achievement.percentComplete,
    });
  }

  /// Submit a [score] to specific leader board.
  /// [Score] takes three parameters:
  /// [androidLeaderboardID] the leader board id that you want to send the score for in case of android.
  /// [iOSLeaderboardID] the leader board id that you want to send the score for in case of iOS.
  /// [value] the score.
  static Future<String> submitScore({score: Score}) async {
    return await _channel.invokeMethod("submitScore", {
      "leaderboardID": score.leaderboardID,
      "value": score.value,
    });
  }

  /// It will open the achievements screen.
  static Future<String> showAchievements() async {
    return await _channel.invokeMethod("showAchievements");
  }

  /// It will open the leaderboards screen.
  static Future<String> showLeaderboards({iOSLeaderboardID = ""}) async {
    return await _channel
        .invokeMethod("showLeaderboards", {"iOSLeaderboardID": iOSLeaderboardID});
  }


  /// JRMARKHAM
  /// Retrieve player info namely playerId and displayName
  static Future<String> getPlayerId () async {
    return await _channel.invokeMethod ("playerID");
  }

  static Future<String> getDisplayName () async {
    return await _channel.invokeMethod ("displayName");
  }


  /// To sign in the user.
  /// You need to call the sign in before making any action,
  /// (like sending a score or unlocking an achievement).
  static Future<String> signIn() async {
    if (Helpers.isPlatformAndroid) {
      return await _channel.invokeMethod("silentSignIn");
    } else {
      return await _channel.invokeMethod("signIn");
    }
  }
}
