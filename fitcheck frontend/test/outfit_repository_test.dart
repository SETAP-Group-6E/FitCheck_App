import 'dart:convert';

import 'package:fitcheck/Data/repositories/supabase_wardrobe_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('SupabaseWardrobeRepository addOutfit', () {
    test('creates an outfit and links one item', () async {
      final databaseRequests = <http.Request>[];

      final mockHttpClient = MockClient((request) async {
        databaseRequests.add(request);

        if (request.url.path.endsWith('/outfit')) {
          return http.Response(
            jsonEncode({'outfit_id': 'outfit1'}),
            201,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }

        return http.Response('', 201, request: request);
      });

      final supabase = await _createSignedInSupabase(mockHttpClient);
      final repository = SupabaseWardrobeRepository(supabase);

      await repository.addOutfit(
        name: 'Winter fit',
        description: 'Warm outfit',
        isOwned: true,
        clothingItemIds: ['item1'],
      );

      expect(databaseRequests, hasLength(2));

      final outfitBody =
          jsonDecode(databaseRequests[0].body) as Map<String, dynamic>;
      expect(outfitBody['user_id'], 'user-123');
      expect(outfitBody['name'], 'Winter fit');
      expect(outfitBody['description'], 'Warm outfit');
      expect(outfitBody['is_owned'], true);

      final linkBody = jsonDecode(databaseRequests[1].body) as List<dynamic>;
      expect(linkBody, hasLength(1));
      expect(linkBody.first['outfit_id'], 'outfit1');
      expect(linkBody.first['item_id'], 'item1');
      expect(linkBody.first['user_id'], 'user-123');

      await supabase.dispose();
    });

    test('creates one link for each selected item', () async {
      final databaseRequests = <http.Request>[];

      final mockHttpClient = MockClient((request) async {
        databaseRequests.add(request);

        if (request.url.path.endsWith('/outfit')) {
          return http.Response(
            jsonEncode({'outfit_id': 'outfit1'}),
            201,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }

        return http.Response('', 201, request: request);
      });

      final supabase = await _createSignedInSupabase(mockHttpClient);
      final repository = SupabaseWardrobeRepository(supabase);

      await repository.addOutfit(
        name: 'Layered fit',
        description: 'Three item outfit',
        isOwned: true,
        clothingItemIds: ['item1', 'item2', 'item3'],
      );

      expect(databaseRequests, hasLength(2));

      final linkBody = jsonDecode(databaseRequests[1].body) as List<dynamic>;
      expect(linkBody, hasLength(3));
      expect(linkBody[0]['item_id'], 'item1');
      expect(linkBody[1]['item_id'], 'item2');
      expect(linkBody[2]['item_id'], 'item3');
      expect(linkBody.every((link) => link['user_id'] == 'user-123'), true);

      await supabase.dispose();
    });

    test(
        'creates an outfit without item links when no items are selected',
        () async {
      http.Request? capturedRequest;

      final mockHttpClient = MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode({'outfit_id': 'outfit1'}),
          201,
          headers: {'content-type': 'application/json'},
          request: request,
        );
      });

      final supabase = await _createSignedInSupabase(mockHttpClient);
      final repository = SupabaseWardrobeRepository(supabase);

      await repository.addOutfit(
        name: 'Simple fit',
        description: 'No linked items',
        isOwned: false,
        clothingItemIds: const [],
      );

      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.url.path.endsWith('/outfit'), true);
      expect(capturedRequest!.body, contains('Simple fit'));

      await supabase.dispose();
    });

    test('throws an Exception when the outfit insert does not return an id',
        () async {
      final mockHttpClient = MockClient((request) async {
        return http.Response(
          jsonEncode({}),
          201,
          headers: {'content-type': 'application/json'},
          request: request,
        );
      });

      final supabase = await _createSignedInSupabase(mockHttpClient);
      final repository = SupabaseWardrobeRepository(supabase);

      await expectLater(
        repository.addOutfit(
          name: 'Broken fit',
          description: 'Missing id',
          isOwned: true,
          clothingItemIds: ['item1'],
        ),
        throwsA(isA<Exception>()),
      );

      await supabase.dispose();
    });

    test('throws a PostgrestException when the outfit insert fails', () async {
      final mockHttpClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'message': 'Insert failed',
            'details': 'Fake database error for test',
            'hint': null,
            'code': 'TEST_ERROR',
          }),
          500,
          headers: {'content-type': 'application/json'},
          request: request,
        );
      });

      final supabase = await _createSignedInSupabase(mockHttpClient);
      final repository = SupabaseWardrobeRepository(supabase);

      await expectLater(
        repository.addOutfit(
          name: 'Winter fit',
          description: 'Warm outfit',
          isOwned: true,
          clothingItemIds: ['item1'],
        ),
        throwsA(isA<PostgrestException>()),
      );

      await supabase.dispose();
    });

    test(
        'throws a PostgrestException when a linked item belongs to a different user',
        () async {
      final databaseRequests = <http.Request>[];

      final mockHttpClient = MockClient((request) async {
        databaseRequests.add(request);

        if (request.url.path.endsWith('/outfit')) {
          return http.Response(
            jsonEncode({'outfit_id': 'outfit1'}),
            201,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }

        return http.Response(
          jsonEncode({
            'message': 'Insert failed',
            'details': 'Linked item belongs to another user',
            'hint': null,
            'code': 'TEST_ERROR',
          }),
          500,
          headers: {'content-type': 'application/json'},
          request: request,
        );
      });

      final supabase = await _createSignedInSupabase(mockHttpClient);
      final repository = SupabaseWardrobeRepository(supabase);

      await expectLater(
        repository.addOutfit(
          name: 'Shared item fit',
          description: 'Includes an item owned by someone else',
          isOwned: true,
          clothingItemIds: ['item-owned-by-u999'],
        ),
        throwsA(isA<PostgrestException>()),
      );

      expect(databaseRequests, hasLength(2));

      final linkBody = jsonDecode(databaseRequests[1].body) as List<dynamic>;
      expect(linkBody.first['item_id'], 'item-owned-by-u999');
      expect(linkBody.first['user_id'], 'user-123');

      await supabase.dispose();
    });
  });

  group('SupabaseWardrobeRepository updateOutfit', () {
    test('updates only the provided outfit fields', () async {
      http.Request? capturedRequest;

      final mockHttpClient = MockClient((request) async {
        capturedRequest = request;
        return http.Response('', 204, request: request);
      });

      final supabase = await _createSignedInSupabase(mockHttpClient);
      final repository = SupabaseWardrobeRepository(supabase);

      await repository.updateOutfit(
        id: 'outfit1',
        name: 'Updated fit',
        description: 'New description',
        isOwned: false,
      );

      expect(capturedRequest, isNotNull);
      final body = jsonDecode(capturedRequest!.body) as Map<String, dynamic>;
      expect(body['name'], 'Updated fit');
      expect(body['description'], 'New description');
      expect(body['is_owned'], false);
      expect(body.containsKey('clothing_item_ids'), false);
      expect(
        capturedRequest!.url.queryParameters['outfit_id'],
        'eq.outfit1',
      );
      expect(capturedRequest!.url.queryParameters['user_id'], 'eq.user-123');

      await supabase.dispose();
    });

    test('replaces outfit items when a new list is provided', () async {
      final databaseRequests = <http.Request>[];

      final mockHttpClient = MockClient((request) async {
        databaseRequests.add(request);

        if (request.url.path.endsWith('/outfit_item') &&
            request.method == 'DELETE') {
          return http.Response('', 204, request: request);
        }

        if (request.url.path.endsWith('/outfit_item') &&
            request.method == 'POST') {
          return http.Response('', 201, request: request);
        }

        return http.Response('', 204, request: request);
      });

      final supabase = await _createSignedInSupabase(mockHttpClient);
      final repository = SupabaseWardrobeRepository(supabase);

      await repository.updateOutfit(
        id: 'outfit1',
        clothingItemIds: ['item2', 'item3'],
      );

      expect(databaseRequests.length, greaterThanOrEqualTo(2));
      expect(
        databaseRequests.any((request) =>
            request.url.path.endsWith('/outfit_item') &&
            request.method == 'DELETE'),
        true,
      );
      expect(
        databaseRequests.any((request) =>
            request.url.path.endsWith('/outfit_item') &&
            request.method == 'POST'),
        true,
      );

      final insertRequest = databaseRequests.firstWhere(
        (request) =>
            request.url.path.endsWith('/outfit_item') && request.method == 'POST',
      );
      final payload = jsonDecode(insertRequest.body) as List<dynamic>;
      expect(payload, hasLength(2));
      expect(payload[0]['item_id'], 'item2');
      expect(payload[1]['item_id'], 'item3');
      expect(payload.every((row) => row['user_id'] == 'user-123'), true);

      await supabase.dispose();
    });

    test('clears outfit items when an empty list is provided', () async {
      final databaseRequests = <http.Request>[];

      final mockHttpClient = MockClient((request) async {
        databaseRequests.add(request);
        return http.Response('', 204, request: request);
      });

      final supabase = await _createSignedInSupabase(mockHttpClient);
      final repository = SupabaseWardrobeRepository(supabase);

      await repository.updateOutfit(
        id: 'outfit1',
        clothingItemIds: const [],
      );

      expect(databaseRequests.length, 1);
      expect(databaseRequests.first.url.path.endsWith('/outfit_item'), true);
      expect(databaseRequests.first.method, 'DELETE');

      await supabase.dispose();
    });

    test('does not call the database when no fields are provided', () async {
      var requestCount = 0;

      final mockHttpClient = MockClient((request) async {
        requestCount++;
        return http.Response('', 204, request: request);
      });

      final supabase = await _createSignedInSupabase(mockHttpClient);
      final repository = SupabaseWardrobeRepository(supabase);

      await repository.updateOutfit(id: 'outfit1');

      expect(requestCount, 0);

      await supabase.dispose();
    });

    test('throws a PostgrestException when the outfit update fails', () async {
      final mockHttpClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'message': 'Update failed',
            'details': 'Fake database error for test',
            'hint': null,
            'code': 'TEST_ERROR',
          }),
          500,
          headers: {'content-type': 'application/json'},
          request: request,
        );
      });

      final supabase = await _createSignedInSupabase(mockHttpClient);
      final repository = SupabaseWardrobeRepository(supabase);

      await expectLater(
        repository.updateOutfit(
          id: 'outfit1',
          name: 'Updated fit',
        ),
        throwsA(isA<PostgrestException>()),
      );

      await supabase.dispose();
    });
  });

  group('SupabaseWardrobeRepository removeOutfit', () {
    test('deletes outfit items and the outfit using the current user id',
        () async {
      final databaseRequests = <http.Request>[];

      final mockHttpClient = MockClient((request) async {
        databaseRequests.add(request);
        return http.Response('', 204, request: request);
      });

      final supabase = await _createSignedInSupabase(mockHttpClient);
      final repository = SupabaseWardrobeRepository(supabase);

      await repository.removeOutfit(id: 'outfit1');

      expect(databaseRequests, hasLength(2));
      expect(databaseRequests[0].url.path.endsWith('/outfit_item'), true);
      expect(databaseRequests[1].url.path.endsWith('/outfit'), true);
      expect(databaseRequests[0].url.queryParameters['outfit_id'], 'eq.outfit1');
      expect(databaseRequests[0].url.queryParameters['user_id'], 'eq.user-123');
      expect(databaseRequests[1].url.queryParameters['outfit_id'], 'eq.outfit1');
      expect(databaseRequests[1].url.queryParameters['user_id'], 'eq.user-123');

      await supabase.dispose();
    });

    test('throws a PostgrestException when the outfit delete fails', () async {
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

      final supabase = await _createSignedInSupabase(mockHttpClient);
      final repository = SupabaseWardrobeRepository(supabase);

      await expectLater(
        repository.removeOutfit(id: 'outfit1'),
        throwsA(isA<PostgrestException>()),
      );

      await supabase.dispose();
    });
  });

  group('SupabaseWardrobeRepository getOutfits', () {
    test('returns existing outfits', () async {
      http.Request? capturedRequest;

      final mockHttpClient = MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode([
            {
              'outfit_id': 'outfit1',
              'name': 'Winter fit',
              'description': 'Warm outfit',
              'is_owned': true,
            },
            {
              'outfit_id': 'outfit2',
              'name': 'Summer fit',
              'description': 'Light outfit',
              'is_owned': false,
            },
          ]),
          200,
          headers: {'content-type': 'application/json'},
          request: request,
        );
      });

      final supabase = await _createSignedInSupabase(mockHttpClient);
      final repository = SupabaseWardrobeRepository(supabase);

      final outfits = await repository.getOutfits();

      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.url.queryParameters['user_id'], 'eq.user-123');
      expect(outfits, hasLength(2));
      expect(outfits[0]['name'], 'Winter fit');
      expect(outfits[1]['name'], 'Summer fit');

      await supabase.dispose();
    });

    test('returns an empty list when there are no outfits', () async {
      final mockHttpClient = MockClient((request) async {
        return http.Response(
          jsonEncode([]),
          200,
          headers: {'content-type': 'application/json'},
          request: request,
        );
      });

      final supabase = await _createSignedInSupabase(mockHttpClient);
      final repository = SupabaseWardrobeRepository(supabase);

      final outfits = await repository.getOutfits();

      expect(outfits, isEmpty);

      await supabase.dispose();
    });

    test('throws an Exception when there is no logged-in user', () async {
      final mockHttpClient = MockClient((request) async {
        return http.Response('', 200, request: request);
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
      final repository = SupabaseWardrobeRepository(supabase);

      await expectLater(
        repository.getOutfits(),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('No authenticated user'),
          ),
        ),
      );

      await supabase.dispose();
    });
  });
}

Future<SupabaseClient> _createSignedInSupabase(http.Client httpClient) async {
  final supabase = SupabaseClient(
    'https://example.supabase.co',
    'test-anon-key',
    authOptions: const AuthClientOptions(
      autoRefreshToken: false,
      authFlowType: AuthFlowType.implicit,
    ),
    httpClient: httpClient,
  );

  await supabase.auth.recoverSession(
    jsonEncode({
      'access_token': 'test-access-token',
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
  );

  return supabase;
}