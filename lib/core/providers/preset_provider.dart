import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/preset.dart';
import '../../data/repositories/preset_repository.dart';
import 'hive_providers.dart';
import 'settings_provider.dart';
import '../platform/settings_service.dart';

final presetRepositoryProvider = Provider<PresetRepository>((ref) {
  return PresetRepository(ref.watch(presetsBoxProvider));
});

class PresetListNotifier extends StateNotifier<List<Preset>> {
  PresetListNotifier(this._repository, this._settingsService)
      : super(_repository.getAll()) {
    _syncToNative();
  }

  final PresetRepository _repository;
  final SettingsService _settingsService;

  Future<void> addFromDuration(Duration duration, String label) async {
    if (_repository.existsWithDuration(duration.inSeconds)) return;
    final preset = Preset(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      label: label,
      durationSeconds: duration.inSeconds,
      createdAtMillis: DateTime.now().millisecondsSinceEpoch,
    );
    await _repository.add(preset);
    state = _repository.getAll();
    _syncToNative();
  }

  Future<void> remove(String id) async {
    await _repository.remove(id);
    state = _repository.getAll();
    _syncToNative();
  }

  void _syncToNative() {
    _settingsService.syncPresets(
      state.map((p) => {'label': p.label, 'durationSeconds': p.durationSeconds}).toList(),
    );
  }
}

final presetListProvider = StateNotifierProvider<PresetListNotifier, List<Preset>>((ref) {
  return PresetListNotifier(
    ref.watch(presetRepositoryProvider),
    ref.watch(settingsServiceProvider),
  );
});
