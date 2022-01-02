[![pub package](https://img.shields.io/pub/v/games_services.svg)](https://pub.dartlang.org/packages/games_services)

<img src="https://github.com/Abedalkareem/games_services/raw/master/logo.png" width="200"/>

A Flutter plugin to support game center and google play games services.  

## Screenshot  
#### iOS  
<img src="https://raw.githubusercontent.com/Abedalkareem/games_services/master/screenshots/screenshot1.png" width="200"/> <img src="https://raw.githubusercontent.com/Abedalkareem/games_services/master/screenshots/screenshot2.png" width="200"/> <img src="https://raw.githubusercontent.com/Abedalkareem/games_services/master/screenshots/screenshot3.png" width="200"/>  
#### Android  
<img src="https://raw.githubusercontent.com/Abedalkareem/games_services/master/screenshots/screenshot4.png" width="200"/> <img src="https://raw.githubusercontent.com/Abedalkareem/games_services/master/screenshots/screenshot5.png" width="200"/>  

## Tutorials  

[Written tutorial](https://bit.ly/2yv1C00)  

Video tutorial
*Will be added soon.*  

## Apps  

Monkey Banana [Android](https://play.google.com/store/apps/details?id=com.jostudio.monkeybanana) & [iOS](https://apps.apple.com/gm/app/id1514479049) by Abedalkareem.  
[Nonogram Colors](https://play.google.com/store/apps/details?id=com.tbuonomo.nonogramcolordot) by @tommybuonomo.
[Ripple Effect Puzzle](https://play.google.com/store/apps/details?id=com.tbuonomo.rippleeffectpuzzle) by @tommybuonomo.
Lights: A Memory Game [Android](https://play.google.com/store/apps/details?id=us.leephillips.lights) & [iOS](https://apps.apple.com/us/app/lights-a-memory-game/id1580230611) by @theLee3.


## Usage  
#### Sign in:  
To sign in the user. You need to call the sign in before  
making any action (like sending a score or unlocking an achievement).  
``` dart
 GamesServices.signIn();
```  

#### Show achievements:
To show the achievements screen.  
``` dart
GamesServices.showAchievements();
```  

#### Show leaderboards:
To show the leaderboards screen.  
``` dart
 GamesServices.showLeaderboards(iOSLeaderboardID: 'ios_leaderboard_id');
```  
*Note: You need to pass the leaderboard id for iOS, for android it's not required.*  

#### Submit score:  
To submit a ```Score``` to specific leader board.  
-The ```Score``` class takes three parameters:  
-```androidLeaderboardID```: the leader board id that you want to send the score for in case of android.  
-```iOSLeaderboardID``` the leader board id that you want to send the score for in case of iOS.  
-```value``` the score.  

``` dart
GamesServices.submitScore(score: Score(androidLeaderboardID: 'android_leaderboard_id',
                                       iOSLeaderboardID: 'ios_leaderboard_id',
                                       value: 5));
```  
  
*note: You need to pass the leaderboard id for iOS in case of iOS and the leaderboard id for android in case of android.*  

#### Unlock achievement:  
To unlock an ```Achievement```.  
The ```Achievement``` takes three parameters:  
-```androidID``` the achievement id for android.  
-```iOSID``` the achievement id for iOS.  
-```percentComplete``` the completion percent of the achievement, this parameter is optional in case of iOS.  

``` dart
GamesServices.unlock(achievement: Achievement(androidID: 'android_id',
                                              iOSID: 'ios_id',
                                              percentComplete: 100)); 
```  
  

*Note: You need to pass the achievement id for iOS in case of iOS and the achievement id for android in case of android.
the ```percentComplete``` is required in case of iOS but not android.*  

## Installing  
Simply add the following line to your pubspec.yaml file:  
``` yaml
dependencies:
  games_services: any       # <-- Add this line
```
  
