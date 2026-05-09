import 'dart:convert';

import 'package:fitcheck/Data/repositories/supabase_auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('SupabaseAuthRepository signIn', () {
    test('sends the email and password to Supabase', () async {
      http.Request? capturedRequest;

      final mockHttpClient = MockClient((request) async {
        capturedRequest = request;

        return http.Response(
          jsonEncode({
            'access_token': 'header.eyJleHAiOjk5OTk5OTk5OTl9.signature',
            'expires_in': 3600,
            'refresh_token': 'test-refresh-token',
            'token_type': 'bearer',
            'user': {
              'id': 'user-123',
              'app_metadata': {},
              'user_metadata': {},
              'aud': 'authenticated',
              'created_at': '2026-01-01T00:00:00Z',
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final supabase = SupabaseClient(
        'https://example.supabase.co',
        'test-anon-key',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
        httpClient: mockHttpClient,
      );
      final repository = SupabaseAuthRepository(supabase);

      await repository.signIn(
        email: 'user@example.com',
        password: 'Password123',
      );

      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.method, 'POST');
      expect(capturedRequest!.url.path, '/auth/v1/token');
      expect(capturedRequest!.url.queryParameters['grant_type'], 'password');

      final body = jsonDecode(capturedRequest!.body) as Map<String, dynamic>;
      expect(body['email'], 'user@example.com');
      expect(body['password'], 'Password123');

      await supabase.dispose();
    });
  });
}
