import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../constants/channel_names.dart';
import '../models/installed_app.dart';

class InstalledAppsService {
  static const _channel = MethodChannel(ChannelNames.installedApps);

  Future<List<InstalledApp>> getInstalledApps() async {
    final result = await _channel.invokeMethod<List<dynamic>>('getInstalledApps');
    if (result == null) return [];
    return result.map((e) => InstalledApp.fromMap(e as Map)).toList();
  }

  Future<Uint8List?> getAppIcon(String packageName) async {
    final base64String = await _channel.invokeMethod<String>('getAppIcon', {
      'packageName': packageName,
    });
    if (base64String == null) return null;
    return base64Decode(base64String);
  }
}
