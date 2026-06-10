# Windows (PlayFab)

Windows has no native equivalent of Game Center or Google Play Games. On Windows the
`games_services` plugin is implemented in pure Dart on top of the
[Microsoft PlayFab](https://learn.microsoft.com/gaming/playfab/) REST API:

| games_services concept | PlayFab feature |
| --- | --- |
| Sign in | `LoginWithCustomID` with an anonymous device id (a GUID persisted via `shared_preferences`) |
| Leaderboards | Player **statistics** (`UpdatePlayerStatistics`, `GetLeaderboard`, `GetLeaderboardAroundPlayer`, `GetFriendLeaderboard`) |
| Achievements | Definitions in **Title Data**, per-player progress in **User Data** |
| Saved games | **Entity Files** for the payload, an **Entity Object** for the index |

## 1. Create a PlayFab title

1. Create a title in the [PlayFab Game Manager](https://developer.playfab.com/) and copy its
   **Title ID** (Settings → Game Properties), e.g. `ABCDE`.
2. In **Settings → API Features**, enable **Allow client to post Player Statistics** (required
   for `submitScore`).
3. In **Settings → Client Profile Options**, allow **Display Name** and **Avatar URL** so the
   player profile and leaderboard entries can return them.

## 2. Initialize before sign-in

`initialize` is a no-op on Android/iOS/macOS, so it is safe to guard with a platform check or
just call it everywhere:

```dart
import 'dart:io' show Platform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) {
    await GamesServices.initialize(playFabTitleId: "ABCDE");
  }
  runApp(const App());
}

// later
await GameAuth.signIn();
```

`initialize` optionally accepts:
- `customId` — use your own stable player id instead of the auto-generated device GUID.
- `displayName` — set the player's display name when the account has none yet.

## 3. Leaderboards

Each leaderboard maps to a PlayFab **statistic** whose name is the **iOS** leaderboard id you
pass (Windows reuses the iOS identifiers). Create the statistic in **Leaderboards** (or let the
first `submitScore` create it). Time scopes (`today`/`week`/`allTime`) rely on the statistic's
configured reset frequency; `loadPreviousOccurrence` reads the prior statistic version.

> Leaderboard entry avatars are returned as **URLs** in `scoreHolder.iconImage` on Windows
> (the signed-in player's own `iconImage` is base64, fetched once at sign-in).

## 4. Achievements

PlayFab has no built-in achievement system, so define your achievements in **Content → Title
Data** under the key `achievements` as a JSON array:

```json
[
  { "id": "first_win", "name": "First Win", "description": "Win a game", "steps": 0 },
  { "id": "100_kills", "name": "Centurion", "description": "100 kills", "steps": 100,
    "lockedImage": "<base64>", "unlockedImage": "<base64>" }
]
```

- `steps` is the total step count for incremental achievements, `0` otherwise.
- `unlock`/`increment` write progress into the player's User Data key `achievements_progress`.
- `loadAchievements` merges the definitions with the stored progress.
- `resetAchievements` clears the progress key.

## 5. Saved games

`saveGame` stores each save as a PlayFab Entity File (a JSON envelope containing the data, an
optional base64 cover image, description, and played time) and records lightweight metadata
(name, modification date, device name) in an Entity Object index so `getSavedGames` is cheap.
`loadGame` downloads and unwraps the file; `deleteGame` removes both.

## Not available on Windows

These return `null` because they have no PlayFab equivalent:

- `showAchievements`, `showLeaderboards`, `showAccessPoint`, `hideAccessPoint` (no native UI)
- `getAuthCode` (Google Play Games only)
- `fetchIdentityVerificationSignature` (Game Center only)
