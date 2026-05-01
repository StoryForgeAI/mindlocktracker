import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/onboarding/domain/onboarding_state.dart';
import '../features/tracking/data/android_app_usage_service.dart';
import '../features/tracking/data/mock_app_usage_service.dart';
import '../features/tracking/domain/app_usage_service.dart';
import '../shared/models/app_info.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in root');
});

final appUsageServiceProvider = Provider<AppUsageService>((ref) {
  if (Platform.isAndroid) {
    return AndroidAppUsageService();
  }
  return const MockAppUsageService();
});

final installedAppsProvider = FutureProvider<List<AppInfo>>((ref) async {
  final service = ref.read(appUsageServiceProvider);
  try {
    final permission = await service.hasUsagePermission();
    if (!permission) {
      return const MockAppUsageService().getInstalledApps();
    }
    return service.getInstalledApps();
  } catch (_) {
    return const MockAppUsageService().getInstalledApps();
  }
});

final topAppsProvider = FutureProvider<List<AppInfo>>((ref) async {
  final service = ref.read(appUsageServiceProvider);
  try {
    final permission = await service.hasUsagePermission();
    if (!permission) {
      return const MockAppUsageService().getTopUsedApps();
    }
    return service.getTopUsedApps();
  } catch (_) {
    return const MockAppUsageService().getTopUsedApps();
  }
});

class OnboardingController extends StateNotifier<OnboardingState> {
  OnboardingController(this._prefs) : super(_load(_prefs));

  static const _key = 'onboarding_state_v1';
  final SharedPreferences _prefs;

  static OnboardingState _load(SharedPreferences prefs) {
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const OnboardingState();
    return OnboardingState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> _save() async {
    await _prefs.setString(_key, jsonEncode(state.toJson()));
  }

  void toggleSelectedApp(String packageName) {
    final updated = {...state.selectedApps};
    if (!updated.add(packageName)) {
      updated.remove(packageName);
    }
    state = state.copyWith(selectedApps: updated);
    _save();
  }

  void toggleBlockedApp(String packageName) {
    final updated = {...state.blockedApps};
    if (!updated.add(packageName)) {
      updated.remove(packageName);
    }
    state = state.copyWith(blockedApps: updated);
    _save();
  }

  void setLockInterval(int? minutes) {
    state = minutes == null
        ? state.copyWith(clearInterval: true)
        : state.copyWith(lockIntervalMinutes: minutes);
    _save();
  }

  void setGoal(String? goal) {
    state = goal == null ? state.copyWith(clearGoal: true) : state.copyWith(goal: goal);
    _save();
  }

  void finish() {
    state = state.copyWith(finished: true);
    _save();
  }
}

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OnboardingController(prefs);
});

final focusScoreProvider = Provider<int>((ref) {
  final onboarding = ref.watch(onboardingControllerProvider);
  final blockedCount = onboarding.blockedApps.length;
  final base = 50 + blockedCount * 6 + (onboarding.lockIntervalMinutes ?? 0) ~/ 10;
  return base.clamp(0, 100);
});

final streakProvider = Provider<int>((ref) {
  final seed = ref.watch(onboardingControllerProvider).blockedApps.length + 3;
  return min(21, seed * 2);
});

final blockedAttemptsProvider = Provider<int>((ref) {
  final blocked = ref.watch(onboardingControllerProvider).blockedApps.length;
  return blocked * 4 + 3;
});

final weeklyMinutesProvider = Provider<List<int>>((ref) {
  final base = ref.watch(onboardingControllerProvider).lockIntervalMinutes ?? 30;
  return List<int>.generate(7, (i) => max(15, base + (i.isEven ? -6 : 8) + i * 3));
});
