import '../models/app_watch_state.dart';
import '../models/app_watch_target.dart';

abstract class AppWatchPlatform {
  Future<void> start(List<AppWatchTarget> targets);
  Future<void> stop();
  Stream<AppWatchState> get stateStream;
}
