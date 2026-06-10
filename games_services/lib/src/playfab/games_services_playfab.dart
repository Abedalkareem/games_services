import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';
import 'dart:typed_data';

import 'package:games_services_platform_interface/game_services_platform_interface.dart';
import 'package:games_services_platform_interface/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'playfab_client.dart';
import 'playfab_session.dart';

/// Windows implementation of games_services backed by
/// [Microsoft PlayFab](https://learn.microsoft.com/gaming/playfab/).
///
/// Windows has no native equivalent of Game Center / Google Play Games, so this
/// implementation talks to PlayFab's REST API over HTTP. Call
/// [GamesServices.initialize] with your PlayFab title id before [signIn].
///
/// Mapping highlights (see the README "Windows (PlayFab)" section for setup):
/// * Leaderboards map to PlayFab statistics; the **iOS** leaderboard id is used
///   as the statistic name (Windows reuses the iOS identifiers).
/// * Achievements are defined in title data and progress is stored in user data.
/// * Saved games are stored as entity files with an entity-object index.
/// * Native-UI methods (`showAchievements`, `showLeaderboards`, the access
///   point) and Apple/Google-only methods return `null`.
class GamesServicesPlayFab extends GamesServicesPlatform {
  GamesServicesPlayFab({PlayFabClient? client}) : _client = client;

  /// Registered by the Flutter tool for the `windows` platform.
  static void registerWith() {
    GamesServicesPlatform.instance = GamesServicesPlayFab();
  }

  static const _deviceIdKey = "games_services.playfab.customId";
  static const _achievementsTitleDataKey = "achievements";
  static const _achievementsProgressKey = "achievements_progress";
  static const _savedGamesObjectName = "saved_games";

  PlayFabClient? _client;
  String? _customId;
  String? _displayName;

  final _session = PlayFabSession();
  final _playerController = StreamController<PlayerData?>.broadcast();

  PlayFabClient get _requireClient {
    final client = _client;
    if (client == null) {
      throw StateError(
        "games_services is not initialized. Call "
        "GamesServices.initialize(playFabTitleId: ...) before using it on Windows.",
      );
    }
    return client;
  }

  String get _ticket {
    final ticket = _session.sessionTicket;
    if (ticket == null) {
      throw StateError("Not signed in. Call signIn() first.");
    }
    return ticket;
  }

  @override
  Future<void> initialize({
    required String playFabTitleId,
    String? customId,
    String? displayName,
  }) async {
    _customId = customId;
    _displayName = displayName;
    _client = PlayFabClient(titleId: playFabTitleId);
  }

  @override
  Stream<PlayerData?> get player async* {
    // Replay the cached player to each new listener, then forward live updates.
    yield _session.player;
    yield* _playerController.stream;
  }

  // ---------------------------------------------------------------------------
  // Authentication
  // ---------------------------------------------------------------------------

  @override
  Future<String?> signIn() async {
    final client = _requireClient;
    final customId = _customId ?? await _deviceCustomId();

    final result = await client.loginWithCustomId(customId: customId);
    _session.sessionTicket = result["SessionTicket"] as String?;
    _session.playFabId = result["PlayFabId"] as String?;

    final entityToken = result["EntityToken"] as Map<String, dynamic>?;
    if (entityToken != null) {
      _session.entityToken = entityToken["EntityToken"] as String?;
      final entity = entityToken["Entity"] as Map<String, dynamic>?;
      _session.entityId = entity?["Id"] as String?;
      _session.entityType = entity?["Type"] as String?;
    }

    final profile = (result["InfoResultPayload"]
        as Map<String, dynamic>?)?["PlayerProfile"] as Map<String, dynamic>?;
    var displayName = profile?["DisplayName"] as String?;
    final avatarUrl = profile?["AvatarUrl"] as String?;

    // Apply a caller-provided display name if the account doesn't have one yet.
    if ((displayName == null || displayName.isEmpty) && _displayName != null) {
      await client.updateUserTitleDisplayName(_ticket, _displayName!);
      displayName = _displayName;
    }

    String? iconImage;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      try {
        iconImage = base64Encode(await client.downloadBytes(avatarUrl));
      } catch (_) {
        // Avatar is best-effort; ignore download/encoding failures.
      }
    }

    final player = PlayerData(
      playerID: _session.playFabId,
      displayName: displayName ?? _session.playFabId ?? "",
      iconImage: iconImage,
    );
    _session.player = player;
    _playerController.add(player);
    return _session.playFabId;
  }

  Future<String> _deviceCustomId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_deviceIdKey);
    if (id == null) {
      id = _generateGuid();
      await prefs.setString(_deviceIdKey, id);
    }
    return id;
  }

  String _generateGuid() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, "0")).join();
  }

  /// `null` on Windows: there is no Google Play Games server auth code.
  @override
  Future<String?> getAuthCode(String clientID,
          {bool forceRefreshToken = false}) async =>
      null;

  /// `null` on Windows: identity verification is a Game Center feature.
  @override
  Future<IdentityVerificationSignature?>
      fetchIdentityVerificationSignature() async => null;

  // ---------------------------------------------------------------------------
  // Player
  // ---------------------------------------------------------------------------

  @override
  Future<String?> getPlayerHiResImage() async => _session.player?.iconImage;

  /// `null` on Windows: the Game Center access point has no PlayFab equivalent.
  @override
  Future<String?> showAccessPoint(AccessPointLocation location) async => null;

  @override
  Future<String?> hideAccessPoint() async => null;

  // ---------------------------------------------------------------------------
  // Leaderboards
  // ---------------------------------------------------------------------------

  String _leaderboardId(String iOSLeaderboardID, String androidLeaderboardID) =>
      iOSLeaderboardID.isNotEmpty ? iOSLeaderboardID : androidLeaderboardID;

  @override
  Future<String?> submitScore({required Score score}) async {
    final statistic = (score.iOSLeaderboardID?.isNotEmpty ?? false)
        ? score.iOSLeaderboardID!
        : (score.androidLeaderboardID ?? "");
    await _requireClient.updatePlayerStatistics(_ticket, [
      {"StatisticName": statistic, "Value": score.value ?? 0}
    ]);
    return "success";
  }

  @override
  Future<String?> loadLeaderboardScores({
    String iOSLeaderboardID = "",
    String androidLeaderboardID = "",
    bool playerCentered = false,
    required PlayerScope scope,
    required TimeScope timeScope,
    required int maxResults,
    bool forceRefresh = false,
  }) async {
    final client = _requireClient;
    final statistic = _leaderboardId(iOSLeaderboardID, androidLeaderboardID);

    final Map<String, dynamic> data;
    if (playerCentered) {
      data = await client.getLeaderboardAroundPlayer(_ticket,
          statisticName: statistic, maxResultsCount: maxResults);
    } else if (scope == PlayerScope.friendsOnly) {
      data = await client.getFriendLeaderboard(_ticket,
          statisticName: statistic, maxResultsCount: maxResults);
    } else {
      data = await client.getLeaderboard(_ticket,
          statisticName: statistic, maxResultsCount: maxResults);
    }

    final entries = (data["Leaderboard"] as List?) ?? const [];
    return jsonEncode(entries
        .map((e) => _scoreEntryToJson(e as Map<String, dynamic>))
        .toList());
  }

  @override
  Future<int?> getPlayerScore({
    String iOSLeaderboardID = "",
    String androidLeaderboardID = "",
  }) async {
    final statistic = _leaderboardId(iOSLeaderboardID, androidLeaderboardID);
    final data = await _requireClient
        .getPlayerStatistics(_ticket, statisticNames: [statistic]);
    final stats = (data["Statistics"] as List?) ?? const [];
    for (final stat in stats) {
      if ((stat as Map)["StatisticName"] == statistic) {
        return (stat["Value"] as num).toInt();
      }
    }
    return null;
  }

  @override
  Future<String?> getPlayerScoreObject({
    String iOSLeaderboardID = "",
    String androidLeaderboardID = "",
    required PlayerScope scope,
    required TimeScope timeScope,
  }) async {
    final statistic = _leaderboardId(iOSLeaderboardID, androidLeaderboardID);
    final data = await _requireClient.getLeaderboardAroundPlayer(_ticket,
        statisticName: statistic, maxResultsCount: 1);
    final entries = (data["Leaderboard"] as List?) ?? const [];
    final entry = _findPlayerEntry(entries);
    return jsonEncode(entry != null
        ? _scoreEntryToJson(entry)
        : _emptyScoreForCurrentPlayer());
  }

  @override
  Future<String?> loadPreviousOccurrence({
    String iOSLeaderboardID = "",
    String androidLeaderboardID = "",
    required TimeScope timeScope,
  }) async {
    final client = _requireClient;
    final statistic = _leaderboardId(iOSLeaderboardID, androidLeaderboardID);

    // Resolve the current leaderboard version, then read the prior one.
    final current = await client.getLeaderboard(_ticket,
        statisticName: statistic, maxResultsCount: 1);
    final version = (current["Version"] as num?)?.toInt() ?? 0;
    if (version <= 0) return null;

    final previous = await client.getLeaderboard(_ticket,
        statisticName: statistic, maxResultsCount: 100, version: version - 1);
    final entry =
        _findPlayerEntry((previous["Leaderboard"] as List?) ?? const []);
    if (entry == null) return null;
    return jsonEncode(_scoreEntryToJson(entry));
  }

  /// `null` on Windows: PlayFab provides no native leaderboard UI.
  @override
  Future<String?> showLeaderboards({
    String iOSLeaderboardID = "",
    String androidLeaderboardID = "",
  }) async =>
      null;

  Map<String, dynamic>? _findPlayerEntry(List<dynamic> entries) {
    for (final e in entries) {
      if ((e as Map)["PlayFabId"] == _session.playFabId) {
        return e.cast<String, dynamic>();
      }
    }
    return entries.isNotEmpty
        ? (entries.first as Map).cast<String, dynamic>()
        : null;
  }

  Map<String, dynamic> _scoreEntryToJson(Map<String, dynamic> entry) {
    final profile = entry["Profile"] as Map<String, dynamic>?;
    final value = (entry["StatValue"] as num?)?.toInt() ?? 0;
    return {
      "rank": ((entry["Position"] as num?)?.toInt() ?? 0) + 1,
      "displayScore": value.toString(),
      "rawScore": value,
      "timestampMillis": 0,
      "scoreHolder": {
        "playerID": entry["PlayFabId"],
        "displayName": entry["DisplayName"] ??
            profile?["DisplayName"] ??
            entry["PlayFabId"] ??
            "",
        // PlayFab returns avatars as URLs; per-entry base64 fetches would be
        // prohibitively expensive, so the URL is surfaced as-is.
        "iconImage": profile?["AvatarUrl"],
      },
      "token": null,
    };
  }

  Map<String, dynamic> _emptyScoreForCurrentPlayer() {
    final player = _session.player;
    return {
      "rank": 0,
      "displayScore": "0",
      "rawScore": 0,
      "timestampMillis": 0,
      "scoreHolder": {
        "playerID": player?.playerID,
        "displayName": player?.displayName ?? "",
        "iconImage": player?.iconImage,
      },
      "token": null,
    };
  }

  // ---------------------------------------------------------------------------
  // Achievements (title-data definitions + user-data progress)
  // ---------------------------------------------------------------------------

  @override
  Future<String?> loadAchievements({
    bool forceRefresh = false,
    bool ignoreImages = false,
  }) async {
    final definitions = await _achievementDefinitions();
    final progress = await _achievementProgress();

    final items = definitions.map((def) {
      final id = def["id"]?.toString() ?? "";
      final state = progress[id] as Map<String, dynamic>?;
      final unlocked = (state?["unlocked"] as bool?) ?? false;
      final total = (def["steps"] as num?)?.toInt() ?? 0;
      final stored = (state?["steps"] as num?)?.toInt() ?? 0;
      return {
        "id": id,
        "name": def["name"]?.toString() ?? "",
        "description": def["description"]?.toString() ?? "",
        "lockedImage": ignoreImages ? null : def["lockedImage"],
        "unlockedImage": ignoreImages ? null : def["unlockedImage"],
        "completedSteps": unlocked && total > 0 ? total : stored,
        "totalSteps": total,
        "unlocked": unlocked,
      };
    }).toList();
    return jsonEncode(items);
  }

  @override
  Future<String?> unlock({required Achievement achievement}) async {
    final id = achievement.id;
    final progress = await _achievementProgress();
    final existing = progress[id] as Map<String, dynamic>?;
    progress[id] = {
      "unlocked": true,
      "steps": (existing?["steps"] as num?)?.toInt() ?? 0,
    };
    await _writeAchievementProgress(progress);
    return "success";
  }

  @override
  Future<String?> increment({required Achievement achievement}) async {
    final id = achievement.id;
    final definitions = await _achievementDefinitions();
    final total = definitions.firstWhere((d) => d["id"]?.toString() == id,
            orElse: () => {})["steps"] as num? ??
        0;

    final progress = await _achievementProgress();
    final existing = progress[id] as Map<String, dynamic>?;
    final steps =
        ((existing?["steps"] as num?)?.toInt() ?? 0) + achievement.steps;
    final unlocked = (existing?["unlocked"] as bool? ?? false) ||
        (total > 0 && steps >= total.toInt());
    progress[id] = {"unlocked": unlocked, "steps": steps};
    await _writeAchievementProgress(progress);
    return "success";
  }

  @override
  Future<String?> resetAchievements() async {
    await _requireClient
        .updateUserData(_ticket, keysToRemove: [_achievementsProgressKey]);
    return "success";
  }

  /// `null` on Windows: PlayFab provides no native achievements UI.
  @override
  Future<String?> showAchievements() async => null;

  Future<List<Map<String, dynamic>>> _achievementDefinitions() async {
    final data = await _requireClient
        .getTitleData(_ticket, keys: [_achievementsTitleDataKey]);
    final raw =
        (data["Data"] as Map<String, dynamic>?)?[_achievementsTitleDataKey];
    if (raw is! String || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> _achievementProgress() async {
    final data = await _requireClient
        .getUserData(_ticket, keys: [_achievementsProgressKey]);
    final record =
        (data["Data"] as Map<String, dynamic>?)?[_achievementsProgressKey]
            as Map<String, dynamic>?;
    final raw = record?["Value"];
    if (raw is! String || raw.isEmpty) return {};
    final decoded = jsonDecode(raw);
    return decoded is Map<String, dynamic> ? decoded : {};
  }

  Future<void> _writeAchievementProgress(Map<String, dynamic> progress) {
    return _requireClient.updateUserData(_ticket,
        data: {_achievementsProgressKey: jsonEncode(progress)});
  }

  // ---------------------------------------------------------------------------
  // Saved games (entity files + entity-object index)
  // ---------------------------------------------------------------------------

  Map<String, dynamic> get _entity {
    final entity = _session.entity;
    if (entity == null) {
      throw StateError("Not signed in. Call signIn() first.");
    }
    return entity;
  }

  /// Encodes a save name into a PlayFab-legal file name (a-Z 0-9 ( ) _ - .).
  String _fileName(String name) {
    final hex = utf8
        .encode(name)
        .map((b) => b.toRadixString(16).padLeft(2, "0"))
        .join();
    return "$hex.save";
  }

  @override
  Future<String?> saveGame({
    required String data,
    required String name,
    Uint8List? coverImage,
    String? description,
    Duration? playedTime,
  }) async {
    final client = _requireClient;
    final entity = _entity;
    final entityToken = _session.entityToken!;
    final fileName = _fileName(name);

    final envelope = jsonEncode({
      "data": data,
      "coverImage": coverImage != null ? base64Encode(coverImage) : null,
      "description": description,
      "playedTime": playedTime?.inMilliseconds,
    });

    final init =
        await client.initiateFileUploads(entityToken, entity, [fileName]);
    final uploadUrl = ((init["UploadDetails"] as List).first
        as Map<String, dynamic>)["UploadUrl"] as String;
    await client.uploadFileBytes(uploadUrl, utf8.encode(envelope));
    await client.finalizeFileUploads(entityToken, entity, [fileName]);

    final index = await _savedGamesIndex();
    index[name] = {
      "fileName": fileName,
      "modificationDate": DateTime.now().millisecondsSinceEpoch,
      "deviceName": _deviceName,
    };
    await client.setObject(entityToken, entity, _savedGamesObjectName, index);
    return "success";
  }

  @override
  Future<String?> loadGame({required String name}) async {
    final client = _requireClient;
    final fileName = _fileName(name);
    final files = await client.getFiles(_session.entityToken!, _entity);
    final metadata = (files["Metadata"] as Map<String, dynamic>?)?[fileName]
        as Map<String, dynamic>?;
    final downloadUrl = metadata?["DownloadUrl"] as String?;
    if (downloadUrl == null) return null;

    final bytes = await client.downloadBytes(downloadUrl);
    final envelope = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    return envelope["data"] as String?;
  }

  @override
  Future<String?> getSavedGames({bool forceRefresh = false}) async {
    final index = await _savedGamesIndex();
    final games = index.entries.map((entry) {
      final value = entry.value as Map<String, dynamic>;
      return {
        "name": entry.key,
        "modificationDate": (value["modificationDate"] as num?)?.toInt() ?? 0,
        "deviceName": value["deviceName"] ?? "",
      };
    }).toList();
    return jsonEncode(games);
  }

  @override
  Future<String?> deleteGame({required String name}) async {
    final client = _requireClient;
    final entityToken = _session.entityToken!;
    final entity = _entity;
    await client.deleteFiles(entityToken, entity, [_fileName(name)]);

    final index = await _savedGamesIndex();
    index.remove(name);
    await client.setObject(entityToken, entity, _savedGamesObjectName, index);
    return "success";
  }

  String get _deviceName {
    try {
      return Platform.localHostname;
    } catch (_) {
      return "Windows";
    }
  }

  Future<Map<String, dynamic>> _savedGamesIndex() async {
    final data =
        await _requireClient.getObjects(_session.entityToken!, _entity);
    final object =
        (data["Objects"] as Map<String, dynamic>?)?[_savedGamesObjectName]
            as Map<String, dynamic>?;
    final dataObject = object?["DataObject"];
    return dataObject is Map<String, dynamic> ? Map.of(dataObject) : {};
  }
}
