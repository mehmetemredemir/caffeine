import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wake_session_state.dart';
import '../platform/android_screen_wake_platform.dart';
import '../platform/screen_wake_platform.dart';

final screenWakePlatformProvider = Provider<ScreenWakePlatform>((ref) {
  return AndroidScreenWakePlatform();
});

final wakeStateProvider = StreamProvider<WakeSessionState>((ref) {
  return ref.watch(screenWakePlatformProvider).stateStream;
});

class WakeController {
  WakeController(this._platform);
  final ScreenWakePlatform _platform;

  Future<void> startDuration(Duration duration) => _platform.startTimed(duration);
  Future<void> startIndefinite() => _platform.startIndefinite();
  Future<void> stop() => _platform.stop();
}

final wakeControllerProvider = Provider<WakeController>((ref) {
  return WakeController(ref.watch(screenWakePlatformProvider));
});
