import '../../../shared/models/app_info.dart';

abstract class AppUsageService {
  Future<bool> hasUsagePermission();

  Future<void> openUsagePermissionSettings();

  Future<List<AppInfo>> getInstalledApps();

  Future<List<AppInfo>> getTopUsedApps();
}
