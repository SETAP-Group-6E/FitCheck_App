import 'dart:convert';

import 'package:fitcheck/Data/repositories/supabase_comment_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SupabaseCommentRepository fetchComments', () {
    // Checks that comments are loaded with the user's name and picture.
    test('loads comments with user name and picture', () async {
      http.Request? commentsRequest;

      final mockHttpClient = MockClient((request) async {
        if (request.url.path.endsWith('/comments')) {
          commentsRequest = request;

          return http.Response(
            jsonEncode([
              {
                'comments_id': 'comment1',
                'post_id': null,
                'user_id': 'user-123456789',
                'body': 'Nice fit',
                'created_at': '2026-01-01T00:00:00Z',
                'storage_key': 'owner/post1',
              },
            ]),
            200,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }

        if (request.url.path.endsWith('/user')) {
          return http.Response(
            jsonEncode({
              'user_id': 'user-123456789',
              'username': 'alex',
              'profile_pic_url': 'https://example.com/alex.jpg',
            }),
            200,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }

        return _notFound(request);
      });

      await _withTestSupabase(mockHttpClient, () async {
        final repository = SupabaseCommentRepository();

        final comments = await repository.fetchComments('owner/post1');

        expect(commentsRequest, isNotNull);
        expect(
          commentsRequest!.url.queryParameters['storage_key'],
          'eq.owner/post1',
        );
        expect(comments, hasLength(1));
        expect(comments.first['username'], 'alex');
        expect(
          comments.first['profile_image_url'],
          'https://example.com/alex.jpg',
        );
      });
    });

    // Checks that comments still load when there is no user id.
    test('returns comments when there is no user id', () async {
      var requestCount = 0;

      final mockHttpClient = MockClient((request) async {
        requestCount++;

        return http.Response(
          jsonEncode([
            {
              'comments_id': 'comment1',
              'post_id': null,
              'user_id': '',
              'body': 'Anonymous',
              'created_at': '2026-01-01T00:00:00Z',
              'storage_key': 'owner/post1',
            },
          ]),
          200,
          headers: {'content-type': 'application/json'},
          request: request,
        );
      });

      await _withTestSupabase(mockHttpClient, () async {
        final repository = SupabaseCommentRepository();

        final comments = await repository.fetchComments('owner/post1');

        expect(comments, hasLength(1));
        expect(requestCount, 1);
      });
    });

    // Checks that missing user data uses a fallback name and picture.
    test(
      'uses fallback username and picture when user data is missing',
      () async {
        final mockHttpClient = MockClient((request) async {
          if (request.url.path.endsWith('/comments')) {
            return http.Response(
              jsonEncode([
                {
                  'comments_id': 'comment1',
                  'post_id': null,
                  'user_id': 'user-123456789',
                  'body': 'Nice fit',
                  'created_at': '2026-01-01T00:00:00Z',
                  'storage_key': 'owner/post1',
                },
              ]),
              200,
              headers: {'content-type': 'application/json'},
              request: request,
            );
          }

          if (request.url.path.endsWith('/user')) {
            return http.Response(
              jsonEncode({
                'user_id': 'user-123456789',
                'username': ' ',
                'profile_pic_url': ' ',
              }),
              200,
              headers: {'content-type': 'application/json'},
              request: request,
            );
          }

          return _notFound(request);
        });

        await _withTestSupabase(mockHttpClient, () async {
          final repository = SupabaseCommentRepository();

          final comments = await repository.fetchComments('owner/post1');

          expect(comments.first['username'], 'user_user-123');
          expect(
            comments.first['profile_image_url'],
            contains(
              '/storage/v1/object/public/Avatars/user-123456789/avatar.jpg',
            ),
          );
        });
      },
    );
  });

  group('SupabaseCommentRepository fetchCommentCount', () {
    // Checks that the comment count is based on the fetched comments list.
    test('returns the number of fetched comments', () async {
      final mockHttpClient = MockClient((request) async {
        return http.Response(
          jsonEncode([
            {'comments_id': 'comment1', 'user_id': '', 'body': 'First'},
            {'comments_id': 'comment2', 'user_id': '', 'body': 'Second'},
          ]),
          200,
          headers: {'content-type': 'application/json'},
          request: request,
        );
      });

      await _withTestSupabase(mockHttpClient, () async {
        final repository = SupabaseCommentRepository();

        final count = await repository.fetchCommentCount('owner/post1');

        expect(count, 2);
      });
    });
  });

  group('SupabaseCommentRepository addComment', () {
    // Checks that a new comment is added and returned with user details.
    test('adds a comment and returns it with user details', () async {
      http.Request? insertRequest;

      final mockHttpClient = MockClient((request) async {
        if (request.url.path.endsWith('/comments')) {
          insertRequest = request;

          return http.Response(
            jsonEncode({
              'comments_id': 'comment1',
              'post_id': null,
              'storage_key': 'owner/post1',
              'user_id': 'user-123',
              'body': 'Looks good',
            }),
            201,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }

        if (request.url.path.endsWith('/user')) {
          return http.Response(
            jsonEncode({
              'username': 'alex',
              'profile_pic_url': 'https://example.com/alex.jpg',
            }),
            200,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }

        return _notFound(request);
      });

      await _withTestSupabase(mockHttpClient, () async {
        final repository = SupabaseCommentRepository();

        final inserted = await repository.addComment(
          'owner/post1',
          'user-123',
          'Looks good',
        );

        expect(insertRequest, isNotNull);
        final body = jsonDecode(insertRequest!.body) as Map<String, dynamic>;
        expect(body['post_id'], isNull);
        expect(body['storage_key'], 'owner/post1');
        expect(body['user_id'], 'user-123');
        expect(body['body'], 'Looks good');

        expect(inserted, isNotNull);
        expect(inserted!['username'], 'alex');
        expect(inserted['profile_image_url'], 'https://example.com/alex.jpg');
      });
    });

    // Checks that addComment returns null when Supabase returns no comment.
    test('returns null when Supabase returns no comment', () async {
      final mockHttpClient = MockClient((request) async {
        return http.Response(
          'null',
          200,
          headers: {'content-type': 'application/json'},
          request: request,
        );
      });

      await _withTestSupabase(mockHttpClient, () async {
        final repository = SupabaseCommentRepository();

        final inserted = await repository.addComment(
          'owner/post1',
          'user-123',
          'Looks good',
        );

        expect(inserted, isNull);
      });
    });

    // Checks that a new comment can also use fallback user details.
    test('uses fallback user details when the user has no profile', () async {
      final mockHttpClient = MockClient((request) async {
        if (request.url.path.endsWith('/comments')) {
          return http.Response(
            jsonEncode({
              'comments_id': 'comment1',
              'post_id': null,
              'storage_key': 'owner/post1',
              'user_id': 'user-123456789',
              'body': 'Looks good',
            }),
            201,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }

        if (request.url.path.endsWith('/user')) {
          return http.Response(
            jsonEncode({'username': ' ', 'profile_pic_url': ' '}),
            200,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }

        return _notFound(request);
      });

      await _withTestSupabase(mockHttpClient, () async {
        final repository = SupabaseCommentRepository();

        final inserted = await repository.addComment(
          'owner/post1',
          'user-123456789',
          'Looks good',
        );

        expect(inserted, isNotNull);
        expect(inserted!['username'], 'user_user-123');
        expect(
          inserted['profile_image_url'],
          contains(
            '/storage/v1/object/public/Avatars/user-123456789/avatar.jpg',
          ),
        );
      });
    });
  });

  group('SupabaseCommentRepository deleteComment', () {
    // Checks that deletes are scoped by both comment id and user id.
    test('deletes a comment by comment id and current user id', () async {
      http.Request? deleteRequest;

      final mockHttpClient = MockClient((request) async {
        deleteRequest = request;

        return http.Response('', 204, request: request);
      });

      await _withTestSupabase(mockHttpClient, () async {
        final repository = SupabaseCommentRepository();

        final deleted = await repository.deleteComment('comment1', 'user-123');

        expect(deleted, true);
        expect(deleteRequest, isNotNull);
        expect(
          deleteRequest!.url.queryParameters['comments_id'],
          'eq.comment1',
        );
        expect(deleteRequest!.url.queryParameters['user_id'], 'eq.user-123');
      });
    });

    // Checks that delete failures are converted to a false result.
    test('returns false when deleting a comment fails', () async {
      final mockHttpClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'message': 'Delete failed',
            'details': 'Fake database error for test',
            'hint': null,
            'code': 'TEST_ERROR',
          }),
          500,
          headers: {'content-type': 'application/json'},
          request: request,
        );
      });

      await _withTestSupabase(mockHttpClient, () async {
        final repository = SupabaseCommentRepository();

        final deleted = await repository.deleteComment('comment1', 'user-123');

        expect(deleted, false);
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

class _EmptyAsyncStorage extends GotrueAsyncStorage {
  const _EmptyAsyncStorage();

  @override
  Future<String?> getItem({required String key}) async => null;

  @override
  Future<void> removeItem({required String key}) async {}

  @override
  Future<void> setItem({required String key, required String value}) async {}
}

http.Response _notFound(http.Request request) {
  return http.Response(
    jsonEncode({'message': 'Unhandled test request: ${request.url}'}),
    404,
    headers: {'content-type': 'application/json'},
    request: request,
  );
}
