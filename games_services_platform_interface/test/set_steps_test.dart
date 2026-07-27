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

  test(
    'sends the absolute Android achievement steps over the channel',
    () async {
      Device.isPlatformAndroid = true;
      MethodCall? receivedCall;
      messenger.setMockMethodCallHandler(channel, (call) async {
        receivedCall = call;
        return 'success';
      });

      final result = await MethodChannelGamesServices().setSteps(
        achievement: Achievement(androidID: 'achievement-id', steps: 42),
      );

      expect(result, 'success');
      expect(receivedCall?.method, 'setSteps');
      expect(receivedCall?.arguments, <String, Object>{
        'achievementID': 'achievement-id',
        'steps': 42,
      });
    },
  );

  test(
    'rejects an empty Android achievement ID before channel invocation',
    () async {
      Device.isPlatformAndroid = true;
      var invoked = false;
      messenger.setMockMethodCallHandler(channel, (call) async {
        invoked = true;
        return 'success';
      });

      await expectLater(
        MethodChannelGamesServices().setSteps(
          achievement: Achievement(androidID: '  ', steps: 1),
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(invoked, isFalse);
    },
  );

  test('rejects non-positive steps before channel invocation', () async {
    Device.isPlatformAndroid = true;
    var invoked = false;
    messenger.setMockMethodCallHandler(channel, (call) async {
      invoked = true;
      return 'success';
    });

    await expectLater(
      MethodChannelGamesServices().setSteps(
        achievement: Achievement(androidID: 'achievement-id', steps: 0),
      ),
      throwsA(isA<ArgumentError>()),
    );
    expect(invoked, isFalse);
  });

  test('rejects unsupported platforms before channel invocation', () async {
    Device.isPlatformAndroid = false;
    var invoked = false;
    messenger.setMockMethodCallHandler(channel, (call) async {
      invoked = true;
      return 'success';
    });

    await expectLater(
      MethodChannelGamesServices().setSteps(
        achievement: Achievement(androidID: 'achievement-id', steps: 1),
      ),
      throwsA(isA<UnsupportedError>()),
    );
    expect(invoked, isFalse);
  });
}
