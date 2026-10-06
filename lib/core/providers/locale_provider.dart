import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'hive_providers.dart';
import 'settings_provider.dart';

const _localeKey = 'locale';

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(this._ref) : super(_load(_ref.read(settingsBoxProvider)));

  final Ref _ref;

  static Locale _load(box) {
    final code = box.get(_localeKey, defaultValue: 'en') as String;
    return Locale(code);
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _ref.read(settingsBoxProvider).put(_localeKey, locale.languageCode);
    // Also sync the native side (for notification/tile text)
    await _ref.read(settingsServiceProvider).setLocale(locale.languageCode);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier(ref);
});
