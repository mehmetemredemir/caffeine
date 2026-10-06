import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/quick_durations.dart';
import '../../../core/providers/screen_wake_provider.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../core/utils/responsive.dart';
import '../../../l10n/generated/app_localizations.dart';

class QuickDurationGrid extends ConsumerWidget {
  const QuickDurationGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final controller = ref.read(wakeControllerProvider);

    return GridView.count(
      crossAxisCount: Responsive.quickDurationColumns(context),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: Responsive.isTablet(context) ? 1.8 : 1.4,
      children: [
        ...kQuickDurations.map(
          (d) => _DurationButton(
            label: formatDurationLabel(d),
            onTap: () => controller.startDuration(d),
          ),
        ),
        _DurationButton(
          label: l10n.indefinite,
          icon: Icons.all_inclusive,
          onTap: () => controller.startIndefinite(),
        ),
      ],
    );
  }
}

class _DurationButton extends StatelessWidget {
  const _DurationButton({required this.label, required this.onTap, this.icon});
  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) Icon(icon, size: 22),
              if (icon != null) const SizedBox(height: 4),
              Text(label, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}
