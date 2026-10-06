class Preset {
  final String id;
  final String label;
  final int durationSeconds;
  final int createdAtMillis;

  const Preset({
    required this.id,
    required this.label,
    required this.durationSeconds,
    required this.createdAtMillis,
  });

  Duration get duration => Duration(seconds: durationSeconds);

  Map<String, dynamic> toMap() => {
        'id': id,
        'label': label,
        'durationSeconds': durationSeconds,
        'createdAtMillis': createdAtMillis,
      };

  factory Preset.fromMap(Map<dynamic, dynamic> map) => Preset(
        id: map['id'] as String,
        label: map['label'] as String,
        durationSeconds: map['durationSeconds'] as int,
        createdAtMillis: map['createdAtMillis'] as int,
      );
}
