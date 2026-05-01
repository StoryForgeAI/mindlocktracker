import 'dart:typed_data';

import '../../../shared/models/app_info.dart';
import '../domain/app_usage_service.dart';

class MockAppUsageService implements AppUsageService {
  const MockAppUsageService();

  static const _apps = [
    AppInfo(packageName: 'com.instagram.android', name: 'Instagram', usageMinutes: 42),
    AppInfo(packageName: 'com.google.android.youtube', name: 'YouTube', usageMinutes: 39),
    AppInfo(packageName: 'com.whatsapp', name: 'WhatsApp', usageMinutes: 28),
    AppInfo(packageName: 'com.reddit.frontpage', name: 'Reddit', usageMinutes: 23),
    AppInfo(packageName: 'com.spotify.music', name: 'Spotify', usageMinutes: 19),
    AppInfo(packageName: 'com.x', name: 'X', usageMinutes: 14),
  ];

  @override
  Future<List<AppInfo>> getInstalledApps() async {
    return _apps
        .map((app) => AppInfo(
              packageName: app.packageName,
              name: app.name,
              icon: Uint8List(0),
              usageMinutes: app.usageMinutes,
            ))
        .toList();
  }

  @override
  Future<List<AppInfo>> getTopUsedApps() async => _apps.take(5).toList();

  @override
  Future<bool> hasUsagePermission() async => false;

  @override
  Future<void> openUsagePermissionSettings() async {}
}
