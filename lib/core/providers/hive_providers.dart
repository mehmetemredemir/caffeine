import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

const settingsBoxName = 'settings';
const presetsBoxName = 'presets';
const appWatchSelectionBoxName = 'app_watch_selection';

final settingsBoxProvider = Provider<Box>((ref) => Hive.box(settingsBoxName));
final presetsBoxProvider = Provider<Box>((ref) => Hive.box(presetsBoxName));
final appWatchSelectionBoxProvider =
    Provider<Box>((ref) => Hive.box(appWatchSelectionBoxName));
