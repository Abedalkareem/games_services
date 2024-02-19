import 'dart:convert';

import 'package:games_services/src/models/leaderboard_score_data.dart';
import 'package:games_services_platform_interface/game_services_platform_interface.dart';
import 'package:games_services_platform_interface/models.dart';

abstract class Leaderboards {
  /// Open the device's default leaderboards screen. If a leaderboard ID is provided,
  /// it will display the specific leaderboard, otherwise it will show the list of all leaderboards.
  static Future<String?> showLeaderboards(
      {iOSLeaderboardID = "", androidLeaderboardID = ""}) async {
    return await GamesServicesPlatform.instance.showLeaderboards(
        iOSLeaderboardID: iOSLeaderboardID,
        androidLeaderboardID: androidLeaderboardID);
  }

  /// Get leaderboard scores as a list. Use this to build a custom UI.
  /// To show the device's default leaderboards screen use [showLeaderboards].
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

  /// Get leaderboard scores as a list for current player
  static Future<LeaderboardScoreData>? getPlayerScoreObject(
      {iOSLeaderboardID = "",
      androidLeaderboardID = "",
      required PlayerScope scope,
      required TimeScope timeScope}) async {
    final String? response = await GamesServicesPlatform.instance.getPlayerScoreObject(
        androidLeaderboardID: androidLeaderboardID,
        iOSLeaderboardID: iOSLeaderboardID,
        scope: scope,
        timeScope: timeScope);

    return LeaderboardScoreData.fromJson(json.decode(response ?? ""));
  }

  /// Submit a [score] to specific leaderboard.
  /// [Score] takes three parameters:
  /// [androidLeaderboardID] the leaderboard ID for Google Play Games.
  /// [iOSLeaderboardID] the leaderboard ID for Game Center.
  /// [value] the score.
  static Future<String?> submitScore({required Score score}) async {
    return await GamesServicesPlatform.instance.submitScore(score: score);
  }
}
