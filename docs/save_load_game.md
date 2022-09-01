# Save/Load Game  

To be able to save games you must do few things before.  
On iOS/macOS:  
You must provide an iCloud container ID in your xcode project to save game data to the player’s iCloud account, to do that:  
- Open your xcode project.
- Select Runner project.
- Navigate to `Signing and Capabilities` 
- Click on the plus icon.
- Search for icloud.
- Enter.
- Now tick the `iCloud Documents`.
- Click on plus icon in the Containers section.
- Enter the name of the continaer.

On Android:  
Make sure to enable saved games support for your game in the Google Play Console, to do that:  
- In the Google Play Console, open the game you want to turn on Saved Games for and navigate to the Play Games Services - Configuration page (Grow > Play Games Services > Setup and management > Configuration) and select Edit properties.  
- Turn the Saved Games option to ON.  
- Click Save. 

After that when you sign in make sure to pass `shouldEnableSavedGame` as true.

``` dart
 GamesServices.signIn(shouldEnableSavedGame: true);
```  

## Save game 
To save a new game with `data` and a unique `name`.

```dart
final data = "55";
final result = await GamesServices.saveGame(data: data, name: "slot1");
```

The data is a `String` but you can pass a json string to save more complex data.  

```dart
final data = jsonEncode(GameData(96, "sword").toJson());
final result = await GamesServices.saveGame(data: data, name: "slot1");
```

*The `name` must be between 1 and 100 non-URL-reserved characters (a-z, A-Z, 0-9, or the symbols "-", ".", "_", or "~").*  


## Load game  
To load a game data with a `name`.

```dart
final result = await GamesServices.loadGame(name: "slot1");
if (result != null) {
  print("Player progress ${result}");
}
```

If the data you saved is a json string you can retrieve it as below:  

```dart
final result = await GamesServices.loadGame(name: "slot1");
if (result != null) {
  final Map json = jsonDecode(result);
  final gameData = GameData.fromJson(json);
  print("Player progress ${gameData.progress}");
  print("Player weapon ${gameData.weapon}");
}
```

## Delete game  
To delete a saved game.

```dart
final result = await GamesServices.deleteGame(name: "slot1");
```

## Get saved games 
To get all saved games as a list of `SavedGame`.

```dart
final result = await GamesServices.getSavedGames();
```