## Unreleased

- Add the Android-only `setSteps` achievement operation.

## 5.1.0

- Add optional `coverImage`, `description`, and `playedTime` parameters to `saveGame`. (#228)
- Add `showSavedGames` method to use Google Play Games default UI.
- Include Google Play Games metadata with returned `SavedGame`s.
- Add `timeScope` and `playerScope` parameters to `Leaderboards.showLeaderboards`.
- Migrate to Swift Package Manager.
- Migrate to built-in Kotlin (Bumps minimum supported SDK version to Flutter 3.44/Dart 3.12).

## 5.0.1

- Return `null` for `playerID` and `teamPlayerID` when GameCenter configuration errors lead to temporary IDs. by @theLee3

## 5.0.0

- Return success instead of null in case of success.
- Migrate Gamekit deprecated usage of methods.
- Update minimum support for iOS and Android.
- Fix the example.
- Add loadPreviousOccurrence method for iOS to retrieve the previous occurrence of a player's score from a leaderboard.
- Add ignoreImages to loadAchievements, offloading blocking loading images to IO threads pool.
- Add support for GKLocalPlayer.fetchItems.

## 4.1.1

- Fixes delay in some results after sign in. by @theLee3

## 4.1.0

- Add `player` stream to listen to authorization changes. by @theLee3
- Fix bug causing subsequent `signIn` calls to freeze on iOS if player not authenticated. Now throws auth error. by @theLee3
- Handle Play Services missing/outdated issues by returning error from `signIn` and presenting native dialog allowing user to resolve the issue. by @theLee3

## 4.0.3

- Add optional Bool forceRefreshToken as parameter for Android GamesSignInClient.requestServerSideAccess, replacing hard-coded false. Defaults to false. by @yukinoshita0219

## 4.0.2

- Add getPlayerScoreObject to retrieve rank and other score data for leaderboard and time span. by @egonbeermat
- Add optional String token to methods that submit and retrieve score. by @egonbeermat
- Add optional Bool showsCompletionBanner as parameter for iOS GKAchievement.report, replacing hard-coded true. Defaults to true. by @egonbeermat
- Add resetAchievements method for iOS only, Android doesn't support this through Play Games. by @egonbeermat
- Export for player_data.dart. by @@theLee3
- Add logs to save game.

## 4.0.1

- Add ability to get Play Games auth code for use with backends by @theLee3
- Add PlayerData class to return more score holder details by @theLee3
- Add isAuthenticated check alongside DEBUG signInFailed by @theLee3
- Add signInFailed check to prevent hanging on hot reload by @theLee3
- Handle consent exception when calling loadLeaderboardScores with Scope.friendsOnly by @theLee3
- Ensure all task exceptions are handled, to prevent crashes. by @Erfa

## 4.0.0

- migrate to google play games services 2.0.0.
- use darwin folder for iOS and macOS.

## 3.0.3

- add getPlayer by @theLee3

## 3.0.1

- add playerIsUnderage
- add playerIsMultiplayerGamingRestricted
- add playerIsPersonalizedCommunicationRestricted

## 3.0.0

- Rearrange classes to group features. `GameAuth` for authintication, `Achievements` for anything related to Achievements, `Leaderboards` for anything related to Leaderboards, `Player` for anything related to Player, and `SaveGame` for anything related to save game.

## 2.2.2

- Add load achievements.
- Add load leaderboard scores.

## 2.2.1

- Add shouldEnableSavedGame to sign in.

## 2.2.0

- Add save and load game 🎁 👾.

## 2.0.9

- Support getting the current player score.

## 2.0.6

- Support getting the player name.

## 2.0.5

- Support getting the player id.

## 2.0.1

- Fix the leaderboard id.

## 2.0.0

- 💪 Running with sound null safety 💪.

## 1.0.9

- Add the iOS Access point.

## 1.0.7

- Add increment method by @tommybuonomo.

## 1.0.5

- Change the method channel.

## 1.0.2

- Remove the static keyword for showAchievements, showLeaderboards and signIn.

## 1.0.1

- Remove the static keyword.

## 1.0.0

- Initial open-source release.
