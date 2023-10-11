# Sign in / out

## Sign in

Sign the user into Game Center (iOS/macOS) or Google Play Games (Android). This must be called before taking any action (such as submitting a score or unlocking an achievement).

``` dart
 GameAuth.signIn();
```

## Is Signed In

A boolean value to check if the user is currently signed into Game Center or Google Play Games.

```dart
final isSignedIn = GameAuth.isSignedIn;
```
