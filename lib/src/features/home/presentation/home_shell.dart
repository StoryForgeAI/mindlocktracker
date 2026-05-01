import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../onboarding/presentation/onboarding_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../widgets/blocking_lab_screen.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final onboarding = ref.read(onboardingControllerProvider);
      if (!onboarding.finished) {
        _openOnboarding();
      }
    });
  }

  void _openOnboarding({int? step}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OnboardingScreen(initialStep: step ?? 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingControllerProvider);
    const tabs = [
      DashboardScreen(),
      BlockingLabScreen(),
      SettingsScreen(),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: IndexedStack(
          key: ValueKey<int>(_index),
          index: _index,
          children: tabs,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.lock_clock), label: 'Blocking'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      floatingActionButton: onboarding.isComplete
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openOnboarding(step: onboarding.missingSteps.first),
              icon: const Icon(Icons.build_circle_outlined),
              label: const Text('Setup incomplete → Fix'),
            ),
    );
  }
}
