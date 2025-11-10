import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Thay thế bằng URL và API key thực tế của Supabase project
  static const String supabaseUrl = 'https://dvhuokxbokovcpwawrio.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR2aHVva3hib2tvdmNwd2F3cmlvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjExNzk0MDQsImV4cCI6MjA3Njc1NTQwNH0.pagcZC4HYiB2HJynPhCV8r8pOuS8uNhHG6IoSs4sBTA';
  
  static SupabaseClient get client => Supabase.instance.client;
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}
