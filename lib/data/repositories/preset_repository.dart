import 'package:hive/hive.dart';
import '../../core/models/preset.dart';

class PresetRepository {
  PresetRepository(this._box);
  final Box _box;

  List<Preset> getAll() {
    final presets = _box.values
        .map((e) => Preset.fromMap(Map<dynamic, dynamic>.from(e as Map)))
        .toList();
    presets.sort((a, b) => a.durationSeconds.compareTo(b.durationSeconds));
    return presets;
  }

  bool existsWithDuration(int durationSeconds) {
    return getAll().any((p) => p.durationSeconds == durationSeconds);
  }

  Future<void> add(Preset preset) async {
    await _box.put(preset.id, preset.toMap());
  }

  Future<void> remove(String id) async {
    await _box.delete(id);
  }
}
