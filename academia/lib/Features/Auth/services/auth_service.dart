import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:academia/Features/Auth/models/auth_user_model.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  Future<AuthUserModel> login(String uniId, String password) async {
    try {
      // ═══════════════════════════════════════════════════
      // STEP 1: Find the email associated with the University ID
      // ═══════════════════════════════════════════════════
      
      final dynamic searchResult = await _supabase
          .from('profiles')
          .select('email')
          .eq('uni_id', uniId)
          .maybeSingle();

      print('🔍 searchResult runtime type: ${searchResult.runtimeType}');
      print('🔍 searchResult value: $searchResult');

      if (searchResult == null) {
        throw Exception('University ID not found.');
      }

      if (searchResult is! Map<String, dynamic>) {
        throw Exception('Unexpected data format: ${searchResult.runtimeType}');
      }

      final email = searchResult['email'] as String?;
      print('✉️ Extracted email: $email');

      if (email == null || email.isEmpty) {
        throw Exception('Email not found for this University ID.');
      }

      // ═══════════════════════════════════════════════════
      // STEP 2: Authenticate with Supabase Auth
      // ═══════════════════════════════════════════════════
      
      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('🔐 authResponse type: ${authResponse.runtimeType}');
      print('🔐 authResponse.user: ${authResponse.user}');
      print('🔐 authResponse.user?.id: ${authResponse.user?.id}');

      final user = authResponse.user;
      if (user == null) {
        throw Exception('Authentication failed - user is null.');
      }

      if (user.id.isEmpty) {
        throw Exception('Authentication failed - user ID is empty.');
      }

      // ═══════════════════════════════════════════════════
      // STEP 3: Fetch full profile details
      // ═══════════════════════════════════════════════════
      
      final dynamic profileData = await _supabase
          .from('profiles')
          .select('id, uni_id, fname, lname, role, email, avatar_url, must_change_password')
          .eq('id', user.id)
          .single();

      print('📊 profileData runtime type: ${profileData.runtimeType}');
      print('📊 profileData value: $profileData');

      if (profileData is! Map<String, dynamic>) {
        throw Exception('Profile data is not a map: ${profileData.runtimeType}');
      }

      // Verify all required fields exist before fromMap
      final requiredFields = ['id', 'uni_id', 'fname', 'lname', 'role', 'email'];
      for (final field in requiredFields) {
        if (!profileData.containsKey(field)) {
          throw Exception('Missing required field in profile data: $field');
        }
        print('✅ Field $field: ${profileData[field]}');
      }

      return AuthUserModel.fromMap(profileData);

    } on AuthException catch (e) {
      print('❌ AuthException: ${e.message}');
      switch (e.message) {
        case 'Invalid login credentials':
          throw Exception('Incorrect password. Please try again.');
        case 'Email not confirmed':
          throw Exception('Account not activated. Please verify your email.');
        default:
          throw Exception(e.message);
      }
    } on PostgrestException catch (e) {
      print('❌ PostgrestException: ${e.message}');
      throw Exception('Database error: ${e.message}');
    } catch (e, stackTrace) {
      print('❌ Unexpected error: $e');
      print('📚 Stack trace:\n$stackTrace');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Updates the current user's password and clears the
  /// "must change password" flag on their profile.
  Future<void> changePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      await _supabase.rpc('mark_password_changed');
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  String? get currentUserId => _supabase.auth.currentUser?.id;
  bool get isLoggedIn => _supabase.auth.currentUser != null;
  User? get currentUser => _supabase.auth.currentUser;
}