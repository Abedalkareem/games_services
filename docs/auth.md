# Authentication

## Listen for Auth Changes

Subscribe to the `player` stream to listen for auth changes. The data will be `null` if the player is not authenticated. When authenticated, the data will be a `PlayerData` object containing all relevant player information.

```dart
GameAuth.player.listen((player) {
    if (player != null) {
        // signed in
    } else {
        // not signed in
    }
});
```

## Sign In

Sign the user into Game Center (iOS/macOS) or Google Play Games (Android). This must be called before taking any action (such as submitting a score or unlocking an achievement).

```dart
 GameAuth.signIn();
```

## Is Signed In

A boolean value to check if the user is currently signed into Game Center or Google Play Games.

```dart
final isSignedIn = await GameAuth.isSignedIn;
```

## Get Auth Code

Retrieve a Google Play Games `server_auth_code` to be used by a backend, such as Firebase, to authenticate the user. `null` on other platforms.

```dart
final authCode = await GameAuth.getAuthCode(String clientID);
```
