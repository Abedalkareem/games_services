# Leaderboard and achievements

## Show achievements

Display the device's default achievements screen.

``` dart
Achievements.showAchievements();
```  

## Load achievements

Get achievements as a list. Use this to build a custom UI.

``` dart
final result = await Achievements.loadAchievements();
```

Note: Loading achievements may take time. It is recommended to use a background thread for better performance.

## Unlock achievement

Unlock an ```Achievement```.
The ```Achievement``` takes three parameters:

- ```androidID``` the achievement id for Google Play Games.
- ```iOSID``` the achievement id for Game Center.
- ```percentComplete``` the completion percentage of the achievement, this parameter is optional on iOS/macOS.
- ```steps``` the achievement steps for Google Play Games (as seen in the next section).

``` dart
Achievements.unlock(achievement: Achievement(androidID: 'android_id',
                                              iOSID: 'ios_id',
                                              percentComplete: 100));
```  

## Increment (Android Only)

Increment the steps for a Google Play Games achievement.

```dart
final result = await Achievements.increment(achievement: Achievement(androidID: 'android_id', steps: 50));
print(result);
```

## Show leaderboards

Display the device's default leaderboards screen. If a leaderboard ID is provided, it will display the specific leaderboard, otherwise it will show the list of all leaderboards.

``` dart
 Leaderboards.showLeaderboards(iOSLeaderboardID: 'ios_leaderboard_id', androidLeaderboardID: 'android_leaderboard_id');
```

## Load leaderboard scores

Get leaderboard scores as a list. Use this to build a custom UI.

``` dart
final result = await Leaderboards.loadLeaderboardScores(
        iOSLeaderboardID: "ios_leaderboard_id",
        androidLeaderboardID: "android_leaderboard_id",
        // Returns a list centered around the player's rank on the leaderboard. (Defaults to false)
        playerCentered: false,
        scope: PlayerScope.global,
        timeScope: TimeScope.allTime,
        maxResults: 10);
```

## Submit score

Submit a ```Score``` to specific leaderboard.
The ```Score``` class takes three parameters:

- ```androidLeaderboardID```: the leaderboard ID for Google Play Games.
- ```iOSLeaderboardID``` the leaderboard ID for Game Center.
- ```value``` the score.

``` dart
Leaderboards.submitScore(score: Score(androidLeaderboardID: 'android_leaderboard_id',
                                       iOSID: 'ios_id',
                                       value: 5));
```
