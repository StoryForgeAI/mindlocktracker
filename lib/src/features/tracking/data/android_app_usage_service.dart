import 'dart:io';

import 'package:device_apps/device_apps.dart';
import 'package:flutter/services.dart';

import '../../../shared/models/app_info.dart';
import '../domain/app_usage_service.dart';

class AndroidAppUsageService implements AppUsageService {
  static const _channel = MethodChannel('mind_lock_tracker/usage');

  @override
  Future<List<AppInfo>> getInstalledApps() async {
    if (!Platform.isAndroid) return const [];
    final apps = await DeviceApps.getInstalledApplications(
      includeAppIcons: true,
      includeSystemApps: false,
      onlyAppsWithLaunchIntent: true,
    );
    return apps.map((app) {
      final icon = app is ApplicationWithIcon ? app.icon : null;
      return AppInfo(
        packageName: app.packageName,
        name: app.appName,
        icon: icon,
      );
    }).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  @override
  Future<List<AppInfo>> getTopUsedApps() async {
    if (!Platform.isAndroid) return const [];
    final installed = await getInstalledApps();
    final installedByPackage = {for (final app in installed) app.packageName: app};
    final top = await _channel.invokeMethod<List<dynamic>>('getTopUsedApps');
    final topEntries = (top ?? const <dynamic>[]).cast<Map<dynamic, dynamic>>();
    return topEntries.map((entry) {
      final packageName = entry['packageName'] as String? ?? '';
      final usageMs = entry['totalTimeForeground'] as int? ?? 0;
      final existing = installedByPackage[packageName];
      return AppInfo(
        packageName: packageName,
        name: existing?.name ?? (entry['appName'] as String? ?? packageName),
        icon: existing?.icon,
        usageMinutes: (usageMs / 60000).round(),
      );
    }).where((app) => app.packageName.isNotEmpty).toList();
  }

  @override
  Future<bool> hasUsagePermission() async {
    if (!Platform.isAndroid) return true;
    return await _channel.invokeMethod<bool>('hasUsageStatsPermission') ?? false;
  }

  @override
  Future<void> openUsagePermissionSettings() async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod('openUsageStatsSettings');
  }
}
