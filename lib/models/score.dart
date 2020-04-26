import 'package:games_services/helpers.dart';

class Score {
  String androidLeaderboardID;
  String iOSLeaderboardID;
  int value;

  String get leaderboardID {
    return Helpers.isPlatformAndroid ? androidLeaderboardID : iOSLeaderboardID;
  }

  Score({this.iOSLeaderboardID, this.androidLeaderboardID, this.value});
}
