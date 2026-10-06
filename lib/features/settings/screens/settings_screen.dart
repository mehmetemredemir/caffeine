import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/quick_durations.dart';
import '../../../core/platform/permission_service.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/preset_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../l10n/generated/app_localizations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> with WidgetsBindingObserver {
  final _service = PermissionService();
  bool _notifGranted = false;
  bool _overlayGranted = false;
  bool _batteryIgnoring = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshPermissions();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshPermissions();
  }

  Future<void> _refreshPermissions() async {
    final notif = await _service.hasNotificationPermission();
    final overlay = await _service.hasOverlayPermission();
    final battery = await _service.isIgnoringBatteryOptimizations();
    if (!mounted) return;
    setState(() {
      _notifGranted = notif;
      _overlayGranted = overlay;
      _batteryIgnoring = battery;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final defaultTileDuration = ref.watch(defaultTileDurationProvider);
    final presets = ref.watch(presetListProvider);

    final tileOptions = <Duration?>[
      null,
      ...kQuickDurations,
      ...presets.map((p) => p.duration).where((d) => !kQuickDurations.contains(d)),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(l10n.language, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'en', label: Text(l10n.english)),
              ButtonSegment(value: 'tr', label: Text(l10n.turkish)),
            ],
            selected: {locale.languageCode},
            onSelectionChanged: (selection) {
              ref.read(localeProvider.notifier).setLocale(Locale(selection.first));
            },
          ),
          const SizedBox(height: 32),
          Text(l10n.defaultTileDuration, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(l10n.defaultTileDurationDescription, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final d in tileOptions)
                ChoiceChip(
                  label: Text(d == null ? l10n.indefinite : formatDurationLabel(d)),
                  selected: defaultTileDuration == d,
                  onSelected: (_) => ref.read(defaultTileDurationProvider.notifier).set(d),
                ),
            ],
          ),
          const SizedBox(height: 32),
          Text(l10n.permissionsSectionTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _PermissionTile(
            title: l10n.notificationPermission,
            granted: _notifGranted,
            l10n: l10n,
            onGrant: () async {
              await _service.requestNotificationPermission();
              _refreshPermissions();
            },
          ),
          _PermissionTile(
            title: l10n.overlayPermission,
            granted: _overlayGranted,
            l10n: l10n,
            onGrant: () => _service.requestOverlayPermission(),
          ),
          _PermissionTile(
            title: l10n.batteryOptimizationTitle,
            granted: _batteryIgnoring,
            l10n: l10n,
            onGrant: () => _service.requestIgnoreBatteryOptimizations(),
          ),
        ],
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.title,
    required this.granted,
    required this.l10n,
    required this.onGrant,
  });

  final String title;
  final bool granted;
  final AppLocalizations l10n;
  final VoidCallback onGrant;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(granted ? l10n.granted : l10n.notGranted),
        trailing: granted
            ? const Icon(Icons.check_circle, color: Colors.green)
            : FilledButton(onPressed: onGrant, child: Text(l10n.grant)),
      ),
    );
  }
}
