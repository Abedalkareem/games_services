# Sign in / out  

## Sign in  
Sign in the user to the Game center (iOS) or Google play games services (Android).  
If you pass [shouldEnableSavedGame], a drive scope will be added to GoogleSignInOptions. This will happed just on android as for iOS/macOS nothing is required to be sent when authenticate.  
You should call the sign in before making any action (like sending a score or unlocking an achievement).  

``` dart
 GameAuth.signIn(shouldEnableSavedGame: true);
```  

## Is Signed In 
A boolean value to check if the user is currently signed into Game Center or Google Play Services.  

```dart
final isSignedIn = GameAuth.isSignedIn;
```  

## Sign out  
To sign the user out of Goole Play Services. After calling, you can no longer make any actions on the user's account. This is available just on android. On iOS/macOS, the user can do that using device setting but there is no other way to do it.  

``` dart
 GameAuth.signOut();
```  