import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_services/games_services.dart';

void main() {
  const MethodChannel channel = MethodChannel('games_services');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await GamesServices.platformVersion, '42');
  });
}
