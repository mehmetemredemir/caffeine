import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../platform/settings_service.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) => SettingsService());

final defaultTileDurationProvider =
    StateNotifierProvider<DefaultTileDurationNotifier, Duration?>((ref) {
  return DefaultTileDurationNotifier(ref.watch(settingsServiceProvider));
});

class DefaultTileDurationNotifier extends StateNotifier<Duration?> {
  DefaultTileDurationNotifier(this._service) : super(null) {
    _load();
  }

  final SettingsService _service;

  Future<void> _load() async {
    state = await _service.getDefaultTileDuration();
  }

  Future<void> set(Duration? duration) async {
    state = duration;
    await _service.setDefaultTileDuration(duration);
  }
}
