# Player  

## Player id  
To get the current player id.

```dart
final playerID = Player.getPlayerID();
```

## Player name  
To get the current player name.

```dart
final playerName = Player.getPlayerName();
```

## Player score  
To get the current player score.

```dart
final playerScore = Player.getPlayerScore();
```

## Show AccessPoint (iOS Only)  
To show the access point you can call the following function.

```dart
Player.showAccessPoint(AccessPointLocation.topLeading);
```  

This feature support only on the iOS, on Android there is nothing like this supported natively.  
The `AccessPointLocation` specifies the corner of the screen to display the access point. If you pass `topLeading` the access point will be shown on the top left corner in case of LTR layout.   

## Hide AccessPoint (iOS Only)  
To hide the access point.

```dart
Player.hideAccessPoint();
```  

This feature support only on the iOS, on Android there is nothing like this supported natively.  