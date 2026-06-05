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

## Fetch Identity Verification Signature (iOS and macOS)

Fetch the identity verification signature from Game Center. This can be used to verify the player's identity with your backend server.

Returns an `IdentityVerificationSignature` object containing:

- `publicKeyURL`: URL to the public key for verifying the signature
- `signature`: Base64 encoded signature
- `salt`: Base64 encoded salt
- `timestamp`: Timestamp value

Returns `null` on platforms other than macOS and iOS.

```dart
final signature = await GameAuth.fetchIdentityVerificationSignature();
if (signature != null) {
  print('Public Key URL: ${signature.publicKeyURL}');
  print('Signature: ${signature.signature}');
  print('Salt: ${signature.salt}');
  print('Timestamp: ${signature.timestamp}');
  
  // Send to your backend for verification
}
```

## Prevent auto sign-in on Android

While the default and suggested behavior is to allow Play Games Services to automatically sign the user in on app launch, this can be prevented if desired. To do so, first, add `play-services-games-v2` to your `dependencies` in `android/app/build.gradle`.

```gradle
implementation "com.google.android.gms:play-services-games-v2:21.0.0" // or latest version
```


Next, make the following changes in `AndroidManifest.xml` to prevent the auto sign in:

```xml
<!-- Add the tools namespace via the manifest tag -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

<!-- Add the following provider tag inside the <application> tag -->
<provider tools:node="remove" android:name="com.google.android.gms.games.provider.PlayGamesInitProvider" />
```

Then, add the following to `MainActivity.kt` to initialize the Play Games SDK:

```kotlin
import android.os.Bundle
// imort the PlayGames SDK
import com.google.android.gms.games.PlayGamesSdk
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // initialize the play games SDK
        PlayGamesSdk.initialize(this)
    }
}
```
