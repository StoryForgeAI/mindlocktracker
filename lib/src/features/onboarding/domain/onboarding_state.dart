class OnboardingState {
  const OnboardingState({
    this.selectedApps = const {},
    this.blockedApps = const {},
    this.lockIntervalMinutes,
    this.goal,
    this.finished = false,
  });

  final Set<String> selectedApps;
  final Set<String> blockedApps;
  final int? lockIntervalMinutes;
  final String? goal;
  final bool finished;

  List<int> get missingSteps {
    final missing = <int>[];
    if (selectedApps.isEmpty) missing.add(0);
    if (blockedApps.isEmpty) missing.add(1);
    if (lockIntervalMinutes == null) missing.add(2);
    if (goal == null || goal!.isEmpty) missing.add(3);
    return missing;
  }

  bool get isComplete => finished && missingSteps.isEmpty;

  OnboardingState copyWith({
    Set<String>? selectedApps,
    Set<String>? blockedApps,
    int? lockIntervalMinutes,
    bool clearInterval = false,
    String? goal,
    bool clearGoal = false,
    bool? finished,
  }) {
    return OnboardingState(
      selectedApps: selectedApps ?? this.selectedApps,
      blockedApps: blockedApps ?? this.blockedApps,
      lockIntervalMinutes: clearInterval
          ? null
          : (lockIntervalMinutes ?? this.lockIntervalMinutes),
      goal: clearGoal ? null : (goal ?? this.goal),
      finished: finished ?? this.finished,
    );
  }

  Map<String, dynamic> toJson() => {
        'selectedApps': selectedApps.toList(),
        'blockedApps': blockedApps.toList(),
        'lockIntervalMinutes': lockIntervalMinutes,
        'goal': goal,
        'finished': finished,
      };

  factory OnboardingState.fromJson(Map<String, dynamic> json) {
    return OnboardingState(
      selectedApps: ((json['selectedApps'] as List<dynamic>? ?? const <dynamic>[]))
          .cast<String>()
          .toSet(),
      blockedApps: ((json['blockedApps'] as List<dynamic>? ?? const <dynamic>[]))
          .cast<String>()
          .toSet(),
      lockIntervalMinutes: json['lockIntervalMinutes'] as int?,
      goal: json['goal'] as String?,
      finished: json['finished'] as bool? ?? false,
    );
  }
}
