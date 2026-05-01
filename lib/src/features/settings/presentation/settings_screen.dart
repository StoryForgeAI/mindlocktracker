import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Settings', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('All onboarding choices are editable here.'),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: const Text('Lock interval'),
              subtitle: Text('${onboarding.lockIntervalMinutes ?? 30} minutes'),
              trailing: DropdownButton<int>(
                value: onboarding.lockIntervalMinutes ?? 30,
                items: const [
                  DropdownMenuItem(value: 15, child: Text('15m')),
                  DropdownMenuItem(value: 30, child: Text('30m')),
                  DropdownMenuItem(value: 60, child: Text('1h')),
                  DropdownMenuItem(value: 120, child: Text('2h')),
                ],
                onChanged: controller.setLockInterval,
              ),
            ),
          ),
          Card(
            child: SwitchListTile(
              title: const Text('RevenueCat ready: Premium mode preview'),
              subtitle: const Text('Architecture placeholder only'),
              value: onboarding.blockedApps.length > 5,
              onChanged: (_) {},
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Goal'),
              subtitle: Text(onboarding.goal ?? 'Not set'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => controller.setGoal(
                  onboarding.goal == 'Focus' ? 'Productivity' : 'Focus',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
