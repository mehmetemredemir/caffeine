import 'package:flutter/services.dart';
import '../constants/channel_names.dart';

class PermissionService {
  static const _channel = MethodChannel(ChannelNames.permissions);

  Future<bool> isIgnoringBatteryOptimizations() async {
    return await _channel.invokeMethod<bool>('isIgnoringBatteryOptimizations') ?? false;
  }

  Future<void> requestIgnoreBatteryOptimizations() {
    return _channel.invokeMethod('requestIgnoreBatteryOptimizations');
  }

  Future<bool> hasUsageStatsPermission() async {
    return await _channel.invokeMethod<bool>('hasUsageStatsPermission') ?? false;
  }

  Future<void> openUsageAccessSettings() {
    return _channel.invokeMethod('openUsageAccessSettings');
  }

  Future<bool> hasNotificationPermission() async {
    return await _channel.invokeMethod<bool>('hasNotificationPermission') ?? false;
  }

  Future<void> requestNotificationPermission() {
    return _channel.invokeMethod('requestNotificationPermission');
  }

  Future<bool> hasOverlayPermission() async {
    return await _channel.invokeMethod<bool>('hasOverlayPermission') ?? false;
  }

  Future<void> requestOverlayPermission() {
    return _channel.invokeMethod('requestOverlayPermission');
  }
}
