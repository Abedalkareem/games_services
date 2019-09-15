import 'package:flutter/material.dart';
import 'package:games_services/games_services.dart';

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
                  child: Text('silentSignIn'),
                  onPressed: () {
                    GamesServices.silentSignIn();
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
                    GamesServices.showLeaderboards(leaderboardID: '');
                  },
                ),
                RaisedButton(
                  child: Text('Submit Score'),
                  onPressed: () {
                    GamesServices.submitScore(leaderboardID: '', score: 1);
                  },
                ),
                RaisedButton(
                  child: Text('Unlock'),
                  onPressed: () {
                    GamesServices.unlock(achievementID: '', percentComplete: 0);
                  },
                ),
              ],
            ),
          )),
    );
  }
}
