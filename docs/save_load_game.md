# Save/Load Game  

## Setup

### iOS/macOS

You must provide an iCloud container ID in your Xcode project to save game data to the player’s iCloud account:

- Open your Xcode project.
- Select Runner.
- Navigate to `Signing and Capabilities`.
- Click on the plus (`+`) icon.
- Search for iCloud.
- Now tick the `iCloud Documents`.
- Click on the plus (`+`) icon in the `Containers` section.
- Enter a name for the container.

### Android

Enable saved games support for your game in the Google Play Console:

- In the Google Play Console, open the game you want to turn on Saved Games for and navigate to Play Games Services - Configuration page (Grow > Play Games Services > Setup and management > Configuration) and select Edit properties.  
- Turn the `Saved Games` option to `ON`.  
- Click `Save`.

After that when you sign in make sure to set `shouldEnableSavedGame` to `true`.

``` dart
 GameAuth.signIn(shouldEnableSavedGame: true);
```  

## Save game

Save a game with `data` and a unique `name`.

```dart
final data = "55";
final result = await SaveGame.saveGame(data: data, name: "slot1");
```

The data is a `String` but you can pass a json string to save more complex data.  

```dart
final data = jsonEncode(GameData(96, "sword").toJson());
final result = await SaveGame.saveGame(data: data, name: "slot1");
```

*The `name` must be between 1 and 100 non-URL-reserved characters (a-z, A-Z, 0-9, or the symbols "-", ".", "_", or "~").*  

## Load game

Load a game save by `name`.

```dart
final result = await SaveGame.loadGame(name: "slot1");
if (result != null) {
  print("Player progress ${result}");
}
```

If the data you saved is a json string you can retrieve it like so:  

```dart
final result = await SaveGame.loadGame(name: "slot1");
if (result != null) {
  final Map json = jsonDecode(result);
  final gameData = GameData.fromJson(json);
  print("Player progress ${gameData.progress}");
  print("Player weapon ${gameData.weapon}");
}
```

## Delete game

Delete a saved game.

```dart
final result = await SaveGame.deleteGame(name: "slot1");
```

## Get saved games

Get all saved games as a list of `SavedGame`.

```dart
final result = await SaveGame.getSavedGames();
```
