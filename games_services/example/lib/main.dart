import 'package:flutter/material.dart';
import 'package:games_services/games_services.dart';

void main() => runApp(const App());

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Games Services plugin example app'),
          ),
          body: Center(
            child: Column(
              children: <Widget>[
                ElevatedButton(
                  child: const Text('signIn'),
                  onPressed: () async {
                    final result = await GamesServices.signIn();
                    print(result);
                  },
                ),
                ElevatedButton(
                  child: const Text('Show Achievements'),
                  onPressed: () async {
                    final result = await GamesServices.showAchievements();
                    print(result);
                  },
                ),
                ElevatedButton(
                  child: const Text('Show Leaderboards'),
                  onPressed: () async {
                    final result = await GamesServices.showLeaderboards(
                        iOSLeaderboardID: 'ios_leaderboard_id');
                    print(result);
                  },
                ),
                ElevatedButton(
                  child: const Text('Submit Score'),
                  onPressed: () async {
                    final result = await GamesServices.submitScore(
                        score: Score(
                            androidLeaderboardID: 'android_leaderboard_id',
                            iOSLeaderboardID: 'ios_leaderboard_id',
                            value: 5));
                    print(result);
                  },
                ),
                ElevatedButton(
                  child: const Text('Unlock'),
                  onPressed: () async {
                    final result = await GamesServices.unlock(
                        achievement: Achievement(
                            androidID: 'android_id',
                            iOSID: 'ios_id',
                            percentComplete: 100));
                    print(result);
                  },
                ),
                ElevatedButton(
                  child: const Text('Increment'),
                  onPressed: () async {
                    final result = await GamesServices.increment(
                        achievement:
                            Achievement(androidID: 'android_id', steps: 50));
                    print(result);
                  },
                ),
                ElevatedButton(
                  child: const Text('Show AccessPoint (iOS only)'),
                  onPressed: () async {
                    final result = await GamesServices.showAccessPoint(
                        AccessPointLocation.topLeading);
                    print(result);
                  },
                ),
                ElevatedButton(
                  child: const Text('Get player id'),
                  onPressed: () async {
                    final result = await GamesServices.getPlayerID();
                    print(result);
                  },
                ),
              ],
            ),
          )),
    );
  }
}
