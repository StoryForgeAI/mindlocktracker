import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';

class BlockingLabScreen extends ConsumerWidget {
  const BlockingLabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingControllerProvider);
    final blocked = onboarding.blockedApps.toList();
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Blocking simulator', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Simulates no-root lock overlay behavior.'),
          const SizedBox(height: 12),
          if (blocked.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No blocked apps yet.'))),
          for (final pkg in blocked)
            Card(
              child: ListTile(
                leading: const Icon(Icons.lock),
                title: Text(pkg),
                trailing: FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => LockedAppScreen(appPackage: pkg)),
                  ),
                  child: const Text('Simulate launch'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class LockedAppScreen extends StatelessWidget {
  const LockedAppScreen({super.key, required this.appPackage});

  final String appPackage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_clock, size: 64),
              const SizedBox(height: 16),
              Text('This app is locked', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(appPackage, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              const Text('Bypass available after timer expires or with Premium tier.'),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
