<img src="https://github.com/Abedalkareem/games_services/raw/master/logo.png" width="200"/>
A Flutter plugin to support game center and google play games services.

## Screenshot
To be added

## Example
#### Normal sign in:
To show the google sign in screen. <br>
``` GamesServices.signIn(); ```

#### Silent sign in:
To silently sign in. <br>
``` GamesServices.silentSignIn(); ```

#### Show achievements:
To show the achievements screen. <br>
``` GamesServices.showAchievements(); ```

#### Show leaderboards:
To show the leaderboards screen. <br>
``` GamesServices.showLeaderboards(leaderboardID: "ios_leaderboard_id"); ``` <br>
*note: You need to pass the leaderboard id for iOS, for android it's not required.*

#### Submit score:
To submit a score to specific leaderboard. <br>
``` GamesServices.submitScore(leaderboardID: 'leader_board_id', score: score); ``` <br>
*note: You need to pass the leaderboard id for iOS in case of iOS and the leaderboard id for android in case of android.*

#### Unlock achievement:
To unlock an achievement. <br>
``` GamesServices.unlock(achievementID: '', percentComplete: 0); ``` <br>
*note: You need to pass the achievement id for iOS in case of iOS and the achievement id for android in case of android.
the ```percentComplete``` is required in case of iOS but not android.*

## Installing
Simply add the following line to your pubspec.yaml file:
```
dependencies:
  games_services: any       # <-- Add this line
```
