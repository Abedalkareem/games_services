import 'dart:async';

import 'package:games_services_platform_interface/game_services_platform_interface.dart';
import 'package:games_services_platform_interface/models/access_point_location.dart';
import 'package:games_services_platform_interface/models/achievement.dart';
import 'package:games_services_platform_interface/models/score.dart';
export 'package:games_services_platform_interface/models/achievement.dart';
export 'package:games_services_platform_interface/models/score.dart';
export 'package:games_services_platform_interface/models/access_point_location.dart';

class GamesServices {
  /// Unlock an [achievement].
  /// [Achievement] takes three parameters:
  /// [androidID] the achievement id for android.
  /// [iOSID] the achievement id for iOS.
  /// [percentComplete] the completion percent of the achievement, this parameter is
  /// optional in case of iOS.
  static Future<String?> unlock({achievement: Achievement}) async {
    return await GamesServicesPlatform.instance.unlock(achievement: achievement);
  }

  /// Increment an [achievement].
  /// [Achievement] takes two parameters:
  /// [androidID] the achievement id for android.
  /// [steps] If the achievement is of the incremental type
  /// you can use this method to increment the steps.
  /// * only for Android (see https://developers.google.com/games/services/android/achievements#unlocking_achievements).
  static Future<String?> increment({achievement: Achievement}) async {
    return await GamesServicesPlatform.instance.increment(achievement: achievement);
  }

  /// Submit a [score] to specific leader board.
  /// [Score] takes three parameters:
  /// [androidLeaderboardID] the leader board id that you want to send the score for in case of android.
  /// [iOSLeaderboardID] the leader board id that you want to send the score for in case of iOS.
  /// [value] the score.
  static Future<String?> submitScore({score: Score}) async {
    return await GamesServicesPlatform.instance.submitScore(score: score);
  }

  /// It will open the achievements screen.
  static Future<String?> showAchievements() async {
    return await GamesServicesPlatform.instance.showAchievements();
  }

  /// It will open the leaderboards screen.
  static Future<String?> showLeaderboards({iOSLeaderboardID = ""}) async {
    return await GamesServicesPlatform.instance.showLeaderboards(iOSLeaderboardID: iOSLeaderboardID);
  }

  /// To sign in the user.
  /// You need to call the sign in before making any action,
  /// (like sending a score or unlocking an achievement).
  static Future<String?> signIn() async {
    return await GamesServicesPlatform.instance.signIn();
  }

  /// Show the iOS Access Point.
  static Future<String?> showAccessPoint(AccessPointLocation location) async {
    return await GamesServicesPlatform.instance.showAccessPoint(location);
  }

  /// Hide the iOS Access Point.
  static Future<String?> hideAccessPoint() async {
    return await GamesServicesPlatform.instance.hideAccessPoint();
  }
}
