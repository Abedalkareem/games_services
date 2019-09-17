<img src="https://github.com/Abedalkareem/games_services/raw/master/logo.png" width="200"/> <br>
A Flutter plugin to support game center and google play games services.

## Screenshot
#### iOS
<img src="https://raw.githubusercontent.com/Abedalkareem/games_services/master/screenshots/screenshot1.png" width="200"/> <img src="https://raw.githubusercontent.com/Abedalkareem/games_services/master/screenshots/screenshot2.png" width="200"/> <img src="https://raw.githubusercontent.com/Abedalkareem/games_services/master/screenshots/screenshot3.png" width="200"/> <br>
#### Android
<img src="https://raw.githubusercontent.com/Abedalkareem/games_services/master/screenshots/screenshot4.png" width="200"/> <img src="https://raw.githubusercontent.com/Abedalkareem/games_services/master/screenshots/screenshot5.png" width="200"/> <br>

## Example
#### Sign in:
To sign in the user. You need to call the sign in before 
making any action (like sending a score or unlocking an achievement). <br>
``` GamesServices.signIn(); ```

#### Show achievements:
To show the achievements screen. <br>
``` GamesServices.showAchievements(); ```

#### Show leaderboards:
To show the leaderboards screen. <br>
``` GamesServices.showLeaderboards(iOSLeaderboardID: 'ios_leaderboard_id'); ``` <br>
*Note: You need to pass the leaderboard id for iOS, for android it's not required.*

#### Submit score:
To submit a ```Score``` to specific leader board.<br>
-The ```Score``` class takes three parameters:<br>
-```androidLeaderboardID```: the leader board id that you want to send the score for in case of android.<br>
-```iOSLeaderboardID``` the leader board id that you want to send the score for in case of iOS.<br>
-```value``` the score.<br>

```
GamesServices.submitScore(score: Score(androidLeaderboardID: 'android_leaderboard_id',
                                       iOSLeaderboardID: 'ios_leaderboard_id',
                                       value: 5));
``` 
<br>

*note: You need to pass the leaderboard id for iOS in case of iOS and the leaderboard id for android in case of android.*

#### Unlock achievement:
To unlock an ```Achievement```. <br>
The ```Achievement``` takes three parameters: <br>
-```androidID``` the achievement id for android. <br>
-```iOSID``` the achievement id for iOS. <br>
-```percentComplete``` the completion percent of the achievement, this parameter is optional in case of iOS. <br>

```
GamesServices.unlock(achievement: Achievement(androidID: 'android_id',
                                              iOSID: 'ios_id',
                                              percentComplete: 100)); 
``` 
<br>

*Note: You need to pass the achievement id for iOS in case of iOS and the achievement id for android in case of android.
the ```percentComplete``` is required in case of iOS but not android.*

## Installing
Simply add the following line to your pubspec.yaml file:
```
dependencies:
  games_services: any       # <-- Add this line
```
