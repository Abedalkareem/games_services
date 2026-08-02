import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:games_services_platform_interface/models.dart';

import '../game_services_platform_interface.dart';
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
            .map(
              (json) =>
                  json == null ? null : PlayerData.fromJson(jsonDecode(json)),
            )
            .listen(
              (player) {
                _player = player;
                _streamController.add(_player);

                // allow cached player to be used until subscription is canceled
                _isInitialized = true;
              },
              onError: (error) {
                _player = null;
                _streamController.add(_player);
                _isInitialized = true;
              },
            );
      },
      onCancel: () {
        // prevent cached player from being used on next listen
        _isInitialized = false;

        // cancel sub to platform event channel when last listener removed
        // new listeners added after this will recreate the subscription
        _sub?.cancel();
        _sub = null;
      },
    );
    _streamView = _PlayerStreamView(_streamController.stream.distinct(), () {
      // use cached PlayerData if StreamSubscription already exists
      if (_isInitialized) _streamController.add(_player);
    });
  }

  late final StreamController<PlayerData?> _streamController;
  late final _PlayerStreamView _streamView;
  StreamSubscription<PlayerData?>? _sub;

  // controls rather the cached PlayerData can be used or
  // if new data must be retrieved first, depending on if a
  // StreamSubscription already exists
  var _isInitialized = false;

  // cache player data to send when a new listener is added while
  // one or more listeners are already attached
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
  Future<String?> setSteps({required Achievement achievement}) async {
    if (!Device.isPlatformAndroid) {
      throw UnsupportedError(
        "Setting achievement steps is only supported on Android.",
      );
    }
    if (achievement.androidID.trim().isEmpty) {
      throw ArgumentError.value(
        achievement.androidID,
        "achievement.androidID",
        "The achievement ID must not be empty.",
      );
    }
    if (achievement.steps <= 0) {
      throw ArgumentError.value(
        achievement.steps,
        "achievement.steps",
        "The number of steps must be greater than zero.",
      );
    }
    return await _methodChannel.invokeMethod("setSteps", {
      "achievementID": achievement.androidID,
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
    TimeScope timeScope = TimeScope.allTime,
    PlayerScope playerScope = PlayerScope.global,
  }) async {
    return await _methodChannel.invokeMethod("showLeaderboards", {
      "leaderboardID": Device.isPlatformAndroid
          ? androidLeaderboardID
          : iOSLeaderboardID,
      "span": timeScope.value,
      "leaderboardCollection": playerScope.value,
    });
  }

  @override
  Future<String?> loadAchievements({
    bool forceRefresh = false,
    bool ignoreImages = false,
  }) async {
    return await _methodChannel.invokeMethod("loadAchievements", {
      "forceRefresh": forceRefresh,
      "ignoreImages": ignoreImages,
    });
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
      "leaderboardID": Device.isPlatformAndroid
          ? androidLeaderboardID
          : iOSLeaderboardID,
      "playerCentered": playerCentered,
      "leaderboardCollection": scope.value,
      "span": timeScope.value,
      "maxResults": maxResults,
      "forceRefresh": forceRefresh,
    });
  }

  @override
  Future<int?> getPlayerScore({
    String iOSLeaderboardID = "",
    String androidLeaderboardID = "",
  }) async {
    return await _methodChannel.invokeMethod("getPlayerScore", {
      "leaderboardID": Device.isPlatformAndroid
          ? androidLeaderboardID
          : iOSLeaderboardID,
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
      "leaderboardID": Device.isPlatformAndroid
          ? androidLeaderboardID
          : iOSLeaderboardID,
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
      "leaderboardID": Device.isPlatformAndroid
          ? androidLeaderboardID
          : iOSLeaderboardID,
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
  }) => Device.isPlatformAndroid
      ? _methodChannel.invokeMethod("getAuthCode", {
          "clientID": clientID,
          "forceRefreshToken": forceRefreshToken,
        })
      : Future.value(null);

  @override
  Future<String?> showAccessPoint(AccessPointLocation location) async {
    return await _methodChannel.invokeMethod("showAccessPoint", {
      "location": location.toString().split(".").last,
    });
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
  Future<String?> saveGame({
    required String data,
    required String name,
    Uint8List? coverImage,
    String? description,
    Duration? playedTime,
  }) async {
    return await _methodChannel.invokeMethod("saveGame", {
      "data": data,
      "name": name,
      "coverImage": coverImage,
      "description": description,
      "playedTime": playedTime?.inMilliseconds,
    });
  }

  @override
  Future<String?> loadGame({required String name}) async {
    return await _methodChannel.invokeMethod("loadGame", {"name": name});
  }

  @override
  Future<String?> showSavedGames({
    required String title,
    bool allowNew = true,
    bool allowDelete = true,
    int? maxResults,
  }) async {
    return await _methodChannel.invokeMethod("showSavedGames", {
      "title": title,
      "allowNew": allowNew,
      "allowDelete": allowDelete,
      "maxResults": maxResults,
    });
  }

  @override
  Future<String?> getSavedGames({
    bool forceRefresh = false,
    bool ignoreImages = false,
  }) async {
    return await _methodChannel.invokeMethod("getSavedGames", {
      "forceRefresh": forceRefresh,
      "ignoreImages": ignoreImages,
    });
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
      "fetchIdentityVerificationSignature",
    );
    if (result == null) {
      return null;
    }
    return IdentityVerificationSignature.fromJson(
      result.cast<String, dynamic>(),
    );
  }
}

class _PlayerStreamView extends StreamView<PlayerData?> {
  _PlayerStreamView(super.stream, this.emit);

  VoidCallback emit;

  @override
  StreamSubscription<PlayerData?> listen(
    void Function(PlayerData? value)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final sub = super.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
    emit();
    return sub;
  }
}
