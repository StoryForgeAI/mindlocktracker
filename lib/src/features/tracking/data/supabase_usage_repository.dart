import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_bootstrap.dart';

class SupabaseUsageRepository {
  Future<void> logUsage({
    required String userId,
    required String packageName,
    required int minutes,
  }) async {
    if (!isSupabaseConfigured) return;
    await Supabase.instance.client.from('usage_logs').insert({
      'user_id': userId,
      'package_name': packageName,
      'minutes': minutes,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> upsertBlockedApps({
    required String userId,
    required List<String> packages,
  }) async {
    if (!isSupabaseConfigured) return;
    await Supabase.instance.client.from('blocked_apps').upsert({
      'user_id': userId,
      'packages': packages,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
