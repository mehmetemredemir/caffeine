import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_watch_state.dart';
import '../models/app_watch_target.dart';
import '../platform/android_app_watch_platform.dart';
import '../platform/app_watch_platform.dart';
import '../../data/repositories/app_watch_selection_repository.dart';
import 'hive_providers.dart';

final appWatchPlatformProvider = Provider<AppWatchPlatform>((ref) {
  return AndroidAppWatchPlatform();
});

final appWatchStateProvider = StreamProvider<AppWatchState>((ref) {
  return ref.watch(appWatchPlatformProvider).stateStream;
});

final appWatchSelectionRepositoryProvider = Provider<AppWatchSelectionRepository>((ref) {
  return AppWatchSelectionRepository(ref.watch(appWatchSelectionBoxProvider));
});

class AppWatchTargetsNotifier extends StateNotifier<List<AppWatchTarget>> {
  AppWatchTargetsNotifier(this._repository) : super(_repository.getTargets());

  final AppWatchSelectionRepository _repository;

  void toggle(String packageName) {
    final exists = state.any((t) => t.packageName == packageName);
    state = exists
        ? state.where((t) => t.packageName != packageName).toList()
        : [...state, AppWatchTarget(packageName: packageName)];
    _repository.saveTargets(state);
  }

  void setDuration(String packageName, int? durationSeconds) {
    state = state
        .map((t) => t.packageName == packageName
            ? AppWatchTarget(packageName: packageName, durationSeconds: durationSeconds)
            : t)
        .toList();
    _repository.saveTargets(state);
  }
}

final appWatchTargetsProvider =
    StateNotifierProvider<AppWatchTargetsNotifier, List<AppWatchTarget>>((ref) {
  return AppWatchTargetsNotifier(ref.watch(appWatchSelectionRepositoryProvider));
});

class AppWatchController {
  AppWatchController(this._platform);
  final AppWatchPlatform _platform;

  Future<void> start(List<AppWatchTarget> targets) => _platform.start(targets);
  Future<void> stop() => _platform.stop();
}

final appWatchControllerProvider = Provider<AppWatchController>((ref) {
  return AppWatchController(ref.watch(appWatchPlatformProvider));
});
