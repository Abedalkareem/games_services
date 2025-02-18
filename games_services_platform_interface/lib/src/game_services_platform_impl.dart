import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import '../game_services_platform_interface.dart';
import 'models/access_point_location.dart';
import 'models/achievement.dart';
import 'models/leaderboard_scope.dart';
import 'models/leaderboard_time_scope.dart';
import 'models/player.dart';
import 'models/score.dart';
import 'util/device.dart';

const MethodChannel _methodChannel = MethodChannel("games_services");
const EventChannel _playerChannel = EventChannel("games_services.player");

class MethodChannelGamesServices extends GamesServicesPlatform {
  MethodChannelGamesServices() : super() {
    // broadcast stream helps reduce code while remaining backwards compatible
    // also allows the app to listen to the stream in multiple places without
    _streamController = StreamController.broadcast(
      onListen: () {
        // subscribe to the platform event channel when first listener added
        _sub ??= _playerChannel
            .receiveBroadcastStream()
            .map((json) =>
                json == null ? null : PlayerData.fromJson(jsonDecode(json)))
            .listen((player) {
          _player = player;
          _streamController.add(_player);
        }, onError: (error) => _streamController.add(null));
      },
      onCancel: () {
        // cancel sub to platform event channel when last listener removed
        // new listeners added after this will recreate the subscription
        _sub?.cancel();
      },
    );
  }

  late final StreamController<PlayerData?> _streamController;
  StreamSubscription<PlayerData?>? _sub;

  // stored to be added to stream for every new listener as
  // broadcast streams lose data
  PlayerData? _player;

  @override
  Stream<PlayerData?> get player {
    // to maintain backwards compatibility, add latest player when
    // listened to by plugin methods. also guarantees synced player data
    // while listening for the user in multiple places throughout the app
    Future(() => _streamController.add(_player));
    return _streamController.stream;
  }

  @override
  Future<String?> unlock({required Achievement achievement}) async {
    return await _methodChannel.invokeMethod("unlock", {
      "achievementID": achievement.id,
      "percentComplete": achievement.percentComplete,
      "showsCompletionBanner": achievement.showsCompletionBanner
    });
  }

  @override
  Future<String?> submitScore({required Score score}) async {
    return await _methodChannel.invokeMethod("submitScore", {
      "leaderboardID": score.leaderboardID,
      "value": score.value,
      "token": score.token
    });
  }

  @override
  Future<String?> increment({required Achievement achievement}) async {
    return await _methodChannel.invokeMethod("increment", {
      "achievementID": achievement.id,
      "steps": achievement.steps,
    });
  }

  @override
  Future<String?> showAchievements() async {
    return await _methodChannel.invokeMethod("showAchievements");
  }

  @override
  Future<String?> showLeaderboards(
      {iOSLeaderboardID = "", androidLeaderboardID = ""}) async {
    return await _methodChannel.invokeMethod("showLeaderboards", {
      "leaderboardID":
          Device.isPlatformAndroid ? androidLeaderboardID : iOSLeaderboardID
    });
  }

  @override
  Future<String?> loadAchievements({bool forceRefresh = false}) async {
    return await _methodChannel
        .invokeMethod("loadAchievements", {"forceRefresh": forceRefresh});
  }

  @override
  Future<String?> resetAchievements() async {
    return await _methodChannel.invokeMethod("resetAchievements");
  }

  @override
  Future<String?> loadLeaderboardScores(
      {iOSLeaderboardID = "",
      androidLeaderboardID = "",
      bool playerCentered = false,
      required PlayerScope scope,
      required TimeScope timeScope,
      required int maxResults,
      bool forceRefresh = false}) async {
    return await _methodChannel.invokeMethod("loadLeaderboardScores", {
      "leaderboardID":
          Device.isPlatformAndroid ? androidLeaderboardID : iOSLeaderboardID,
      "playerCentered": playerCentered,
      "leaderboardCollection": scope.value,
      "span": timeScope.value,
      "maxResults": maxResults,
      "forceRefresh": forceRefresh
    });
  }

  @override
  Future<int?> getPlayerScore(
      {iOSLeaderboardID = "", androidLeaderboardID = ""}) async {
    return await _methodChannel.invokeMethod("getPlayerScore", {
      "leaderboardID":
          Device.isPlatformAndroid ? androidLeaderboardID : iOSLeaderboardID
    });
  }

  @override
  Future<String?> getPlayerScoreObject(
      {iOSLeaderboardID = "",
      androidLeaderboardID = "",
      required PlayerScope scope,
      required TimeScope timeScope}) async {
    return await _methodChannel.invokeMethod("getPlayerScoreObject", {
      "leaderboardID":
          Device.isPlatformAndroid ? androidLeaderboardID : iOSLeaderboardID,
      "leaderboardCollection": scope.value,
      "span": timeScope.value
    });
  }

  @override
  Future<String?> signIn() async {
    return await _methodChannel.invokeMethod("signIn");
  }

  @override
  Future<String?> getAuthCode(String clientID,
          {bool forceRefreshToken = false}) =>
      Device.isPlatformAndroid
          ? _methodChannel.invokeMethod("getAuthCode",
              {"clientID": clientID, "forceRefreshToken": forceRefreshToken})
          : Future.value(null);

  @override
  Future<String?> showAccessPoint(AccessPointLocation location) async {
    return await _methodChannel.invokeMethod(
        "showAccessPoint", {"location": location.toString().split(".").last});
  }

  @override
  Future<String?> hideAccessPoint() async {
    return await _methodChannel.invokeMethod("hideAccessPoint");
  }

  @override
  Future<String?> getPlayerHiResImage() async {
    return await _methodChannel.invokeMethod("getPlayerHiResImage");
  }

  @override
  Future<String?> saveGame({required String data, required String name}) async {
    return await _methodChannel
        .invokeMethod("saveGame", {"data": data, "name": name});
  }

  @override
  Future<String?> loadGame({required String name}) async {
    return await _methodChannel.invokeMethod("loadGame", {"name": name});
  }

  @override
  Future<String?> getSavedGames({bool forceRefresh = false}) async {
    return await _methodChannel
        .invokeMethod("getSavedGames", {"forceRefresh": forceRefresh});
  }

  @override
  Future<String?> deleteGame({required String name}) async {
    return await _methodChannel.invokeMethod("deleteGame", {"name": name});
  }
}
