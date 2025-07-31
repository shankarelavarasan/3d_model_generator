import 'package:supabase_flutter/supabase_flutter.dart';
import '../env.json' as env;

class SupabaseConfig {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: env.SUPABASE_URL,
      anonKey: env.SUPABASE_ANON_KEY,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
  static SupabaseAuth get auth => Supabase.instance.client.auth;
}