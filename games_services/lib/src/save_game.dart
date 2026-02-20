import 'dart:convert';

import 'package:games_services/src/models/saved_game.dart';
import 'package:games_services_platform_interface/game_services_platform_interface.dart';

abstract class SaveGame {
  /// Save game with [data] and a unique [name].
  /// The [name] must be between 1 and 100 non-URL-reserved characters (a-z, A-Z, 0-9, or the symbols "-", ".", "_", or "~").
  static Future<String?> saveGame({
    required String data,
    required String name,
  }) =>
      GamesServicesPlatform.instance.saveGame(data: data, name: name);

  /// Load game with [name].
  static Future<String?> loadGame({required String name}) =>
      GamesServicesPlatform.instance.loadGame(name: name);

  /// Get all saved games.
  ///
  /// The `forceRefresh` argument will invalidate the cache on Android, fetching
  /// the latest results. It has no affect on iOS.
  static Future<List<SavedGame>?> getSavedGames({
    bool forceRefresh = false,
  }) async {
    final result = await GamesServicesPlatform.instance
        .getSavedGames(forceRefresh: forceRefresh);
    if (result == null) return null;
    final items = jsonDecode(result) as List;
    return items.map((json) => SavedGame.fromJson(json)).toList();
  }

  /// Delete game with [name].
  static Future<String?> deleteGame({required String name}) =>
      GamesServicesPlatform.instance.deleteGame(name: name);
}
