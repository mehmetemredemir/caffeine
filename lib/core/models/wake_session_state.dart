import 'wake_mode.dart';

class WakeSessionState {
  final bool isActive;
  final WakeMode mode;
  final Duration remaining;
  final Duration total;
  final String? boundPackage;

  const WakeSessionState({
    required this.isActive,
    required this.mode,
    required this.remaining,
    required this.total,
    this.boundPackage,
  });

  factory WakeSessionState.idle() => const WakeSessionState(
        isActive: false,
        mode: WakeMode.indefinite,
        remaining: Duration.zero,
        total: Duration.zero,
      );

  factory WakeSessionState.fromMap(Map<dynamic, dynamic> map) {
    return WakeSessionState(
      isActive: map['isActive'] as bool? ?? false,
      mode: wakeModeFromNative(map['mode'] as String? ?? 'INDEFINITE'),
      remaining: Duration(milliseconds: (map['remainingMillis'] as num?)?.toInt() ?? 0),
      total: Duration(milliseconds: (map['totalMillis'] as num?)?.toInt() ?? 0),
      boundPackage: map['boundPackage'] as String?,
    );
  }
}
