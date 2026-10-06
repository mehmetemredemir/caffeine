class InstalledApp {
  final String packageName;
  final String appName;

  const InstalledApp({required this.packageName, required this.appName});

  factory InstalledApp.fromMap(Map<dynamic, dynamic> map) {
    return InstalledApp(
      packageName: map['packageName'] as String? ?? '',
      appName: map['appName'] as String? ?? '',
    );
  }
}
