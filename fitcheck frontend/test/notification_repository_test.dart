import 'dart:convert';

import 'package:fitcheck/Data/repositories/notification_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationRepository fetchNotifications', () {
    // Checks that notification loading does nothing when no user is signed in.
    test('returns an empty list when no user is signed in', () async {
      var requestCount = 0;
      final mockHttpClient = MockClient((request) async {
        requestCount++;
        return _notFound(request);
      });

      await _withTestSupabase(mockHttpClient, () async {
        final repository = NotificationRepository();

        final notifications = await repository.fetchNotifications();

        expect(notifications, isEmpty);
        expect(requestCount, 0);
      });
    });

    // Checks that comment and like notifications are shown latest first.
    test('combines comment and like notifications latest first', () async {
      final databaseRequests = <http.Request>[];

      final mockHttpClient = MockClient((request) async {
        databaseRequests.add(request);

        if (request.url.path.endsWith('/comments')) {
          return http.Response(
            jsonEncode([
              {
                'comments_id': 'comment1',
                'user_id': 'commenter-123456',
                'body': 'Great fit',
                'created_at': '2026-01-01T10:00:00Z',
                'storage_key': 'owner-123/post1',
              },
              {
                'comments_id': 'self-comment',
                'user_id': 'owner-123',
                'body': 'My own comment',
                'created_at': '2026-01-01T12:00:00Z',
                'storage_key': 'owner-123/post1',
              },
            ]),
            200,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }

        if (request.url.path.endsWith('/post_likes')) {
          return http.Response(
            jsonEncode([
              {
                'post_like_id': 'like1',
                'user_id': 'liker-123456',
                'created_at': '2026-01-01T11:00:00Z',
                'storage_key': 'owner-123/post1',
              },
              {
                'post_like_id': 'self-like',
                'user_id': 'owner-123',
                'created_at': '2026-01-01T13:00:00Z',
                'storage_key': 'owner-123/post1',
              },
            ]),
            200,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }

        if (request.url.path.endsWith('/user')) {
          return _userResponse(request);
        }

        return _notFound(request);
      });

      await _withTestSupabase(mockHttpClient, () async {
        final client = Supabase.instance.client;
        await _recoverSession(client);
        final repository = NotificationRepository();

        final notifications = await repository.fetchNotifications(limit: 25);

        expect(notifications, hasLength(2));
        expect(notifications[0].type, 'like');
        expect(notifications[0].id, 'like_like1');
        expect(notifications[0].actorUsername, 'lina');
        expect(notifications[1].type, 'comment');
        expect(notifications[1].id, 'comment_comment1');
        expect(notifications[1].actorUsername, 'cami');
        expect(notifications[1].commentPreview, 'Great fit');

        final commentsRequest = databaseRequests.firstWhere(
          (request) => request.url.path.endsWith('/comments'),
        );
        final likesRequest = databaseRequests.firstWhere(
          (request) => request.url.path.endsWith('/post_likes'),
        );
        expect(
          commentsRequest.url.queryParameters['storage_key'],
          'ilike.owner-123/%',
        );
        expect(
          likesRequest.url.queryParameters['storage_key'],
          'ilike.owner-123/%',
        );
      });
    });

    // Checks that missing user data still gives a simple fallback name.
    test('uses fallback user names and handles invalid dates', () async {
      final mockHttpClient = MockClient((request) async {
        if (request.url.path.endsWith('/comments')) {
          return http.Response(
            jsonEncode([
              {
                'comments_id': 'comment1',
                'user_id': 'abc123456789',
                'body': 'Fallback comment',
                'created_at': 'not-a-date',
                'storage_key': 'owner-123/post1',
              },
            ]),
            200,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }

        if (request.url.path.endsWith('/post_likes')) {
          return http.Response(
            jsonEncode([
              {
                'post_like_id': 'like1',
                'user_id': 'xyz123456789',
                'created_at': 'not-a-date',
                'storage_key': 'owner-123/post1',
              },
            ]),
            200,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }

        if (request.url.path.endsWith('/user')) {
          return http.Response(
            'null',
            200,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }

        return _notFound(request);
      });

      await _withTestSupabase(mockHttpClient, () async {
        final client = Supabase.instance.client;
        await _recoverSession(client);
        final repository = NotificationRepository();

        final notifications = await repository.fetchNotifications();

        final comment = notifications.firstWhere(
          (item) => item.type == 'comment',
        );
        final like = notifications.firstWhere((item) => item.type == 'like');
        expect(comment.actorUsername, 'user_abc12345');
        expect(like.actorUsername, 'user_xyz12345');
      });
    });
  });

  group('NotificationRepository fetchUnreadCount', () {
    // Checks that unread count only includes items after the last read time.
    test('counts only notifications after the last read time', () async {
      final lastRead =
          DateTime.parse('2026-01-01T10:30:00Z').millisecondsSinceEpoch;

      final mockHttpClient = MockClient((request) async {
        if (request.url.path.endsWith('/comments')) {
          return http.Response(
            jsonEncode([
              {
                'comments_id': 'old-comment',
                'user_id': 'commenter-123456',
                'body': 'Old comment',
                'created_at': '2026-01-01T10:00:00Z',
                'storage_key': 'owner-123/post1',
              },
            ]),
            200,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }

        if (request.url.path.endsWith('/post_likes')) {
          return http.Response(
            jsonEncode([
              {
                'post_like_id': 'new-like',
                'user_id': 'liker-123456',
                'created_at': '2026-01-01T11:00:00Z',
                'storage_key': 'owner-123/post1',
              },
            ]),
            200,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }

        if (request.url.path.endsWith('/user')) {
          return _userResponse(request);
        }

        return _notFound(request);
      });

      await _withTestSupabase(mockHttpClient, () async {
        final client = Supabase.instance.client;
        await _recoverSession(
          client,
          userMetadata: {'last_notif_read': lastRead.toString()},
        );
        final repository = NotificationRepository();

        final unread = await repository.fetchUnreadCount();

        expect(unread, 1);
      });
    });
  });

  group('NotificationRepository markAllRead', () {
    // Checks that marking notifications read saves the last read time.
    test('updates the current user with a last read time', () async {
      http.Request? updateUserRequest;

      final mockHttpClient = MockClient((request) async {
        if (request.url.path.endsWith('/auth/v1/user') &&
            request.method == 'PUT') {
          updateUserRequest = request;

          return http.Response(
            jsonEncode({
              'id': 'owner-123',
              'app_metadata': {},
              'user_metadata': {'last_notif_read': 1893456000000},
              'aud': 'authenticated',
              'created_at': '2026-01-01T00:00:00Z',
            }),
            200,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }

        if (request.url.path.endsWith('/auth/v1/user') &&
            request.method == 'GET') {
          return http.Response(
            jsonEncode({
              'id': 'owner-123',
              'app_metadata': {},
              'user_metadata': {'last_notif_read': 1893456000000},
              'aud': 'authenticated',
              'created_at': '2026-01-01T00:00:00Z',
            }),
            200,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }

        return _notFound(request);
      });

      await _withTestSupabase(mockHttpClient, () async {
        final client = Supabase.instance.client;
        await _recoverSession(client);
        final repository = NotificationRepository();

        await repository.markAllRead();

        expect(updateUserRequest, isNotNull);
        final body =
            jsonDecode(updateUserRequest!.body) as Map<String, dynamic>;
        final userData = body['data'] as Map<String, dynamic>;
        expect(userData['last_notif_read'], isA<int>());
      });
    });
  });
}

Future<void> _withTestSupabase(
  http.Client httpClient,
  Future<void> Function() body,
) async {
  final supabase = await Supabase.initialize(
    url: 'https://example.supabase.co',
    anonKey: 'test-anon-key',
    httpClient: httpClient,
    authOptions: const FlutterAuthClientOptions(
      autoRefreshToken: false,
      authFlowType: AuthFlowType.implicit,
      detectSessionInUri: false,
      localStorage: EmptyLocalStorage(),
      pkceAsyncStorage: _EmptyAsyncStorage(),
    ),
    debug: false,
  );

  try {
    await body();
  } finally {
    await supabase.dispose();
  }
}

Future<void> _recoverSession(
  SupabaseClient client, {
  Map<String, dynamic> userMetadata = const {},
}) async {
  await client.auth.recoverSession(
    jsonEncode({
      'access_token': 'test-access-token',
      'expires_in': 3600,
      'refresh_token': 'test-refresh-token',
      'token_type': 'bearer',
      'user': {
        'id': 'owner-123',
        'app_metadata': {},
        'user_metadata': userMetadata,
        'aud': 'authenticated',
        'created_at': '2026-01-01T00:00:00Z',
      },
    }),
  );
}

class _EmptyAsyncStorage extends GotrueAsyncStorage {
  const _EmptyAsyncStorage();

  @override
  Future<String?> getItem({required String key}) async => null;

  @override
  Future<void> removeItem({required String key}) async {}

  @override
  Future<void> setItem({required String key, required String value}) async {}
}

http.Response _userResponse(http.Request request) {
  final userId =
      request.url.queryParameters['user_id']?.replaceFirst('eq.', '') ?? '';

  final userRows = {
    'commenter-123456': {
      'user_id': 'commenter-123456',
      'username': 'cami',
      'profile_pic_url': 'https://example.com/cami.jpg',
    },
    'liker-123456': {
      'user_id': 'liker-123456',
      'username': 'lina',
      'profile_pic_url': 'https://example.com/lina.jpg',
    },
  };

  return http.Response(
    jsonEncode(userRows[userId]),
    200,
    headers: {'content-type': 'application/json'},
    request: request,
  );
}

http.Response _notFound(http.Request request) {
  return http.Response(
    jsonEncode({'message': 'Unhandled test request: ${request.url}'}),
    404,
    headers: {'content-type': 'application/json'},
    request: request,
  );
}
