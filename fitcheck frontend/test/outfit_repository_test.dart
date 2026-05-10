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
