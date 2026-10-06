import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/wake_mode.dart';
import '../../../core/providers/screen_wake_provider.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../l10n/generated/app_localizations.dart';

class ActiveSessionCard extends ConsumerWidget {
  const ActiveSessionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final stateAsync = ref.watch(wakeStateProvider);

    return stateAsync.when(
      data: (state) {
        if (!state.isActive) return const SizedBox.shrink();

        final subtitle = state.mode == WakeMode.indefinite
            ? l10n.activeIndefinite
            : l10n.timeRemaining(formatCountdown(state.remaining));

        return Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.brightness_high,
                    color: Theme.of(context).colorScheme.onPrimaryContainer, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.screenAwakeActive,
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                FilledButton.tonal(
                  onPressed: () => ref.read(wakeControllerProvider).stop(),
                  child: Text(l10n.stop),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
