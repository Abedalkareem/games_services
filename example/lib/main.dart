import 'package:flutter/material.dart';
import 'package:games_services/games_services.dart';
import 'package:games_services/Achievement.dart';
import 'package:games_services/Score.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
                RaisedButton(
                  child: Text('signIn'),
                  onPressed: () {
                    GamesServices.signIn();
                  },
                ),
                RaisedButton(
                  child: Text('Show Achievements'),
                  onPressed: () {
                    GamesServices.showAchievements();
                  },
                ),
                RaisedButton(
                  child: Text('Show Leaderboards'),
                  onPressed: () {
                    GamesServices.showLeaderboards(
                        iOSLeaderboardID: 'ios_leaderboard_id');
                  },
                ),
                RaisedButton(
                  child: Text('Submit Score'),
                  onPressed: () {
                    GamesServices.submitScore(
                        score: Score(
                            androidLeaderboardID: 'android_leaderboard_id',
                            iOSLeaderboardID: 'ios_leaderboard_id',
                            value: 5));
                  },
                ),
                RaisedButton(
                  child: Text('Unlock'),
                  onPressed: () {
                    GamesServices.unlock(
                        achievement: Achievement(
                            androidID: 'android_id',
                            iOSID: 'ios_id',
                            percentComplete: 100));
                  },
                ),
              ],
            ),
          )),
    );
  }
}
