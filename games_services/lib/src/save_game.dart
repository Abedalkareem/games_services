import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:games_services_platform_interface/game_services_platform_interface.dart';
import 'package:games_services_platform_interface/models.dart';

abstract class SaveGame {
  /// Save game with [data] and a unique [name].
  /// The [name] must be between 1 and 100 non-URL-reserved characters (a-z, A-Z, 0-9, or the symbols "-", ".", "_", or "~").
  ///
  /// You can optionally attach snapshot metadata used by Google Play Games
  /// Services on Android:
  /// * [coverImage] the raw bytes of an image (e.g. a PNG or JPEG) shown as the
  ///   cover for the saved game. Providing a cover image is required to pass
  ///   Google's Play Games Services quality checklist (item 6.1, see
  ///   https://developer.android.com/games/pgs/quality#saved-games).
  /// * [description] a human readable description of the saved game.
  /// * [playedTime] the total play time represented by this save.
  ///
  /// These parameters are ignored on iOS/macOS (Game Center), which does not
  /// support snapshot metadata.
  static Future<String?> saveGame({
    required String data,
    required String name,
    Uint8List? coverImage,
    String? description,
    Duration? playedTime,
  }) async {
    return await GamesServicesPlatform.instance.saveGame(
      data: data,
      name: name,
      coverImage: coverImage,
      description: description,
      playedTime: playedTime,
    );
  }

  /// Load game with [name].
  static Future<String?> loadGame({required String name}) async {
    return await GamesServicesPlatform.instance.loadGame(name: name);
  }

  /// Open the device's default game selection screen. (Android only.)
  ///
  /// The `title` will be displayed at the top of the UI. If `maxResults` is
  /// `null`, all game saves will be shown.
  ///
  /// If `allowNew` is `true` and the user chooses to create a new save, a
  /// `NewSave` object will be returned. It can be modified to upload a new save
  /// to the cloud when ready.
  static Future<SavedGame?> showSavedGames({
    required String title,
    bool allowNew = true,
    bool allowDelete = true,
    int? maxResults,
  }) async {
    try {
      final result = await GamesServicesPlatform.instance.showSavedGames(
        title: title,
        allowNew: allowNew,
        allowDelete: allowDelete,
        maxResults: maxResults,
      );
      if (result == null) return NewSave();
      return SavedGame.fromJson(jsonDecode(result));
    } on PlatformException catch (e) {
      if (e.code == 'operation_canceled') return null;
      rethrow;
    }
  }

  /// Get all saved games.
  ///
  /// The `forceRefresh` argument will invalidate the cache on Android, fetching
  /// the latest results. It has no affect on iOS.
  static Future<List<SavedGame>?> getSavedGames({
    bool forceRefresh = false,
    bool ignoreImages = false,
  }) async {
    final result = await GamesServicesPlatform.instance.getSavedGames(
      forceRefresh: forceRefresh,
      ignoreImages: ignoreImages,
    );
    if (result == null) {
      return null;
    }
    final List jsonArray = jsonDecode(result);
    final savedGames = jsonArray
        .map((json) => SavedGame.fromJson(json))
        .toList();
    return savedGames;
  }

  /// Delete game with [name].
  static Future<String?> deleteGame({required String name}) async {
    return await GamesServicesPlatform.instance.deleteGame(name: name);
  }
}
