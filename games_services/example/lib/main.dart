import 'dart:convert';

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(color: Colors.black),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
        )),
      ),
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Games Services plugin example'),
          ),
          body: StreamBuilder<PlayerData?>(
              stream: GameAuth.player,
              builder: (context, snapshot) {
                final player = snapshot.data;
                return SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Image.asset(
                            "assets/logo.png",
                            width: 200,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: player == null
                              ? ElevatedButton(
                                  onPressed: _signIn,
                                  child: const Text('Sign In'),
                                )
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        if (player.iconImage != null)
                                          CircleAvatar(
                                            foregroundImage: MemoryImage(
                                              base64Decode(player.iconImage!),
                                            ),
                                          )
                                        else
                                          CircleAvatar(
                                            child: Text(player.displayName[0]),
                                          ),
                                        const SizedBox(width: 16.0),
                                        Text('playerID: ${player.playerID}\n'
                                            'displayName: ${player.displayName}'),
                                      ],
                                    ),
                                    const SizedBox(height: 16.0),
                                    Wrap(
                                      spacing: 20,
                                      runSpacing: 10,
                                      children: <Widget>[
                                        ElevatedButton(
                                          onPressed: _showAchievements,
                                          child:
                                              const Text('Show Achievements'),
                                        ),
                                        ElevatedButton(
                                          onPressed: _showLeaderboards,
                                          child:
                                              const Text('Show Leaderboards'),
                                        ),
                                        ElevatedButton(
                                          onPressed: _submitScore,
                                          child: const Text('Submit Score'),
                                        ),
                                        ElevatedButton(
                                          onPressed: _unlockAchievement,
                                          child:
                                              const Text('Unlock Achievement'),
                                        ),
                                        ElevatedButton(
                                          onPressed: _loadAchievement,
                                          child: const Text('Load Achievement'),
                                        ),
                                        ElevatedButton(
                                          onPressed: _resetAchievement,
                                          child:
                                              const Text('Reset Achievement'),
                                        ),
                                        ElevatedButton(
                                          onPressed: _loadLeaderboardScores,
                                          child: const Text(
                                              'Load Leaderboard Scores'),
                                        ),
                                        ElevatedButton(
                                          onPressed: _incrementAchievement,
                                          child: const Text(
                                              'Increment Achievement (Android only)'),
                                        ),
                                        ElevatedButton(
                                          onPressed: _showAccessPoint,
                                          child: const Text(
                                              'Show AccessPoint (iOS only)'),
                                        ),
                                        ElevatedButton(
                                          onPressed: _hideAccessPoint,
                                          child: const Text(
                                              'Hide AccessPoint (iOS only)'),
                                        ),
                                        ElevatedButton(
                                          onPressed: _getPlayerScore,
                                          child: const Text('Get player score'),
                                        ),
                                        ElevatedButton(
                                          onPressed: _getPlayerScoreObject,
                                          child: const Text(
                                              'Load Player Centered Scores'),
                                        ),
                                        ElevatedButton(
                                          onPressed: _getSavedGames,
                                          child: const Text('Get saved games'),
                                        ),
                                        ElevatedButton(
                                          onPressed: _saveGame,
                                          child: const Text('Save game'),
                                        ),
                                        ElevatedButton(
                                          onPressed: _loadGame,
                                          child: const Text('Load game'),
                                        ),
                                        ElevatedButton(
                                          onPressed: _deleteGame,
                                          child:
                                              const Text('Delete saved game'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              })),
    );
  }

  void _signIn() async {
    final result = await GameAuth.signIn();
    print(result);
  }

  void _getPlayerScore() async {
    final result = await Player.getPlayerScore();
    print(result);
  }

  void _getPlayerScoreObject() async {
    final result = await Leaderboards.getPlayerScoreObject(
        iOSLeaderboardID: "ios_leaderboard_id",
        androidLeaderboardID: "android_leaderboard_id",
        scope: PlayerScope.global,
        timeScope: TimeScope.allTime);
    print(result);
  }

  void _showAccessPoint() async {
    final result = await Player.showAccessPoint(AccessPointLocation.topLeading);
    print(result);
  }

  void _hideAccessPoint() async {
    final result = await Player.hideAccessPoint();
    print(result);
  }

  void _resetAchievement() async {
    final result = await Achievements.resetAchievements();
    print(result);
  }

  void _incrementAchievement() async {
    final result = await Achievements.increment(
        achievement: Achievement(androidID: 'android_id', steps: 50));
    print(result);
  }

  void _unlockAchievement() async {
    final result = await Achievements.unlock(
        achievement: Achievement(
            androidID: 'android_id', iOSID: 'ios_id', percentComplete: 100));
    print(result);
  }

  void _loadAchievement() async {
    final result = await Achievements.loadAchievements();
    print(result);
  }

  void _loadLeaderboardScores() async {
    final result = await Leaderboards.loadLeaderboardScores(
        iOSLeaderboardID: "ios_leaderboard_id",
        androidLeaderboardID: "android_leaderboard_id",
        scope: PlayerScope.global,
        timeScope: TimeScope.allTime,
        maxResults: 10);
    print(result);
  }

  void _submitScore() async {
    final result = await Leaderboards.submitScore(
        score: Score(
            androidLeaderboardID: 'android_leaderboard_id',
            iOSLeaderboardID: 'ios_leaderboard_id',
            value: 5));
    print(result);
  }

  void _showLeaderboards() async {
    final result = await Leaderboards.showLeaderboards(
        androidLeaderboardID: 'android_leaderboard_id',
        iOSLeaderboardID: 'ios_leaderboard_id');
    print(result);
  }

  void _showAchievements() async {
    final result = await Achievements.showAchievements();
    print(result);
  }

  void _getSavedGames() async {
    final result = await SaveGame.getSavedGames();
    print(result);
  }

  void _saveGame() async {
    final data = jsonEncode(GameData(96, "sword").toJson());
    final result = await SaveGame.saveGame(data: data, name: "slot1");
    print(result);
  }

  void _loadGame() async {
    final result = await SaveGame.loadGame(name: "slot1");
    if (result != null) {
      final Map json = jsonDecode(result);
      final gameData = GameData.fromJson(json);
      print("Player progress ${gameData.progress}");
      print("Player weapon ${gameData.weapon}");
    }
  }

  void _deleteGame() async {
    final result = await SaveGame.deleteGame(name: "slot1");
    print(result);
  }
}

class GameData {
  int progress;
  String weapon;
  GameData(this.progress, this.weapon);

  factory GameData.fromJson(Map json) {
    return GameData(json["progress"], json["weapon"]);
  }

  Map toJson() => {'progress': progress, 'weapon': weapon};
}
