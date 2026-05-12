import 'dart:convert';

import 'package:fitcheck/Data/repositories/supabase_auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('SupabaseAuthRepository signIn', () {
    // Test Plan row 2: valid login credentials.
    // Checks that signIn sends the same email and password to Supabase.
    test('sends the email and password to Supabase', () async {
      http.Request? capturedRequest;

      final mockHttpClient = MockClient((request) async {
        capturedRequest = request;

        // Fake successful Supabase login response, so no real network call is made.
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
        authOptions: const AuthClientOptions(
          autoRefreshToken: false,
          authFlowType: AuthFlowType.implicit,
        ),
        httpClient: mockHttpClient,
      );
      final repository = SupabaseAuthRepository(supabase);

      await repository.signIn(
        email: 'user@example.com',
        password: 'Password123',
      );

      expect(capturedRequest, isNotNull);

      final body = jsonDecode(capturedRequest!.body) as Map<String, dynamic>;
      expect(body['email'], 'user@example.com');
      expect(body['password'], 'Password123');

      await supabase.dispose();
    });

    // Test Plan row 5: invalid login credentials.
    // Checks that signIn passes a Supabase login error back to the app.
    test('throws an AuthException when login details are invalid', () async {
      final mockHttpClient = MockClient((request) async {
        // Fake failed Supabase login response.
        return http.Response(
          jsonEncode({
            'msg': 'Invalid login credentials',
            'error': 'invalid_grant',
          }),
          400,
          headers: {'content-type': 'application/json'},
        );
      });

      final supabase = SupabaseClient(
        'https://example.supabase.co',
        'test-anon-key',
        authOptions: const AuthClientOptions(
          autoRefreshToken: false,
          authFlowType: AuthFlowType.implicit,
        ),
        httpClient: mockHttpClient,
      );
      final repository = SupabaseAuthRepository(supabase);

      await expectLater(
        repository.signIn(email: 'wrong@example.com', password: 'wrongpass'),
        throwsA(isA<AuthException>()),
      );

      await supabase.dispose();
    });
  });

  group('SupabaseAuthRepository signUp', () {
    // Test Plan row 8: valid registration.
    // Checks that signUp sends email, password and username to Supabase.
    test('sends registration details to Supabase', () async {
      http.Request? capturedRequest;

      final mockHttpClient = MockClient((request) async {
        capturedRequest = request;

        // Fake successful Supabase registration response.
        return http.Response(
          jsonEncode({
            'access_token': 'header.eyJleHAiOjk5OTk5OTk5OTl9.signature',
            'expires_in': 3600,
            'refresh_token': 'test-refresh-token',
            'token_type': 'bearer',
            'user': {
              'id': 'user-456',
              'app_metadata': {},
              'user_metadata': {'username': 'alex'},
              'aud': 'authenticated',
              'email': 'alex@example.com',
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
        authOptions: const AuthClientOptions(
          autoRefreshToken: false,
          authFlowType: AuthFlowType.implicit,
        ),
        httpClient: mockHttpClient,
      );
      final repository = SupabaseAuthRepository(supabase);

      await repository.signUp(
        email: 'alex@example.com',
        password: 'Password123',
        username: 'alex',
      );

      expect(capturedRequest, isNotNull);

      final body = jsonDecode(capturedRequest!.body) as Map<String, dynamic>;
      expect(body['email'], 'alex@example.com');
      expect(body['password'], 'Password123');
      expect(body['data'], {'username': 'alex'});

      await supabase.dispose();
    });

    // Test Plan row 11: invalid email registration.
    // Checks that signUp passes a Supabase registration error back to the app.
    test('throws an AuthException when the email is invalid', () async {
      final mockHttpClient = MockClient((request) async {
        // Fake failed Supabase registration response.
        return http.Response(
          jsonEncode({
            'msg': 'Unable to validate email address',
            'error': 'invalid_email',
          }),
          400,
          headers: {'content-type': 'application/json'},
        );
      });

      final supabase = SupabaseClient(
        'https://example.supabase.co',
        'test-anon-key',
        authOptions: const AuthClientOptions(
          autoRefreshToken: false,
          authFlowType: AuthFlowType.implicit,
        ),
        httpClient: mockHttpClient,
      );
      final repository = SupabaseAuthRepository(supabase);

      await expectLater(
        repository.signUp(
          email: 'alex',
          password: 'Password123',
          username: 'alex',
        ),
        throwsA(isA<AuthException>()),
      );

      await supabase.dispose();
    });
  });
}
