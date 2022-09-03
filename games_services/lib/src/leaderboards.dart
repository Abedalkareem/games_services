import 'dart:convert';

import 'package:games_services/src/models/leaderboard_score_data.dart';
import 'package:games_services_platform_interface/game_services_platform_interface.dart';
import 'package:games_services_platform_interface/models.dart';

abstract class Leaderboards {
  /// It will open the leaderboards screen.
  static Future<String?> showLeaderboards(
      {iOSLeaderboardID = "", androidLeaderboardID = ""}) async {
    return await GamesServicesPlatform.instance.showLeaderboards(
        iOSLeaderboardID: iOSLeaderboardID,
        androidLeaderboardID: androidLeaderboardID);
  }

  /// Get leaderboard scores as a list. Use this to build your own custom UI.
  /// To show the prebuilt system screen use [showLeaderboards].
  static Future<List<LeaderboardScoreData>?> loadLeaderboardScores(
      {iOSLeaderboardID = "",
      androidLeaderboardID = "",
      required PlayerScope scope,
      required TimeScope timeScope,
      required int maxResults}) async {
    final response = await GamesServicesPlatform.instance.loadLeaderboardScores(
        androidLeaderboardID: androidLeaderboardID,
        iOSLeaderboardID: iOSLeaderboardID,
        scope: scope,
        timeScope: timeScope,
        maxResults: maxResults);
    if (response != null) {
      Iterable items = json.decode(response) as List;
      return List<LeaderboardScoreData>.from(
          items.map((model) => LeaderboardScoreData.fromJson(model)).toList());
    }
    return null;
  }

  /// Submit a [score] to specific leader board.
  /// [Score] takes three parameters:
  /// [androidLeaderboardID] the leader board id that you want to send the score for in case of android.
  /// [iOSLeaderboardID] the leader board id that you want to send the score for in case of iOS.
  /// [value] the score.
  static Future<String?> submitScore({required Score score}) async {
    return await GamesServicesPlatform.instance.submitScore(score: score);
  }
}
