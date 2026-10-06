import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/providers/hive_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox(settingsBoxName);
  await Hive.openBox(presetsBoxName);
  await Hive.openBox(appWatchSelectionBoxName);

  runApp(const ProviderScope(child: CaffeineApp()));
}
