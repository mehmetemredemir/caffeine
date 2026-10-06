import 'package:hive/hive.dart';
import '../../core/models/app_watch_target.dart';

class AppWatchSelectionRepository {
  AppWatchSelectionRepository(this._box);
  final Box _box;

  static const _targetsKey = 'targets';

  List<AppWatchTarget> getTargets() {
    final raw = _box.get(_targetsKey, defaultValue: <dynamic>[]) as List;
    return raw
        .map((e) => AppWatchTarget.fromMap(Map<dynamic, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> saveTargets(List<AppWatchTarget> targets) {
    return _box.put(_targetsKey, targets.map((t) => t.toMap()).toList());
  }
}
