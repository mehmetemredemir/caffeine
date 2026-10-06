import '../models/wake_session_state.dart';

/// Platform-independent interface for keeping the screen awake.
/// If Windows support is added later (Win32 SetThreadExecutionState), a
/// separate class implementing this interface is written — the Flutter UI
/// layer is never touched.
abstract class ScreenWakePlatform {
  Future<void> startTimed(Duration duration);
  Future<void> startIndefinite();
  Future<void> stop();
  Stream<WakeSessionState> get stateStream;
}
