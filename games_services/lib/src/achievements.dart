import 'dart:convert';

import 'package:games_services/src/models/achievement_item_data.dart';
import 'package:games_services_platform_interface/game_services_platform_interface.dart';
import 'package:games_services_platform_interface/models.dart';

abstract class Achievements {
  /// Open the device's default achievements screen.
  static Future<String?> showAchievements() =>
      GamesServicesPlatform.instance.showAchievements();

  /// Get achievements as a list. Use this to build a custom UI.
  /// To show the device's default achievements screen use [showAchievements].
  ///
  /// The `forceRefresh` argument will invalidate the cache on Android, fetching
  /// the latest results. It has no affect on iOS.
  static Future<List<AchievementItemData>?> loadAchievements({
    bool forceRefresh = false,
    bool ignoreImages = false,
  }) async {
    String? result = await GamesServicesPlatform.instance.loadAchievements(
      forceRefresh: forceRefresh,
      ignoreImages: ignoreImages,
    );
    if (result != null) {
      Iterable items = json.decode(result) as List;
      return List<AchievementItemData>.from(
        items.map((model) => AchievementItemData.fromJson(model)).toList(),
      );
    }
    return null;
  }

  /// It will reset the achievements. Not available on Android.
  static Future<String?> resetAchievements() =>
      GamesServicesPlatform.instance.resetAchievements();

  /// Unlock an [achievement].
  /// [Achievement] takes three parameters:
  /// [androidID] the achievement ID for Google Play Games.
  /// [iOSID] the achievement ID for Game Center.
  /// [percentComplete] the completion percentage of the achievement,
  /// this parameter is optional on iOS/macOS.
  /// [showsCompletionBanner] whether to show the native completion banner,
  /// defaults to true.
  static Future<String?> unlock({required Achievement achievement}) =>
      GamesServicesPlatform.instance.unlock(achievement: achievement);

  /// Increment an [achievement].
  /// [Achievement] takes two parameters:
  /// [androidID] the achievement ID for Google Play Games.
  /// [steps] If the achievement is of the incremental type
  /// you can use this method to increment the steps.
  /// * only for Android (see https://developers.google.com/games/services/android/achievements#unlocking_achievements).
  static Future<String?> increment({required Achievement achievement}) =>
      GamesServicesPlatform.instance.increment(achievement: achievement);
}
