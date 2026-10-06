import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_services_platform_interface/models.dart';
import 'package:games_services_platform_interface/src/game_services_platform_impl.dart';
import 'package:games_services_platform_interface/src/util/device.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('games_services');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late bool originalIsPlatformAndroid;

  setUp(() {
    originalIsPlatformAndroid = Device.isPlatformAndroid;
  });

  tearDown(() {
    Device.isPlatformAndroid = originalIsPlatformAndroid;
    messenger.setMockMethodCallHandler(channel, null);
  });

  Future<MethodCall?> captureCall(
    Future<String?> Function(MethodChannelGamesServices platform) invoke,
  ) async {
    MethodCall? receivedCall;
    messenger.setMockMethodCallHandler(channel, (call) async {
      receivedCall = call;
      return '[]';
    });
    final result = await invoke(MethodChannelGamesServices());
    expect(result, '[]');
    return receivedCall;
  }

  test('sends ignoreImages: false by default', () async {
    Device.isPlatformAndroid = false;

    final call = await captureCall(
      (platform) => platform.loadLeaderboardScores(
        iOSLeaderboardID: 'ios-id',
        androidLeaderboardID: 'android-id',
        scope: PlayerScope.global,
        timeScope: TimeScope.allTime,
        maxResults: 25,
      ),
    );

    expect(call?.method, 'loadLeaderboardScores');
    expect(call?.arguments, <String, Object>{
      'leaderboardID': 'ios-id',
      'playerCentered': false,
      'leaderboardCollection': PlayerScope.global.value,
      'span': TimeScope.allTime.value,
      'maxResults': 25,
      'forceRefresh': false,
      'ignoreImages': false,
    });
  });

  test('sends ignoreImages over the channel', () async {
    Device.isPlatformAndroid = true;

    final call = await captureCall(
      (platform) => platform.loadLeaderboardScores(
        iOSLeaderboardID: 'ios-id',
        androidLeaderboardID: 'android-id',
        scope: PlayerScope.friendsOnly,
        timeScope: TimeScope.week,
        maxResults: 10,
        playerCentered: true,
        forceRefresh: true,
        ignoreImages: true,
      ),
    );

    expect(call?.method, 'loadLeaderboardScores');
    expect(call?.arguments, <String, Object>{
      'leaderboardID': 'android-id',
      'playerCentered': true,
      'leaderboardCollection': PlayerScope.friendsOnly.value,
      'span': TimeScope.week.value,
      'maxResults': 10,
      'forceRefresh': true,
      'ignoreImages': true,
    });
  });
}
