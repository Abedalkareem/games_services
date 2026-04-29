import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import '../game_services_platform_interface.dart';
import 'models/access_point_location.dart';
import 'models/achievement.dart';
import 'models/identity_verification_signature.dart';
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
        // subscribe to the platform event channel when first listener is added
        _sub ??= _playerChannel
            .receiveBroadcastStream()
            .map((json) =>
                json == null ? null : PlayerData.fromJson(jsonDecode(json)))
            .listen((player) {
          _player = player;
          _streamController.add(_player);
        }, onError: (error) {
          _player = null;
          _streamController.add(_player);
        });
      },
      onCancel: () {
        // cancel sub to platform event channel when last listener removed
        // new listeners added after this will recreate the subscription
        _sub?.cancel();
        _sub = null;
      },
    );
    _streamView = _PlayerStreamView(_streamController.stream.distinct(),
        () => _streamController.add(_player));
  }

  late final StreamController<PlayerData?> _streamController;
  late final _PlayerStreamView _streamView;
  StreamSubscription<PlayerData?>? _sub;

  // cache player data to send when a new listener is added
  PlayerData? _player;

  @override
  Stream<PlayerData?> get player => _streamView;

  @override
  Future<String?> unlock({required Achievement achievement}) async {
    return await _methodChannel.invokeMethod("unlock", {
      "achievementID": achievement.id,
      "percentComplete": achievement.percentComplete,
      "showsCompletionBanner": achievement.showsCompletionBanner,
    });
  }

  @override
  Future<String?> submitScore({required Score score}) async {
    return await _methodChannel.invokeMethod("submitScore", {
      "leaderboardID": score.leaderboardID,
      "value": score.value,
      "token": score.token,
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
  Future<String?> showLeaderboards({
    String iOSLeaderboardID = "",
    String androidLeaderboardID = "",
  }) async {
    return await _methodChannel.invokeMethod("showLeaderboards", {
      "leaderboardID":
          Device.isPlatformAndroid ? androidLeaderboardID : iOSLeaderboardID
    });
  }

  @override
  Future<String?> loadAchievements({
    bool forceRefresh = false,
    bool ignoreImages = false,
  }) async {
    return await _methodChannel.invokeMethod("loadAchievements",
        {"forceRefresh": forceRefresh, "ignoreImages": ignoreImages});
  }

  @override
  Future<String?> resetAchievements() async {
    return await _methodChannel.invokeMethod("resetAchievements");
  }

  @override
  Future<String?> loadLeaderboardScores({
    required PlayerScope scope,
    required TimeScope timeScope,
    required int maxResults,
    String iOSLeaderboardID = "",
    String androidLeaderboardID = "",
    bool playerCentered = false,
    bool forceRefresh = false,
  }) async {
    return await _methodChannel.invokeMethod("loadLeaderboardScores", {
      "leaderboardID":
          Device.isPlatformAndroid ? androidLeaderboardID : iOSLeaderboardID,
      "playerCentered": playerCentered,
      "leaderboardCollection": scope.value,
      "span": timeScope.value,
      "maxResults": maxResults,
      "forceRefresh": forceRefresh,
    });
  }

  @override
  Future<int?> getPlayerScore(
      {String iOSLeaderboardID = "", String androidLeaderboardID = ""}) async {
    return await _methodChannel.invokeMethod("getPlayerScore", {
      "leaderboardID":
          Device.isPlatformAndroid ? androidLeaderboardID : iOSLeaderboardID
    });
  }

  @override
  Future<String?> getPlayerScoreObject({
    String iOSLeaderboardID = "",
    String androidLeaderboardID = "",
    required PlayerScope scope,
    required TimeScope timeScope,
  }) async {
    return await _methodChannel.invokeMethod("getPlayerScoreObject", {
      "leaderboardID":
          Device.isPlatformAndroid ? androidLeaderboardID : iOSLeaderboardID,
      "leaderboardCollection": scope.value,
      "span": timeScope.value,
    });
  }

  @override
  Future<String?> loadPreviousOccurrence({
    String iOSLeaderboardID = "",
    String androidLeaderboardID = "",
    required TimeScope timeScope,
  }) async {
    return await _methodChannel.invokeMethod("loadPreviousOccurrence", {
      "leaderboardID":
          Device.isPlatformAndroid ? androidLeaderboardID : iOSLeaderboardID,
      "span": timeScope.value,
    });
  }

  @override
  Future<String?> signIn() async {
    return await _methodChannel.invokeMethod("signIn");
  }

  @override
  Future<String?> getAuthCode(
    String clientID, {
    bool forceRefreshToken = false,
  }) =>
      Device.isPlatformAndroid
          ? _methodChannel.invokeMethod("getAuthCode", {
              "clientID": clientID,
              "forceRefreshToken": forceRefreshToken,
            })
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

  @override
  Future<IdentityVerificationSignature?>
      fetchIdentityVerificationSignature() async {
    if (!Device.isPlatformIOS && !Device.isPlatformMacOS) {
      return null;
    }
    final result = await _methodChannel.invokeMethod<Map<Object?, Object?>?>(
        "fetchIdentityVerificationSignature");
    if (result == null) {
      return null;
    }
    return IdentityVerificationSignature.fromJson(
        result.cast<String, dynamic>());
  }
}

class _PlayerStreamView extends StreamView<PlayerData?> {
  _PlayerStreamView(Stream<PlayerData?> stream, this.emit) : super(stream);

  VoidCallback emit;

  @override
  StreamSubscription<PlayerData?> listen(
      void Function(PlayerData? value)? onData,
      {Function? onError,
      void Function()? onDone,
      bool? cancelOnError}) {
    final sub = super.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
    emit();
    return sub;
  }
}
