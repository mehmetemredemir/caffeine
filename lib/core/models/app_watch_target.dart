class AppWatchTarget {
  final String packageName;
  final int? durationSeconds; // null = indefinite while the app is in the foreground

  const AppWatchTarget({required this.packageName, this.durationSeconds});

  Map<String, dynamic> toMap() => {
        'packageName': packageName,
        'durationSeconds': durationSeconds,
      };

  factory AppWatchTarget.fromMap(Map<dynamic, dynamic> map) => AppWatchTarget(
        packageName: map['packageName'] as String,
        durationSeconds: map['durationSeconds'] as int?,
      );
}
