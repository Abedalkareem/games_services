# Player

## Player ID

Get the current player's ID.

```dart
final playerID = Player.getPlayerID();
```

## Player name

Get the current player's name. This returns the player's alias on iOS/macOS.

```dart
final playerName = Player.getPlayerName();
```

## Player icon image

Get the player's icon image as a base64 encoded string.

```dart
// icon-size image
final base64iconImage = await Player.getPlayerIconImage();

// hi-res image
final base64hiResImage = await Player.getPlayerHiResImage();
```

## Player score

Get the current player's score for a specific leaderboard.

```dart
final playerScore = Player.getPlayerScore(
    iOSLeaderboardID = 'ios_leaderboard_id',
    androidLeaderboardID = 'android_leaderboard_id',
);
```

## Show AccessPoint (iOS Only)

Show the Game Center Access Point for the current player.

```dart
Player.showAccessPoint(AccessPointLocation.topLeading);
```

This feature is only available on iOS.
`AccessPointLocation` specifies the corner of the screen to display the access point. If you pass `topLeading` the access point will be shown on the top left corner in case of LTR layout.

## Hide AccessPoint (iOS Only)

Hide the Game Center Access Point.

```dart
Player.hideAccessPoint();
```
