import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'dart:io' show Platform;

class FirebaseAdmobRewardedVideo {
  static const MethodChannel _channel =
      const MethodChannel('firebase_admob_rewarded_video');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}

class MobileAdTargetingInfo {
  const MobileAdTargetingInfo(
      {this.keywords,
        this.contentUrl,
        this.childDirected,
        this.testDevices,
        this.nonPersonalizedAds});

  final List<String> keywords;
  final String contentUrl;
  final bool childDirected;
  final List<String> testDevices;
  final bool nonPersonalizedAds;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      'requestAgent': 'flutter-alpha',
    };

    if (keywords != null && keywords.isNotEmpty) {
      assert(keywords.every((String s) => s != null && s.isNotEmpty));
      json['keywords'] = keywords;
    }
    if (nonPersonalizedAds != null)
      json['nonPersonalizedAds'] = nonPersonalizedAds;
    if (contentUrl != null && contentUrl.isNotEmpty)
      json['contentUrl'] = contentUrl;
    if (childDirected != null) json['childDirected'] = childDirected;
    if (testDevices != null && testDevices.isNotEmpty) {
      assert(testDevices.every((String s) => s != null && s.isNotEmpty));
      json['testDevices'] = testDevices;
    }

    return json;
  }
}

enum RewardedVideoAdEvent {
  loaded,
  failedToLoad,
  opened,
  leftApplication,
  closed,
  rewarded,
  started,
  completed,
}

typedef void RewardedVideoAdListener(RewardedVideoAdEvent event,
    {String rewardType, int rewardAmount});

class RewardedVideoAd {
  RewardedVideoAd._();

  /// A platform-specific AdMob test ad unit ID for rewarded video ads. This ad
  /// unit has been specially configured to always return test ads, and
  /// developers are encouraged to use it while building and testing their apps.
  static final String testAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';

  static final RewardedVideoAd _instance = RewardedVideoAd._();

  /// The one and only instance of this class.
  static RewardedVideoAd get instance => _instance;

  /// Callback invoked for events in the rewarded video ad lifecycle.
  RewardedVideoAdListener listener;

  /// Shows a rewarded video ad if one has been loaded.
  Future<bool> show() {
    return _invokeBooleanMethod("showRewardedVideoAd");
  }

  /// sets the user id for ssv
  Future<bool> setUserId(
      {@required String userId}) {
    assert(userId.isNotEmpty);
    return _invokeBooleanMethod("setUserId", <String, dynamic>{
      'userId': userId,
    });
  }

  /// Loads a rewarded video ad using the provided ad unit ID.
  Future<bool> load(
      {@required String adUnitId, MobileAdTargetingInfo targetingInfo}) {
    assert(adUnitId.isNotEmpty);
    return _invokeBooleanMethod("loadRewardedVideoAd", <String, dynamic>{
      'adUnitId': adUnitId,
      'targetingInfo': targetingInfo?.toJson(),
    });
  }
}




class FirebaseAdMob {
  @visibleForTesting
  FirebaseAdMob.private(MethodChannel channel) : _channel = channel {
    _channel.setMethodCallHandler(_handleMethod);
  }

  // A placeholder AdMob App ID for testing. AdMob App IDs and ad unit IDs are
  // specific to a single operating system, so apps building for both Android and
  // iOS will need a set for each platform.
  static final String testAppId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544~3347511713'
      : 'ca-app-pub-3940256099942544~1458002511';

  static final FirebaseAdMob _instance = FirebaseAdMob.private(
    const MethodChannel('plugins.flutter.io/firebase_admob'),
  );

  /// The single shared instance of this plugin.
  static FirebaseAdMob get instance => _instance;

  final MethodChannel _channel;

  static const Map<String, RewardedVideoAdEvent> _methodToRewardedVideoAdEvent =
  <String, RewardedVideoAdEvent>{
    'onRewarded': RewardedVideoAdEvent.rewarded,
    'onRewardedVideoAdClosed': RewardedVideoAdEvent.closed,
    'onRewardedVideoAdFailedToLoad': RewardedVideoAdEvent.failedToLoad,
    'onRewardedVideoAdLeftApplication': RewardedVideoAdEvent.leftApplication,
    'onRewardedVideoAdLoaded': RewardedVideoAdEvent.loaded,
    'onRewardedVideoAdOpened': RewardedVideoAdEvent.opened,
    'onRewardedVideoStarted': RewardedVideoAdEvent.started,
    'onRewardedVideoCompleted': RewardedVideoAdEvent.completed,
  };

  /// Initialize this plugin for the AdMob app specified by `appId`.
  Future<bool> initialize(
      {@required String appId,
        String trackingId,
        bool analyticsEnabled = false}) {
    assert(appId != null && appId.isNotEmpty);
    assert(analyticsEnabled != null);
    return _invokeBooleanMethod("initialize", <String, dynamic>{
      'appId': appId,
      'trackingId': trackingId,
      'analyticsEnabled': analyticsEnabled,
    });
  }

  Future<dynamic> _handleMethod(MethodCall call) {
    assert(call.arguments is Map);
    final Map<dynamic, dynamic> argumentsMap = call.arguments;
    final RewardedVideoAdEvent rewardedEvent =
    _methodToRewardedVideoAdEvent[call.method];
    if (rewardedEvent != null) {
      if (RewardedVideoAd.instance.listener != null) {
        if (rewardedEvent == RewardedVideoAdEvent.rewarded) {
          RewardedVideoAd.instance.listener(rewardedEvent,
              rewardType: argumentsMap['rewardType'],
              rewardAmount: argumentsMap['rewardAmount']);
        } else {
          RewardedVideoAd.instance.listener(rewardedEvent);
        }
      }
    } else {
      // not a rewardedEvent is null
    }

    return Future<dynamic>.value(null);
  }
}

Future<bool> _invokeBooleanMethod(String method, [dynamic arguments]) async {
  final bool result = await FirebaseAdMob.instance._channel.invokeMethod(
    method,
    arguments,
  );
  return result;
}
