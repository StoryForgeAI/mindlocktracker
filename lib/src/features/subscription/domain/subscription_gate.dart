enum SubscriptionTier { free, premium }

class SubscriptionGate {
  const SubscriptionGate(this.tier);

  final SubscriptionTier tier;

  bool get canUseUnlimitedBlocking => tier == SubscriptionTier.premium;
  bool get canSeeAdvancedAnalytics => tier == SubscriptionTier.premium;
}
