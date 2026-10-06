class AppWatchState {
  final bool isWatching;
  final String? activePackage;

  const AppWatchState({required this.isWatching, this.activePackage});

  factory AppWatchState.idle() => const AppWatchState(isWatching: false);

  factory AppWatchState.fromMap(Map<dynamic, dynamic> map) {
    return AppWatchState(
      isWatching: map['isWatching'] as bool? ?? false,
      activePackage: map['activePackage'] as String?,
    );
  }
}
