import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/app_watch_target.dart';
import '../../../core/platform/permission_service.dart';
import '../../../core/providers/app_watch_provider.dart';
import '../../../core/providers/installed_apps_provider.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../widgets/app_duration_picker_sheet.dart';
import '../widgets/app_list_tile.dart';

AppWatchTarget? _findTarget(List<AppWatchTarget> targets, String packageName) {
  for (final t in targets) {
    if (t.packageName == packageName) return t;
  }
  return null;
}

class AppSelectorScreen extends ConsumerStatefulWidget {
  const AppSelectorScreen({super.key});

  @override
  ConsumerState<AppSelectorScreen> createState() => _AppSelectorScreenState();
}

class _AppSelectorScreenState extends ConsumerState<AppSelectorScreen>
    with WidgetsBindingObserver {
  final _permissionService = PermissionService();
  bool _checked = false;
  bool _granted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission(promptIfMissing: true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Automatically re-checks when the user grants the permission in Settings and comes back.
    if (state == AppLifecycleState.resumed) {
      _checkPermission(promptIfMissing: false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkPermission({required bool promptIfMissing}) async {
    final granted = await _permissionService.hasUsageStatsPermission();
    if (!mounted) return;
    setState(() {
      _granted = granted;
      _checked = true;
    });
    if (!granted && promptIfMissing) _showPermissionDialog();
  }

  Future<void> _showPermissionDialog() async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.usageAccessRequired),
        content: Text(l10n.usageAccessExplanation),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _permissionService.openUsageAccessSettings();
            },
            child: Text(l10n.grantPermission),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (!_checked) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.appSpecificWakelock)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!_granted) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.appSpecificWakelock)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 48),
                const SizedBox(height: 16),
                Text(l10n.usageAccessRequired,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(l10n.usageAccessExplanation,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => _permissionService.openUsageAccessSettings(),
                  child: Text(l10n.grantPermission),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const _AppSelectorContent();
  }
}

class _AppSelectorContent extends ConsumerWidget {
  const _AppSelectorContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final appsAsync = ref.watch(installedAppsProvider);
    final targets = ref.watch(appWatchTargetsProvider);
    final watchState = ref.watch(appWatchStateProvider);

    final isWatching = watchState.maybeWhen(data: (s) => s.isWatching, orElse: () => false);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appSpecificWakelock)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.appWatchDurationDescription, style: Theme.of(context).textTheme.bodySmall),
          ),
          const Divider(height: 1),
          Expanded(
            child: appsAsync.when(
              data: (apps) {
                if (apps.isEmpty) return Center(child: Text(l10n.noAppsFound));
                return ListView.builder(
                  itemCount: apps.length,
                  itemBuilder: (context, index) {
                    final app = apps[index];
                    final target = _findTarget(targets, app.packageName);
                    final isSelected = target != null;
                    final durationLabel = target == null
                        ? null
                        : target.durationSeconds == null
                            ? l10n.indefinite
                            : formatDurationLabel(Duration(seconds: target.durationSeconds!));

                    final iconAsync = ref.watch(appIconProvider(app.packageName));
                    final iconBytes = iconAsync.maybeWhen(data: (b) => b, orElse: () => null);

                    return AppListTile(
                      app: app,
                      selected: isSelected,
                      durationLabel: durationLabel,
                      iconBytes: iconBytes,
                      onToggle: (_) =>
                          ref.read(appWatchTargetsProvider.notifier).toggle(app.packageName),
                      onTapDuration: () async {
                        final current = target?.durationSeconds != null
                            ? Duration(seconds: target!.durationSeconds!)
                            : (isSelected ? Duration.zero : null);
                        final result = await showAppDurationPicker(context, ref, current: current);
                        if (result == null) return;
                        final newDuration = result == Duration.zero ? null : result;
                        ref
                            .read(appWatchTargetsProvider.notifier)
                            .setDuration(app.packageName, newDuration?.inSeconds);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Center(child: Text(l10n.noAppsFound)),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: targets.isEmpty
                      ? null
                      : () {
                          final controller = ref.read(appWatchControllerProvider);
                          isWatching ? controller.stop() : controller.start(targets);
                        },
                  child: Text(isWatching ? l10n.stopWatching : l10n.startWatching),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
