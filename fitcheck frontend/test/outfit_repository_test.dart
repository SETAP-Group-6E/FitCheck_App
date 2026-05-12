import 'dart:convert';

import 'package:fitcheck/Data/repositories/supabase_wardrobe_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('SupabaseWardrobeRepository addOutfit', () {
    // Test Plan row 51: valid outfit creation.
    // Checks that an outfit is created and linked to one wardrobe item.
    test('creates an outfit and links one item', () async {
      final databaseRequests = <http.Request>[];

      final mockHttpClient = MockClient((request) async {
        databaseRequests.add(request);

        // addOutfit makes two database requests:
        // 1. insert the outfit and get its new outfit_id
        // 2. insert the outfit_item link using that outfit_id

        if (request.url.path.endsWith('/outfit')) {
          // Fake successful outfit insert response with the new outfit id.
          return http.Response(
            jsonEncode({'outfit_id': 'outfit1'}),
            201,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }

        // Fake successful outfit_item insert response.
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

    // Test Plan row 52: outfit with multiple items.
    // Checks that one outfit_item link is created for each selected item.
    test('creates one link for each selected item', () async {
      final databaseRequests = <http.Request>[];

      final mockHttpClient = MockClient((request) async {
        databaseRequests.add(request);

        if (request.url.path.endsWith('/outfit')) {
          // Fake successful outfit insert response with the new outfit id.
          return http.Response(
            jsonEncode({'outfit_id': 'outfit1'}),
            201,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }

        // Fake successful outfit_item insert response.
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

    // Test Plan row 54: missing outfit id.
    // Checks that outfit creation fails safely if Supabase returns no outfit_id.
    test('throws an Exception when no outfit id is returned', () async {
      final mockHttpClient = MockClient((request) async {
        // Fake outfit insert response without outfit_id.
        return http.Response(
          jsonEncode({'name': 'Winter fit'}),
          201,
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
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('Failed to create outfit'),
          ),
        ),
      );

      await supabase.dispose();
    });
  });

  group('SupabaseWardrobeRepository updateOutfit', () {
    // Test Plan row 57: replace outfit items.
    // Checks that old links are removed and the new item link is inserted.
    test('replaces outfit item links', () async {
      final databaseRequests = <http.Request>[];

      final mockHttpClient = MockClient((request) async {
        databaseRequests.add(request);

        // Fake successful update/delete/insert responses.
        return http.Response('', 204, request: request);
      });

      final supabase = await _createSignedInSupabase(mockHttpClient);
      final repository = SupabaseWardrobeRepository(supabase);

      await repository.updateOutfit(
        id: 'outfit1',
        name: 'Updated fit',
        description: 'Updated description',
        isOwned: false,
        clothingItemIds: ['item2'],
      );

      expect(databaseRequests, hasLength(3));

      final outfitUpdateBody =
          jsonDecode(databaseRequests[0].body) as Map<String, dynamic>;
      expect(outfitUpdateBody['name'], 'Updated fit');
      expect(outfitUpdateBody['description'], 'Updated description');
      expect(outfitUpdateBody['is_owned'], false);
      expect(
        databaseRequests[0].url.queryParameters['outfit_id'],
        'eq.outfit1',
      );
      expect(databaseRequests[0].url.queryParameters['user_id'], 'eq.user-123');

      expect(databaseRequests[1].url.path.endsWith('/outfit_item'), true);
      expect(
        databaseRequests[1].url.queryParameters['outfit_id'],
        'eq.outfit1',
      );
      expect(databaseRequests[1].url.queryParameters['user_id'], 'eq.user-123');

      final newLinkBody = jsonDecode(databaseRequests[2].body) as List<dynamic>;
      expect(newLinkBody, hasLength(1));
      expect(newLinkBody.first['outfit_id'], 'outfit1');
      expect(newLinkBody.first['item_id'], 'item2');
      expect(newLinkBody.first['user_id'], 'user-123');

      await supabase.dispose();
    });

    // Test Plan row 60: clear outfit items.
    // Checks that old links are removed and no new links are inserted.
    test('clears all outfit item links', () async {
      final databaseRequests = <http.Request>[];

      final mockHttpClient = MockClient((request) async {
        databaseRequests.add(request);

        // Fake successful outfit_item delete response.
        return http.Response('', 204, request: request);
      });

      final supabase = await _createSignedInSupabase(mockHttpClient);
      final repository = SupabaseWardrobeRepository(supabase);

      await repository.updateOutfit(id: 'outfit1', clothingItemIds: <String>[]);

      expect(databaseRequests, hasLength(1));
      expect(databaseRequests[0].url.path.endsWith('/outfit_item'), true);
      expect(
        databaseRequests[0].url.queryParameters['outfit_id'],
        'eq.outfit1',
      );
      expect(databaseRequests[0].url.queryParameters['user_id'], 'eq.user-123');

      await supabase.dispose();
    });

    // Test Plan row 63: different user outfit.
    // Checks that outfit updates are filtered by outfit id and current user id.
    test('uses the current user id when updating an outfit', () async {
      http.Request? capturedRequest;

      final mockHttpClient = MockClient((request) async {
        capturedRequest = request;

        // Fake successful database update response.
        return http.Response('', 204, request: request);
      });

      final supabase = await _createSignedInSupabase(mockHttpClient);
      final repository = SupabaseWardrobeRepository(supabase);

      await repository.updateOutfit(
        id: 'outfit-owned-by-someone-else',
        name: 'New outfit name',
      );

      expect(capturedRequest, isNotNull);
      expect(
        capturedRequest!.url.queryParameters['outfit_id'],
        'eq.outfit-owned-by-someone-else',
      );
      expect(capturedRequest!.url.queryParameters['user_id'], 'eq.user-123');

      await supabase.dispose();
    });
  });

  group('SupabaseWardrobeRepository removeOutfit', () {
    // Test Plan row 66: valid outfit deletion.
    // Checks that outfit links are deleted before the outfit row.
    test('deletes outfit item links before deleting the outfit', () async {
      final databaseRequests = <http.Request>[];

      final mockHttpClient = MockClient((request) async {
        databaseRequests.add(request);

        // Fake successful database delete response.
        return http.Response('', 204, request: request);
      });

      final supabase = await _createSignedInSupabase(mockHttpClient);
      final repository = SupabaseWardrobeRepository(supabase);

      await repository.removeOutfit(id: 'outfit1');

      expect(databaseRequests, hasLength(2));
      expect(databaseRequests[0].url.path.endsWith('/outfit_item'), true);
      expect(databaseRequests[1].url.path.endsWith('/outfit'), true);
      expect(
        databaseRequests[0].url.queryParameters['outfit_id'],
        'eq.outfit1',
      );
      expect(
        databaseRequests[1].url.queryParameters['outfit_id'],
        'eq.outfit1',
      );
      expect(databaseRequests[0].url.queryParameters['user_id'], 'eq.user-123');
      expect(databaseRequests[1].url.queryParameters['user_id'], 'eq.user-123');

      await supabase.dispose();
    });

    // Test Plan row 69: database delete error.
    // Checks that removeOutfit passes a database error back to the app.
    test('throws a PostgrestException when outfit delete fails', () async {
      final mockHttpClient = MockClient((request) async {
        // Fake failed database delete response.
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
    // Test Plan row 72: existing outfits.
    // Checks that outfit rows returned by the database are returned by the repository.
    test('returns existing outfits', () async {
      final mockHttpClient = MockClient((request) async {
        // Fake database response with two outfit rows.
        return http.Response(
          jsonEncode([
            {'outfit_id': 'outfit1', 'name': 'Winter fit'},
            {'outfit_id': 'outfit2', 'name': 'Summer fit'},
          ]),
          200,
          headers: {'content-type': 'application/json'},
          request: request,
        );
      });

      final supabase = await _createSignedInSupabase(mockHttpClient);
      final repository = SupabaseWardrobeRepository(supabase);

      final outfits = await repository.getOutfits();

      expect(outfits, hasLength(2));
      expect(outfits[0]['name'], 'Winter fit');
      expect(outfits[1]['name'], 'Summer fit');

      await supabase.dispose();
    });

    // Test Plan row 75: empty outfit list.
    // Checks that the repository returns an empty list when no outfits exist.
    test('returns an empty list when there are no outfits', () async {
      final mockHttpClient = MockClient((request) async {
        // Fake database response with no outfits.
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
  });
}

Future<SupabaseClient> _createSignedInSupabase(http.Client httpClient) async {
  // This helper avoids repeating the fake Supabase login setup in every test.
  final supabase = SupabaseClient(
    'https://example.supabase.co',
    'test-anon-key',
    authOptions: const AuthClientOptions(
      autoRefreshToken: false,
      authFlowType: AuthFlowType.implicit,
    ),
    httpClient: httpClient,
  );

  // Outfit methods need a current user, so the test creates a fake login session.
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
