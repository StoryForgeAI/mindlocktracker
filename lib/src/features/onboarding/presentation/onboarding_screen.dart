import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../shared/models/app_info.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, required this.initialStep});

  final int initialStep;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _controller = PageController(initialPage: widget.initialStep);
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _page = widget.initialStep;
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final appsAsync = ref.watch(installedAppsProvider);
    final topAppsAsync = ref.watch(topAppsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mind Lock Setup')),
      body: PageView(
        controller: _controller,
        onPageChanged: (index) => setState(() => _page = index),
        children: [
          _StepContainer(
            title: 'Step 1: Pick your apps',
            subtitle: 'Most used apps first, then view all installed apps.',
            child: appsAsync.when(
              data: (apps) => topAppsAsync.when(
                data: (topApps) => _AppSelectionStep(
                  apps: apps,
                  topApps: topApps,
                  selectedPackages: onboarding.selectedApps,
                  onToggle: controller.toggleSelectedApp,
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('Failed to load top apps'),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Failed to load apps'),
            ),
          ),
          _StepContainer(
            title: 'Step 2: Blocking setup',
            subtitle: 'Choose which selected apps are blocked.',
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: onboarding.selectedApps
                        .map(
                          (pkg) => SwitchListTile(
                            title: Text(pkg),
                            value: onboarding.blockedApps.contains(pkg),
                            onChanged: (_) => controller.toggleBlockedApp(pkg),
                          ),
                        )
                        .toList(),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    controller.setGoal(onboarding.goal);
                    _next();
                  },
                  child: const Text('Skip for now'),
                ),
              ],
            ),
          ),
          _StepContainer(
            title: 'Step 3: Lock interval',
            subtitle: 'How long should blocked apps stay locked?',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final interval in [15, 30, 60])
                  ChoiceChip(
                    label: Text('${interval}m'),
                    selected: onboarding.lockIntervalMinutes == interval,
                    onSelected: (_) => controller.setLockInterval(interval),
                  ),
                ActionChip(
                  label: const Text('Custom'),
                  onPressed: () async {
                    final custom = await _pickCustomInterval(context);
                    if (custom != null) controller.setLockInterval(custom);
                  },
                ),
              ],
            ),
          ),
          _StepContainer(
            title: 'Step 4: Goal',
            subtitle: 'Select your primary focus goal.',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final goal in const [
                  'Focus',
                  'Productivity',
                  'Reduce social media',
                  'Deep work',
                ])
                  ChoiceChip(
                    label: Text(goal),
                    selected: onboarding.goal == goal,
                    onSelected: (_) => controller.setGoal(goal),
                  ),
              ],
            ),
          ),
          _StepContainer(
            title: 'Step 5: Finish',
            subtitle: 'Review your setup and complete onboarding.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Selected apps: ${onboarding.selectedApps.length}'),
                Text('Blocked apps: ${onboarding.blockedApps.length}'),
                Text('Interval: ${onboarding.lockIntervalMinutes ?? '-'} min'),
                Text('Goal: ${onboarding.goal ?? '-'}'),
                const SizedBox(height: 12),
                if (onboarding.missingSteps.isNotEmpty)
                  const Text('If something missing, use the floating fix button.'),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (_page > 0)
                OutlinedButton(
                  onPressed: _back,
                  child: const Text('Back'),
                ),
              const Spacer(),
              FilledButton(
                onPressed: _page == 4
                    ? () {
                        controller.finish();
                        Navigator.of(context).pop();
                      }
                    : _next,
                child: Text(_page == 4 ? 'Finish' : 'Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _next() {
    if (_page >= 4) return;
    _controller.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _back() {
    if (_page <= 0) return;
    _controller.previousPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<int?> _pickCustomInterval(BuildContext context) async {
    final text = TextEditingController(text: '90');
    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom interval (minutes)'),
        content: TextField(
          controller: text,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter minutes'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, int.tryParse(text.text)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _StepContainer extends StatelessWidget {
  const _StepContainer({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(subtitle),
              const SizedBox(height: 16),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppSelectionStep extends StatelessWidget {
  const _AppSelectionStep({
    required this.apps,
    required this.topApps,
    required this.selectedPackages,
    required this.onToggle,
  });

  final List<AppInfo> apps;
  final List<AppInfo> topApps;
  final Set<String> selectedPackages;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const Text('Top 5 most used'),
        const SizedBox(height: 8),
        ...topApps.take(5).map((app) => _AppTile(
              app: app,
              selected: selectedPackages.contains(app.packageName),
              onTap: () => onToggle(app.packageName),
            )),
        const SizedBox(height: 8),
        ExpansionTile(
          title: const Text('Show more apps'),
          children: [
            for (final app in apps)
              _AppTile(
                app: app,
                selected: selectedPackages.contains(app.packageName),
                onTap: () => onToggle(app.packageName),
              ),
          ],
        ),
      ],
    );
  }
}

class _AppTile extends StatelessWidget {
  const _AppTile({
    required this.app,
    required this.selected,
    required this.onTap,
  });

  final AppInfo app;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      secondary: app.icon != null && app.icon!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(app.icon!, width: 28, height: 28),
            )
          : const CircleAvatar(child: Icon(Icons.apps)),
      value: selected,
      onChanged: (_) => onTap(),
      title: Text(app.name),
      subtitle: Text(app.packageName),
    );
  }
}
