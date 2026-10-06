import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/platform/permission_service.dart';
import '../../../core/utils/responsive.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../app_selector/screens/app_selector_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../widgets/active_session_card.dart';
import '../widgets/custom_duration_sheet.dart';
import '../widgets/preset_list.dart';
import '../widgets/quick_duration_grid.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runFirstLaunchPermissionFlow());
  }

  Future<void> _runFirstLaunchPermissionFlow() async {
    final service = PermissionService();
    final l10n = AppLocalizations.of(context)!;

    // 1) Notification permission — Android 13+ shows the system's own dialog.
    if (!await service.hasNotificationPermission()) {
      await service.requestNotificationPermission();
    }
    if (!mounted) return;

    // 2) Overlay permission — the actual mechanism that reliably keeps the screen on.
    if (!await service.hasOverlayPermission()) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.overlayPermissionTitle),
          content: Text(l10n.overlayPermissionExplanation),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.skip)),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                service.requestOverlayPermission();
              },
              child: Text(l10n.allow),
            ),
          ],
        ),
      );
    }
    if (!mounted) return;

    // 3) Battery optimization exemption.
    if (!await service.isIgnoringBatteryOptimizations()) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.batteryOptimizationTitle),
          content: Text(l10n.batteryOptimizationExplanation),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.skip)),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                service.requestIgnoreBatteryOptimizations();
              },
              child: Text(l10n.allow),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.apps),
            tooltip: l10n.appSpecificWakelock,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AppSelectorScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settingsTitle,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: Responsive.maxContentWidth(context)),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const ActiveSessionCard(),
              const SizedBox(height: 20),
              Text(l10n.quickDurations, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              const QuickDurationGrid(),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.tune),
                label: Text(l10n.customDuration),
                onPressed: () => showCustomDurationSheet(context, ref),
              ),
              const SizedBox(height: 28),
              Text(l10n.myPresets, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              const PresetList(),
            ],
          ),
        ),
      ),
    );
  }
}
