import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../core/models/installed_app.dart';

class AppListTile extends StatelessWidget {
  const AppListTile({
    super.key,
    required this.app,
    required this.selected,
    required this.onToggle,
    required this.onTapDuration,
    this.durationLabel,
    this.iconBytes,
  });

  final InstalledApp app;
  final bool selected;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTapDuration;
  final String? durationLabel;
  final Uint8List? iconBytes;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => onToggle(!selected),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        backgroundImage: iconBytes != null ? MemoryImage(iconBytes!) : null,
        child: iconBytes == null ? const Icon(Icons.android) : null,
      ),
      title: Text(app.appName),
      subtitle: Text(
        selected ? (durationLabel ?? '') : app.packageName,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selected)
            IconButton(icon: const Icon(Icons.schedule), onPressed: onTapDuration),
          Checkbox(value: selected, onChanged: (v) => onToggle(v ?? false)),
        ],
      ),
    );
  }
}
