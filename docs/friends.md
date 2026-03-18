# Friends

## iOS/MacOS Setup

On iOS and MacOS, you must provide a reason to access a player’s friends by adding the `NSGKFriendListUsageDescription` key to `Info.plist`.

There is no additional setup required for Android.

## Check for access to the players friends list

Get the access status to the player's friends list. This can be useful for presenting a different UI if friends list access is unavailable or to delay the request to access the friends list once value is established. It is not strictly necessary to use this as the call to `loadFriends` will automatically request access to the friends list on first call or throw an error if the access has been denied.

```dart
final FriendsAccess friendsAccess = await Friends.access;
```

## Get the player's friends list

Return a list of `PlayerData` objects representing the users platform friends.

```dart
final friends = await Friends.loadFriends();
```

## Show the player's friends list (iOS only)

Show the platform friends list UI. Friends access is not required.

```dart
Friends.showFriendsList();
```

## Show a player's profile

Show the platform UI displaying a player's profile. Passing in the current player's ID will display their profile.

```dart
Friends.showPlayerProfile(playerID);
```

On Android, the UI will contain a comparison of the current player's profile with the profile corresponding to the provided `playerID`. If the players are not platform friends, an option to add as a friend will be avaiable. If in game nicknames differ from the platfrom `displayName`s, these can be provided to display in the profile comparison UI. If provided, the `localInGameName` will also be included in the friend request.

```dart
Friends.showPlayerProfile(
  playerID,
  playerInGameName: 'otherPlayersNickname',
  localInGameName: 'currentPlayersNickname',
);
```

## Send a platform friend request (iOS only)

Launch the platform friend request UI.

```dart
Friends.sendFriendRequest();
```

## Search for a platform player by name (Android only)

Launch the platform player search UI. Returns a `PlayerData` object representing the selected player or `null` if canceled.

```dart
final player = Friends.searchForPlayer();
```
