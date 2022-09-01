# Leaderboard and achievements  

## Show achievements
To show the achievements screen.  
``` dart
GamesServices.showAchievements();
```  

## Load achievements
Get achievements as a list. Use this to build your own custom UI. 
``` dart
final result = await GamesServices.loadAchievements();
```  

## Show leaderboards
To show the leaderboards screen. It takes the leaderbord id for android and iOS.  
``` dart
 GamesServices.showLeaderboards(iOSLeaderboardID: 'ios_leaderboard_id', androidLeaderboardID: 'android_leaderboard_id');
```   

## Submit score  
To submit a ```Score``` to specific leaderboard.  
The ```Score``` class takes three parameters:  
- ```androidLeaderboardID```: the leader board id that you want to send the score for in case of android.  
- ```iOSLeaderboardID``` the leader board id that you want to send the score for in case of iOS.  
- ```value``` the score.  

``` dart
GamesServices.submitScore(score: Score(androidLeaderboardID: 'android_leaderboard_id',
                                       iOSLeaderboardID: 'ios_leaderboard_id',
                                       value: 5));
```  

## Unlock achievement  
To unlock an ```Achievement```.  
The ```Achievement``` takes three parameters:  
- ```androidID``` the achievement id for android.  
- ```iOSID``` the achievement id for iOS.  
- ```percentComplete``` the completion percent of the achievement, this parameter is optional in case of iOS.  
- ```steps``` the achievement steps for Android.

``` dart
GamesServices.unlock(achievement: Achievement(androidID: 'android_id',
                                              iOSID: 'ios_id',
                                              percentComplete: 100,
                                              steps: 2)); 
```  

## Increment (Android Only)  
To increment the steps for android achievement.

```dart
final result = await GamesServices.increment(achievement: Achievement(androidID: 'android_id', steps: 50));
print(result);
```  
