import 'package:supabase_flutter/supabase_flutter.dart';

class MockAuthService {
  static Future<AuthResponse> mockSignIn() async {
    return AuthResponse(
      user: User(
        id: 'test-user-id',
        email: 'test@example.com',
        createdAt: DateTime.now(),
      ),
      session: Session(
        accessToken: 'mock-token',
        refreshToken: 'mock-refresh',
        user: User(
          id: 'test-user-id',
          email: 'test@example.com',
          createdAt: DateTime.now(),
        ),
      ),
    );
  }
}