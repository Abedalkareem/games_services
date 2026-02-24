import 'dart:convert';

import 'package:games_services/games_services.dart';
import 'package:games_services_platform_interface/game_services_platform_interface.dart';

abstract class Friends {
  /// Open the default friends list screen on iOS 15.0+ and MacOS 12.0+.
  /// Does nothing on Android.
  static Future<String?> showFriendsList() =>
      GamesServicesPlatform.instance.showFriendsList();

  /// Check for access to the player's friends list. Useful for presenting
  /// differing UIs based on access. Calling [loadFriends] automatically request
  /// access if needed and will throw an error if access is denied.
  ///
  /// Supported on Android, iOS 14.5+ and macOS 11.3+.
  static Future<FriendsAccess> get access =>
      GamesServicesPlatform.instance.friendsAccess;

  /// Get the current player's friends list.
  ///
  /// `pageSize` will guarantee a minimum list size (or the full list if it is less)
  /// on Android. The list size may be larger than `pageSize` if the data is already
  /// cached. `forceRefresh` will invalidate the cache on Android, fetching
  /// the latest results. These arguments have no affect on iOS.
  ///
  /// Supported on Android, iOS 14.5+ and macOS 11.3+.
  static Future<List<PlayerData>?> loadFriends({
    int pageSize = 25,
    bool forceRefresh = false,
  }) async {
    final response = await GamesServicesPlatform.instance
        .loadFriends(pageSize: pageSize, forceRefresh: forceRefresh);
    if (response != null) {
      Iterable items = json.decode(response) as List;
      return List<PlayerData>.from(
          items.map((model) => PlayerData.fromJson(model)));
    }
    return null;
  }

  /// View a player's profile.
  ///
  /// On Android, this presents a player comparison profile
  /// between the current player and the player identified by the `playerID`. The
  /// `playerInGameName` and `localInGameName` will be presented on this screen to
  /// allow in game nicknames to carry over to Google Play Games, and any friend
  /// request sent from this view will include the `localInGameName`.
  ///
  /// Supported on Android, iOS 18.0+ and macOS 15.0+.
  static Future<String?> viewPlayerProfile({
    required String playerID,
    String? playerInGameName,
    String? localInGameName,
  }) =>
      GamesServicesPlatform.instance.viewPlayerProfile(
          playerID: playerID,
          playerInGameName: playerInGameName,
          localInGameName: localInGameName);

  /// Launch a player search UI. Only available on Android. Throws an
  /// [UnimplementedError] on other platforms.
  static Future<PlayerData?> searchForPlayer() =>
      GamesServicesPlatform.instance.searchForPlayer();

  /// Launch the friend request UI. Only available on iOS 15.0+ and MacOS 12.0+.
  /// Throws an [UnimplementedError] on other platforms.
  static Future<String?> sendFriendRequest() =>
      GamesServicesPlatform.instance.sendFriendRequest();
}
