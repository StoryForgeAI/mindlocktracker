import 'dart:typed_data';

class AppInfo {
  const AppInfo({
    required this.packageName,
    required this.name,
    this.icon,
    this.usageMinutes = 0,
  });

  final String packageName;
  final String name;
  final Uint8List? icon;
  final int usageMinutes;

  AppInfo copyWith({int? usageMinutes}) {
    return AppInfo(
      packageName: packageName,
      name: name,
      icon: icon,
      usageMinutes: usageMinutes ?? this.usageMinutes,
    );
  }
}
