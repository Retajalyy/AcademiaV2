import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static late SupabaseClient client;

  static Future<void> init() async {
    await Supabase.initialize(
      url: 'https://szwutxelehqzzmccpodg.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN6d3V0eGVsZWhxenptY2Nwb2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg3NzYyODAsImV4cCI6MjA5NDM1MjI4MH0.7VnoCCSjjuu86Y1Zd2pVjra3jVhmUSYEeP-6jTnooZk',
    );

    client = Supabase.instance.client;
  }
}