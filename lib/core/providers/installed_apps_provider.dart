import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/installed_app.dart';
import '../platform/installed_apps_service.dart';

final installedAppsServiceProvider = Provider<InstalledAppsService>((ref) {
  return InstalledAppsService();
});

final installedAppsProvider = FutureProvider<List<InstalledApp>>((ref) {
  return ref.watch(installedAppsServiceProvider).getInstalledApps();
});

final appIconProvider = FutureProvider.family<Uint8List?, String>((ref, packageName) {
  return ref.watch(installedAppsServiceProvider).getAppIcon(packageName);
});
