import 'dart:convert';

import 'package:games_services/src/models/achievement_item_data.dart';
import 'package:games_services_platform_interface/game_services_platform_interface.dart';
import 'package:games_services_platform_interface/models.dart';

abstract class Achievements {
  /// It will open the achievements screen.
  static Future<String?> showAchievements() async {
    return await GamesServicesPlatform.instance.showAchievements();
  }

  /// Get achievements as a list. Use this to build your own custom UI.
  /// To show the prebuilt system UI use [showAchievements]
  static Future<List<AchievementItemData>?> loadAchievements() async {
    final response = await GamesServicesPlatform.instance.loadAchievements();
    if (response != null) {
      Iterable items = json.decode(response) as List;
      return List<AchievementItemData>.from(
          items.map((model) => AchievementItemData.fromJson(model)).toList());
    }
    return null;
  }

  /// Unlock an [achievement].
  /// [Achievement] takes three parameters:
  /// [androidID] the achievement id for android.
  /// [iOSID] the achievement id for iOS.
  /// [percentComplete] the completion percent of the achievement, this parameter is
  /// optional in case of iOS.
  static Future<String?> unlock({required Achievement achievement}) async {
    return await GamesServicesPlatform.instance
        .unlock(achievement: achievement);
  }

  /// Increment an [achievement].
  /// [Achievement] takes two parameters:
  /// [androidID] the achievement id for android.
  /// [steps] If the achievement is of the incremental type
  /// you can use this method to increment the steps.
  /// * only for Android (see https://developers.google.com/games/services/android/achievements#unlocking_achievements).
  static Future<String?> increment({required Achievement achievement}) async {
    return await GamesServicesPlatform.instance
        .increment(achievement: achievement);
  }
}
