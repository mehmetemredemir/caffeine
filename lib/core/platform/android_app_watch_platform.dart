import 'package:flutter/services.dart';
import '../constants/channel_names.dart';
import '../models/app_watch_state.dart';
import '../models/app_watch_target.dart';
import 'app_watch_platform.dart';

class AndroidAppWatchPlatform implements AppWatchPlatform {
  static const _method = MethodChannel(ChannelNames.appWatch);
  static const _events = EventChannel(ChannelNames.appWatchEvents);

  @override
  Future<void> start(List<AppWatchTarget> targets) {
    return _method.invokeMethod('start', {
      'targets': targets.map((t) => t.toMap()).toList(),
    });
  }

  @override
  Future<void> stop() => _method.invokeMethod('stop');

  @override
  Stream<AppWatchState> get stateStream => _events.receiveBroadcastStream().map(
        (event) => AppWatchState.fromMap(event as Map),
      );
}
