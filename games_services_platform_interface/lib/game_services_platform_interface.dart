import 'dart:async';

import 'package:games_services_platform_interface/method_channel_games_services.dart';
import 'package:games_services_platform_interface/models/achievement.dart';
import 'package:games_services_platform_interface/models/score.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'models/access_point_location.dart';

abstract class GamesServicesPlatform extends PlatformInterface {
  /// Constructs a GamesServicesPlatform.
  GamesServicesPlatform() : super(token: _token);

  static final Object _token = Object();

  static GamesServicesPlatform _instance = MethodChannelGamesServices();

  /// The default instance of [GamesServicesPlatform] to use.
  ///
  /// Defaults to [MethodChannelGamesServices].
  static GamesServicesPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [GamesServicesPlatform] when they register themselves.
  static set instance(GamesServicesPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Increment an [achievement].
  /// [Achievement] takes two parameters:
  /// [androidID] the achievement id for android.
  /// [steps] If the achievement is of the incremental type
  /// you can use this method to increment the steps.
  /// * only for Android (see https://developers.google.com/games/services/android/achievements#unlocking_achievements).
  Future<String?> increment({achievement: Achievement}) async {
    throw UnimplementedError("not implemented.");
  }

  /// Unlock an [achievement].
  /// [Achievement] takes three parameters:
  /// [androidID] the achievement id for android.
  /// [iOSID] the achievement id for iOS.
  /// [percentComplete] the completion percent of the achievement, this parameter is
  /// optional in case of iOS.
  Future<String?> unlock({achievement: Achievement}) async {
    throw UnimplementedError("not implemented.");
  }

  /// Submit a [score] to specific leader board.
  /// [Score] takes three parameters:
  /// [androidLeaderboardID] the leader board id that you want to send the score for in case of android.
  /// [iOSLeaderboardID] the leader board id that you want to send the score for in case of iOS.
  /// [value] the score.
  Future<String?> submitScore({score: Score}) async {
    throw UnimplementedError("not implemented.");
  }

  /// It will open the achievements screen.
  Future<String?> showAchievements() async {
    throw UnimplementedError("not implemented.");
  }

  /// It will open the leaderboards screen.
  Future<String?> showLeaderboards({iOSLeaderboardID = "", androidLeaderboardID = ""}) async {
    throw UnimplementedError("not implemented.");
  }

  /// To sign in the user.
  /// You need to call the sign in before making any action,
  /// (like sending a score or unlocking an achievement).
  Future<String?> signIn() async {
    throw UnimplementedError("not implemented.");
  }

  /// Check to see if the user is currently signed into
  /// Game Center or Google Play Services
  Future<bool?> get isSignedIn => throw UnimplementedError("not implemented.");

  /// To sign the user out of Google Play Services.
  /// After calling, you can no longer make any actions
  /// on the user's account.
  Future<String?> signOut() async {
    throw UnimplementedError("not implemented.");
  }

  /// Show the iOS Access Point.
  Future<String?> showAccessPoint(AccessPointLocation location) async {
    throw UnimplementedError("not implemented.");
  }

  /// Hide the iOS Access Point.
  Future<String?> hideAccessPoint() async {
    throw UnimplementedError("not implemented.");
  }
}
