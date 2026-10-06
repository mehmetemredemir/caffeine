import 'package:flutter/services.dart';
import '../constants/channel_names.dart';
import '../models/wake_session_state.dart';
import 'screen_wake_platform.dart';

class AndroidScreenWakePlatform implements ScreenWakePlatform {
  static const _method = MethodChannel(ChannelNames.wakeMethod);
  static const _events = EventChannel(ChannelNames.wakeEvents);

  @override
  Future<void> startTimed(Duration duration) {
    return _method.invokeMethod('startTimed', {
      'durationMillis': duration.inMilliseconds,
    });
  }

  @override
  Future<void> startIndefinite() => _method.invokeMethod('startIndefinite');

  @override
  Future<void> stop() => _method.invokeMethod('stop');

  @override
  Stream<WakeSessionState> get stateStream => _events.receiveBroadcastStream().map(
        (event) => WakeSessionState.fromMap(event as Map),
      );
}
