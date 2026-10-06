import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/preset_provider.dart';
import '../../../core/providers/screen_wake_provider.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../l10n/generated/app_localizations.dart';

Future<void> showCustomDurationSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _CustomDurationSheetContent(),
  );
}

class _CustomDurationSheetContent extends ConsumerStatefulWidget {
  const _CustomDurationSheetContent();

  @override
  ConsumerState<_CustomDurationSheetContent> createState() =>
      _CustomDurationSheetContentState();
}

class _CustomDurationSheetContentState extends ConsumerState<_CustomDurationSheetContent> {
  int _hours = 0;
  int _minutes = 15;
  int _seconds = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final duration = Duration(hours: _hours, minutes: _minutes, seconds: _seconds);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.customDuration, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          Row(
            children: [
              _WheelColumn(
                label: l10n.hours,
                max: 23,
                initial: _hours,
                onChanged: (v) => setState(() => _hours = v),
              ),
              _WheelColumn(
                label: l10n.minutes,
                max: 59,
                initial: _minutes,
                onChanged: (v) => setState(() => _minutes = v),
              ),
              _WheelColumn(
                label: l10n.seconds,
                max: 59,
                initial: _seconds,
                onChanged: (v) => setState(() => _seconds = v),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: duration.inSeconds == 0
                  ? null
                  : () async {
                      final label = formatDurationLabel(duration);
                      await ref
                          .read(presetListProvider.notifier)
                          .addFromDuration(duration, label);
                      await ref.read(wakeControllerProvider).startDuration(duration);
                      if (context.mounted) Navigator.of(context).pop();
                    },
              child: Text(l10n.start),
            ),
          ),
        ],
      ),
    );
  }
}

class _WheelColumn extends StatefulWidget {
  const _WheelColumn({
    required this.label,
    required this.max,
    required this.initial,
    required this.onChanged,
  });

  final String label;
  final int max;
  final int initial;
  final ValueChanged<int> onChanged;

  @override
  State<_WheelColumn> createState() => _WheelColumnState();
}

class _WheelColumnState extends State<_WheelColumn> {
  late final FixedExtentScrollController _controller =
      FixedExtentScrollController(initialItem: widget.initial);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(widget.label, style: Theme.of(context).textTheme.labelMedium),
          SizedBox(
            height: 140,
            child: ListWheelScrollView.useDelegate(
              controller: _controller,
              itemExtent: 40,
              perspective: 0.005,
              diameterRatio: 1.4,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: widget.onChanged,
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: widget.max + 1,
                builder: (context, index) => Center(
                  child: Text(
                    index.toString().padLeft(2, '0'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
