import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/preset_provider.dart';
import '../../../core/providers/screen_wake_provider.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../l10n/generated/app_localizations.dart';

class PresetList extends ConsumerWidget {
  const PresetList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final presets = ref.watch(presetListProvider);
    final controller = ref.read(wakeControllerProvider);

    if (presets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          l10n.noPresetsYet,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: presets.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final preset = presets[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: Text(preset.label),
            subtitle: Text(formatDurationLabel(preset.duration)),
            onTap: () => controller.startDuration(preset.duration),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n.deletePreset,
              onPressed: () => ref.read(presetListProvider.notifier).remove(preset.id),
            ),
          ),
        );
      },
    );
  }
}
