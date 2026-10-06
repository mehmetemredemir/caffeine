import 'package:flutter/services.dart';
import '../constants/channel_names.dart';

class SettingsService {
  static const _channel = MethodChannel(ChannelNames.settings);

  Future<void> setLocale(String languageCode) {
    return _channel.invokeMethod('setLocale', {'languageCode': languageCode});
  }

  Future<void> setDefaultTileDuration(Duration? duration) {
    return _channel.invokeMethod('setDefaultTileDuration', {
      'durationMillis': duration?.inMilliseconds,
    });
  }

  Future<Duration?> getDefaultTileDuration() async {
    final millis = await _channel.invokeMethod<int>('getDefaultTileDuration');
    if (millis == null) return null;
    return Duration(milliseconds: millis);
  }

  Future<void> syncPresets(List<Map<String, dynamic>> presets) {
    return _channel.invokeMethod('syncPresets', {'presets': presets});
  }
}
