import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// Thrown when a PlayFab REST call returns an error envelope or a non-200 status.
class PlayFabException implements Exception {
  PlayFabException(this.code, this.error, this.errorMessage);

  /// PlayFab's numerical error code (or the HTTP status when none is provided).
  final int code;

  /// PlayFab's symbolic error name, e.g. `StatisticNotFound`.
  final String? error;

  /// Human readable description of the error.
  final String? errorMessage;

  @override
  String toString() => "PlayFabException($code, $error): $errorMessage";
}

/// A thin wrapper around the [PlayFab REST API](https://learn.microsoft.com/rest/api/playfab/)
/// exposing only the endpoints the Windows implementation of games_services needs.
///
/// All `Client/*` calls authenticate with the session ticket returned by
/// [loginWithCustomId] (`X-Authorization`). All `File/*` and `Object/*` calls
/// authenticate with the entity token from the same login (`X-EntityToken`).
class PlayFabClient {
  PlayFabClient({required this.titleId, http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  /// The PlayFab title id, found in Game Manager > Settings > Game Properties.
  final String titleId;
  final http.Client _http;

  String get _baseUrl => "https://$titleId.playfabapi.com";

  /// POSTs a PlayFab API call and returns the unwrapped `data` payload, throwing
  /// a [PlayFabException] on any error envelope or non-200 response.
  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body, {
    String? sessionTicket,
    String? entityToken,
  }) async {
    final headers = <String, String>{"Content-Type": "application/json"};
    if (sessionTicket != null) headers["X-Authorization"] = sessionTicket;
    if (entityToken != null) headers["X-EntityToken"] = entityToken;

    final response = await _http.post(
      Uri.parse("$_baseUrl$path"),
      headers: headers,
      body: jsonEncode(body),
    );

    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw PlayFabException(
        decoded["errorCode"] as int? ?? response.statusCode,
        decoded["error"] as String?,
        decoded["errorMessage"] as String? ?? response.reasonPhrase,
      );
    }
    return (decoded["data"] as Map<String, dynamic>?) ?? <String, dynamic>{};
  }

  // ---------------------------------------------------------------------------
  // Authentication
  // ---------------------------------------------------------------------------

  /// Signs in (creating the account if needed) with a title-generated custom id.
  /// Returns the raw `LoginResult` payload (`SessionTicket`, `PlayFabId`,
  /// `EntityToken`, `InfoResultPayload`).
  Future<Map<String, dynamic>> loginWithCustomId({
    required String customId,
    bool createAccount = true,
  }) {
    return _post("/Client/LoginWithCustomID", {
      "TitleId": titleId,
      "CustomId": customId,
      "CreateAccount": createAccount,
      "InfoRequestParameters": {
        "GetPlayerProfile": true,
        "ProfileConstraints": {
          "ShowDisplayName": true,
          "ShowAvatarUrl": true,
        },
      },
    });
  }

  /// Sets the title-specific display name for the signed-in player.
  Future<void> updateUserTitleDisplayName(
    String sessionTicket,
    String displayName,
  ) async {
    await _post(
      "/Client/UpdateUserTitleDisplayName",
      {"DisplayName": displayName},
      sessionTicket: sessionTicket,
    );
  }

  // ---------------------------------------------------------------------------
  // Statistics & leaderboards
  // ---------------------------------------------------------------------------

  /// Updates the player's statistics. `statistics` is a list of
  /// `{"StatisticName": ..., "Value": ...}` maps.
  Future<void> updatePlayerStatistics(
    String sessionTicket,
    List<Map<String, dynamic>> statistics,
  ) async {
    await _post(
      "/Client/UpdatePlayerStatistics",
      {"Statistics": statistics},
      sessionTicket: sessionTicket,
    );
  }

  /// Returns the player's statistic values (`{Statistics: [{StatisticName, Value, Version}]}`).
  Future<Map<String, dynamic>> getPlayerStatistics(
    String sessionTicket, {
    List<String>? statisticNames,
  }) {
    return _post(
      "/Client/GetPlayerStatistics",
      {"StatisticNames": ?statisticNames},
      sessionTicket: sessionTicket,
    );
  }

  static const _profileConstraints = {
    "ShowDisplayName": true,
    "ShowAvatarUrl": true,
  };

  /// Returns a ranked listing for `statisticName` starting at `startPosition`.
  Future<Map<String, dynamic>> getLeaderboard(
    String sessionTicket, {
    required String statisticName,
    int startPosition = 0,
    int maxResultsCount = 100,
    int? version,
  }) {
    return _post(
      "/Client/GetLeaderboard",
      {
        "StatisticName": statisticName,
        "StartPosition": startPosition,
        "MaxResultsCount": maxResultsCount,
        "ProfileConstraints": _profileConstraints,
        if (version != null) ...{
          "UseSpecificVersion": true,
          "Version": version,
        },
      },
      sessionTicket: sessionTicket,
    );
  }

  /// Returns a ranked listing centered on the signed-in player.
  Future<Map<String, dynamic>> getLeaderboardAroundPlayer(
    String sessionTicket, {
    required String statisticName,
    int maxResultsCount = 100,
  }) {
    return _post(
      "/Client/GetLeaderboardAroundPlayer",
      {
        "StatisticName": statisticName,
        "MaxResultsCount": maxResultsCount,
        "ProfileConstraints": _profileConstraints,
      },
      sessionTicket: sessionTicket,
    );
  }

  /// Returns a ranked listing restricted to the player's friends.
  Future<Map<String, dynamic>> getFriendLeaderboard(
    String sessionTicket, {
    required String statisticName,
    int startPosition = 0,
    int maxResultsCount = 100,
  }) {
    return _post(
      "/Client/GetFriendLeaderboard",
      {
        "StatisticName": statisticName,
        "StartPosition": startPosition,
        "MaxResultsCount": maxResultsCount,
        "ProfileConstraints": _profileConstraints,
      },
      sessionTicket: sessionTicket,
    );
  }

  // ---------------------------------------------------------------------------
  // Title & user data (achievements)
  // ---------------------------------------------------------------------------

  /// Returns the requested title data keys (`{Data: {key: value}}`).
  Future<Map<String, dynamic>> getTitleData(
    String sessionTicket, {
    required List<String> keys,
  }) {
    return _post(
      "/Client/GetTitleData",
      {"Keys": keys},
      sessionTicket: sessionTicket,
    );
  }

  /// Returns the requested user data keys (`{Data: {key: {Value, ...}}}`).
  Future<Map<String, dynamic>> getUserData(
    String sessionTicket, {
    required List<String> keys,
  }) {
    return _post(
      "/Client/GetUserData",
      {"Keys": keys},
      sessionTicket: sessionTicket,
    );
  }

  /// Writes and/or removes user data keys. Values must be strings.
  Future<void> updateUserData(
    String sessionTicket, {
    Map<String, String>? data,
    List<String>? keysToRemove,
  }) async {
    await _post(
      "/Client/UpdateUserData",
      {
        "Data": ?data,
        "KeysToRemove": ?keysToRemove,
      },
      sessionTicket: sessionTicket,
    );
  }

  // ---------------------------------------------------------------------------
  // Entity files & objects (saved games)
  // ---------------------------------------------------------------------------

  /// Requests upload URLs for `fileNames` on the given entity.
  /// Returns `{UploadDetails: [{FileName, UploadUrl}], ProfileVersion}`.
  Future<Map<String, dynamic>> initiateFileUploads(
    String entityToken,
    Map<String, dynamic> entity,
    List<String> fileNames,
  ) {
    return _post(
      "/File/InitiateFileUploads",
      {"Entity": entity, "FileNames": fileNames},
      entityToken: entityToken,
    );
  }

  /// Moves uploaded files from pending to live.
  Future<void> finalizeFileUploads(
    String entityToken,
    Map<String, dynamic> entity,
    List<String> fileNames,
  ) async {
    await _post(
      "/File/FinalizeFileUploads",
      {"Entity": entity, "FileNames": fileNames},
      entityToken: entityToken,
    );
  }

  /// Returns file metadata for the entity
  /// (`{Metadata: {fileName: {FileName, DownloadUrl, Size, LastModified}}, ProfileVersion}`).
  Future<Map<String, dynamic>> getFiles(
    String entityToken,
    Map<String, dynamic> entity,
  ) {
    return _post(
      "/File/GetFiles",
      {"Entity": entity},
      entityToken: entityToken,
    );
  }

  /// Deletes the named files from the entity's profile.
  Future<void> deleteFiles(
    String entityToken,
    Map<String, dynamic> entity,
    List<String> fileNames,
  ) async {
    await _post(
      "/File/DeleteFiles",
      {"Entity": entity, "FileNames": fileNames},
      entityToken: entityToken,
    );
  }

  /// Returns the entity's stored objects (`{Objects: {name: {ObjectName, DataObject}}}`).
  Future<Map<String, dynamic>> getObjects(
    String entityToken,
    Map<String, dynamic> entity,
  ) {
    return _post(
      "/Object/GetObjects",
      {"Entity": entity, "EscapeObject": false},
      entityToken: entityToken,
    );
  }

  /// Writes a single object onto the entity's profile.
  Future<void> setObject(
    String entityToken,
    Map<String, dynamic> entity,
    String objectName,
    Object dataObject,
  ) async {
    await _post(
      "/Object/SetObjects",
      {
        "Entity": entity,
        "Objects": [
          {"ObjectName": objectName, "DataObject": dataObject}
        ],
      },
      entityToken: entityToken,
    );
  }

  /// Uploads raw bytes to an Azure blob `UploadUrl` returned by
  /// [initiateFileUploads].
  Future<void> uploadFileBytes(String uploadUrl, List<int> bytes) async {
    final response = await _http.put(
      Uri.parse(uploadUrl),
      headers: {"x-ms-blob-type": "BlockBlob"},
      body: bytes,
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw PlayFabException(
          response.statusCode, "FileUploadFailed", response.reasonPhrase);
    }
  }

  /// Downloads raw bytes from a `DownloadUrl` (entity file) or an avatar URL.
  Future<Uint8List> downloadBytes(String url) async {
    final response = await _http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw PlayFabException(
          response.statusCode, "FileDownloadFailed", response.reasonPhrase);
    }
    return response.bodyBytes;
  }

  /// Releases the underlying HTTP client.
  void close() => _http.close();
}
