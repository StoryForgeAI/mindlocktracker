import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

Future<void> bootstrapSupabase() async {
  if (AppConfig.supabaseUrl.isEmpty || AppConfig.supabaseAnonKey.isEmpty) {
    return;
  }
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
}

bool get isSupabaseConfigured =>
    AppConfig.supabaseUrl.isNotEmpty && AppConfig.supabaseAnonKey.isNotEmpty;
