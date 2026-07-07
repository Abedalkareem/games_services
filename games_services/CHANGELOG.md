## 5.1.1

- Fix legacy Auth/Player methods returning stale data.

## 5.1.0

- Add optional `coverImage`, `description`, and `playedTime` parameters to `SaveGame.saveGame`. On Android these are set as the snapshot metadata (cover image required to pass Google's Play Games Services quality checklist). Ignored on iOS/macOS. (#228)
- Fix Android `saveGame` using the unique name as the snapshot description; the description is now only set when provided. (#228)
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
- Export for player_data.dart. by @theLee3
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

- Fix gradle issue by @Skyost
- add getPlayer by @theLee3

## 3.0.2

- Fix class not found exception on android @theLee3

## 3.0.1

- add playerIsUnderage by @theLee3
- add playerIsMultiplayerGamingRestricted by @theLee3
- add playerIsPersonalizedCommunicationRestricted by @theLee3
- Fix getSavedGames crash by @AntonHolovin
- Exclude Gson serialized data models from obfuscation by @theLee3

## 3.0.0

- Rearrange classes to group features. `GameAuth` for authintication, `Achievements` for anything related to Achievements, `Leaderboards` for anything related to Leaderboards, `Player` for anything related to Player, and `SaveGame` for anything related to save game.

## 2.2.2

- Add load achievements.
- Add load leaderboard scores.

## 2.2.0

- Release Load/ Save a game 🚀.

## 2.1.0

- Return error in case of error and null in case of success on android for the methods that has no return value.

## 2.0.9

- Support getting the current player score.

## 2.0.8

- Support getting the player name.

## 2.0.7

- Update docs.

## 2.0.5

- Support getting the player id.

## 2.0.4

- Fix the crash play service library. @impure @gyuri-fluttech @jonafeucht

## 2.0.3

- Added support for macOS.

## 2.0.2

- Fix android crash cused by pendingOperation.

## 2.0.1

- Fix showing a leader board with id on android.

## 2.0.0

- Migrated `jcenter` to `mavenCentral` See: [Gradle announcement](https://blog.gradle.org/jcenter-shutdown)
- Removed `android.enableR8`
- `jdk7` to `jdk8`
- Bumped up versions

## 2.0.0-nullsafety.3

- Make access_point_location accessible

## 2.0.0-nullsafety.2

- fix AccessPoint issues

## 2.0.0-nullsafety.1

- 💪 Running with sound null safety 💪 by @jonatadashi

## 1.0.0

- Add the iOS Access point

## 0.3.3

Add increment method by @tommybuonomo

## 0.3.2

Add the read me.

## 0.3.1

Show the android popups

## 0.2.10

Add addActivityResultListener for registrar

## 0.2.9

Return an error if user not logged in and clicked on achievement or leaderboard.

## 0.2.8

Add registerWith(registrar:) back

## 0.2.7

Add explicitSignIn, by @dioxmio

## 0.2.6

Fix autogenerated class GeneratedPluginRegistrant usage and missing constructor paramete, by @alexeystrakh

## 0.2.5

Update gradle properties to fix appcenter build, by @alexeystrakh

## 0.2.4

Upgrade to android x

## 0.2.3

Upgrade to flutter 1.12

## 0.2.2

Upgrade to swift 5.0

## 0.1.1

First stable release.
