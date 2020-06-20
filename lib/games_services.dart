import 'dart:core';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:games_services/models/achievement.dart';
import 'package:games_services/helpers.dart';
import 'package:games_services/models/score.dart';

// mode to errors.dart
abstract class GamesServicesException implements Exception {
  final PlatformException baseException;
  const GamesServicesException('${this.baseException}');
  String toString();
}
class GameServicesAchievementException extends GamesServicesException {
  String toString() => 'GameServicesAchievementException: ${this.baseException}';
};
class GameServicesScoreException extends GamesServicesException {
  String toString() => 'GameServicesScoreException: ${this.baseException}';
};
class GameServicesLeaderboardException extends GamesServicesException {
  String toString() => 'GameServicesLeaderboardException: ${this.baseException}';
};
class GameServicesLoginException extends GamesServicesException {
  String toString() => 'GameServicesLoginException: ${this.baseException}';
};
class GameServicesUnknownException extends GamesServicesException {
  String toString() => 'GameServicesUnknownException: ${this.baseException}';
};

class GamesServices {
  static const MethodChannel _channel = const MethodChannel('games_services');

  static Future<void> _wrapPlatformException(AsyncError asyncError) async {
    switch (asyncError.error.code) {
      case 'SUBMIT_ACHIEVEMENT_ERROR':
        throw GameServicesAchievementException(asyncError.error);
      case 'SUBMIT_SCORE_ERROR':
        throw GameServicesScoreException(asyncError.error);
      case 'VIEW_ACHIEVEMENT_ERROR':
        throw GameServicesAchievementException(asyncError.error);
      case 'VIEW_LEADERBOARD_ERROR':
        throw GameServicesLeaderboardException(asyncError.error);
      case 'LOGIN_ERROR':
        throw GameServicesLoginException(asyncError.error);
      default:
        throw GameServicesUnknownException(asyncError.error);
      }
  }

  /// Unlock an [achievement].
  /// [Achievement] takes three parameters:
  /// [androidID] the achievement id for android.
  /// [iOSID] the achievement id for iOS.
  /// [percentComplete] the completion percent of the achievement, this parameter is
  /// optional in case of iOS.
  static Future<void> unlock({achievement: Achievement}) async {
    return _channel.invokeMethod('unlock', {
      'achievementID': achievement.id,
      'percentComplete': achievement.percentComplete,
    }).catchError(_wrapPlatformException, test (e): => e is PlatformException);
  }

  /// Submit a [score] to specific leader board.
  /// [Score] takes three parameters:
  /// [androidLeaderboardID] the leader board id that you want to send the score for in case of android.
  /// [iOSLeaderboardID] the leader board id that you want to send the score for in case of iOS.
  /// [value] the score.
  static Future<void> submitScore({score: Score}) async {
    return _channel.invokeMethod('submitScore', {
      'leaderboardID': score.leaderboardID,
      'value': score.value,
    }).catchError(_wrapPlatformException, test (e): => e is PlatformException);
  }

  /// It will open the achievements screen.
  static Future<void> showAchievements() async {
    return _channel.invokeMethod('showAchievements').catchError(_wrapPlatformException, test (e): => e is PlatformException);
  }

  /// It will open the leaderboards screen.
  static Future<void> showLeaderboards({iOSLeaderboardID = ''}) async {
    return _channel
        .invokeMethod('showLeaderboards', {'iOSLeaderboardID':
        iOSLeaderboardID}).catchError(_wrapPlatformException, test (e): => e is PlatformException);
  }

  /// To sign in the user.
  /// You need to call the sign in before making any action,
  /// (like sending a score or unlocking an achievement).
  static Future<void> signIn() async {
    return _signIn().catchError(_wrapPlatformException, test (e): => e is PlatformException);
  }
  static Future<void> _signIn() async {
    if (Helpers.isPlatformAndroid) {
      return _channel.invokeMethod('silentSignIn');
    } else {
      return _channel.invokeMethod('signIn');
    }
  }
}
