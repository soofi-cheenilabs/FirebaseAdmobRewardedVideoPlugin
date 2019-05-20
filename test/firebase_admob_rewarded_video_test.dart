import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_admob_rewarded_video/firebase_admob_rewarded_video.dart';

void main() {
  const MethodChannel channel = MethodChannel('firebase_admob_rewarded_video');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FirebaseAdmobRewardedVideo.platformVersion, '42');
  });
}
