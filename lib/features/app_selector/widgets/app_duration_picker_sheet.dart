import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/quick_durations.dart';
import '../../../core/providers/preset_provider.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Return contract: null = the user cancelled (no change);
/// Duration.zero = "indefinite" was selected; anything else is the actual chosen duration.
Future<Duration?> showAppDurationPicker(
  BuildContext context,
  WidgetRef ref, {
  Duration? current,
}) {
  return showModalBottomSheet<Duration?>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _AppDurationPickerContent(current: current),
  );
}

class _AppDurationPickerContent extends ConsumerWidget {
  const _AppDurationPickerContent({this.current});
  final Duration? current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final presets = ref.watch(presetListProvider);

    final options = <Duration?>[
      null,
      ...kQuickDurations,
      ...presets.map((p) => p.duration).where((d) => !kQuickDurations.contains(d)),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.appWatchDurationOptional, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final d in options)
                  ChoiceChip(
                    label: Text(d == null ? l10n.indefinite : formatDurationLabel(d)),
                    selected: current == (d ?? Duration.zero),
                    onSelected: (_) => Navigator.of(context).pop(d ?? Duration.zero),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
