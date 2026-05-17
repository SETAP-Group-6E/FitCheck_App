import 'dart:convert';

import 'package:fitcheck/Data/repositories/supabase_wardrobe_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('SupabaseWardrobeRepository addClothingItem', () {
    // Test Plan row 14: valid wardrobe item creation.
    // Checks that a new wardrobe item is saved with the current user's id.
    test('sends item details with the current user id', () async {
      http.Request? capturedRequest;

      final mockHttpClient = MockClient((request) async {
        capturedRequest = request;

        // Fake successful database insert response.
        return http.Response(
          '',
          201,
          request: request,
        ); // 201 Created status code.
      });

      final supabase = await _createSignedInSupabase(mockHttpClient);
      final repository = SupabaseWardrobeRepository(supabase);

      await repository.addClothingItem(
        photoUrl: 'https://example.com/coat.jpg',
        title: 'Black coat',
        wearType: 'Casual',
        fabricMaterial: 'Wool',
        warmthRating: 3,
        waterResistance: true,
        layerCategory: 'Outer layer',
      );

      expect(capturedRequest, isNotNull);

      final body = jsonDecode(capturedRequest!.body) as Map<String, dynamic>;
      expect(body['user_id'], 'user-123');
      expect(body['title'], 'Black coat');
      expect(body['wear_type'], 'Casual');
      expect(body['fabric_material'], 'Wool');
      expect(body['warmth_rating'], 3);
      expect(body['water_resistant'], true);
      expect(body['layer_category'], 'Outer layer');
      expect(body['photo_url'], 'https://example.com/coat.jpg');

      await supabase.dispose();
    });

    // Test Plan row 17: optional photo missing.
    // Checks that an item can be saved without sending a photo_url field.
    test('does not send photoUrl when no photo is provided', () async {
      http.Request? capturedRequest;

      final mockHttpClient = MockClient((request) async {
        capturedRequest = request;

        // Fake successful database insert response.
        return http.Response(
          '',
          201,
          request: request,
        ); // 201 Created status code.
      });

      final supabase = await _createSignedInSupabase(mockHttpClient);
      final repository = SupabaseWardrobeRepository(supabase);

      await repository.addClothingItem(
        photoUrl: '',
        title: 'White t-shirt',
        wearType: 'Casual',
        fabricMaterial: 'Cotton',
        warmthRating: 1,
        waterResistance: false,
        layerCategory: 'Base layer',
      );

      expect(capturedRequest, isNotNull);

      final body = jsonDecode(capturedRequest!.body) as Map<String, dynamic>;
      expect(body['user_id'], 'user-123');
      expect(body['title'], 'White t-shirt');
      expect(body.containsKey('photo_url'), false);

      await supabase.dispose();
    });

    // Test Plan row 18: warmth boundary values.
    // Checks that the lowest and highest warmth ratings are sent correctly.
    test('keeps minimum and maximum warmth ratings', () async {
      final capturedRequests = <http.Request>[];

      final mockHttpClient = MockClient((request) async {
        capturedRequests.add(request);

        // Fake successful database insert response.
        return http.Response(
          '',
          201,
          request: request,
        ); // 201 Created status code.
      });

      final supabase = await _createSignedInSupabase(mockHttpClient);
      final repository = SupabaseWardrobeRepository(supabase);

      await repository.addClothingItem(
        photoUrl: '',
        title: 'Light t-shirt',
        wearType: 'Casual',
        fabricMaterial: 'Cotton',
        warmthRating: 1,
        waterResistance: false,
        layerCategory: 'Base layer',
      );

      await repository.addClothingItem(
        photoUrl: '',
        title: 'Winter coat',
        wearType: 'Outdoor',
        fabricMaterial: 'Wool',
        warmthRating: 5,
        waterResistance: true,
        layerCategory: 'Outer layer',
      );

      final firstBody =
          jsonDecode(capturedRequests[0].body) as Map<String, dynamic>;
      final secondBody =
          jsonDecode(capturedRequests[1].body) as Map<String, dynamic>;

      expect(firstBody['warmth_rating'], 1);
      expect(secondBody['warmth_rating'], 5);

      await supabase.dispose();
    });

    // Test Plan row 20: database insert error.
    // Checks that addClothingItem passes a database error back to the app.
    test(
      'throws a PostgrestException when the database insert fails',
      () async {
        final mockHttpClient = MockClient((request) async {
          // Fake failed database insert response.
          return http.Response(
            jsonEncode({
              'message': 'Insert failed',
              'details': 'Fake database error for test',
              'hint': null,
              'code': 'TEST_ERROR',
            }),
            500, // Internal Server Error status code.
            headers: {'content-type': 'application/json'},
            request: request,
          );
        });

        final supabase = await _createSignedInSupabase(mockHttpClient);
        final repository = SupabaseWardrobeRepository(supabase);

        await expectLater(
          repository.addClothingItem(
            photoUrl: '',
            title: 'Black coat',
            wearType: 'Casual',
            fabricMaterial: 'Wool',
            warmthRating: 3,
            waterResistance: false,
            layerCategory: 'Outer layer',
          ),
          throwsA(isA<PostgrestException>()),
        );

        await supabase.dispose();
      },
    );
  });

  group('SupabaseWardrobeRepository updateClothingItem', () {
    // Test Plan row 23: valid wardrobe item update.
    // Checks that only the fields provided are sent in the update.
    test('updates only the provided item fields', () async {
      http.Request? capturedRequest;

      final mockHttpClient = MockClient((request) async {
        capturedRequest = request;

        // Fake successful database update response.
        return http.Response(
          '',
          204,
          request: request,
        ); // 204 No Content status code for successful update.
      });

      final supabase = await _createSignedInSupabase(mockHttpClient);
      final repository = SupabaseWardrobeRepository(supabase);

      await repository.updateClothingItem(
        id: 'item1',
        title: 'Blue jeans',
        warmthRating: 2,
      );

      expect(capturedRequest, isNotNull);

      final body = jsonDecode(capturedRequest!.body) as Map<String, dynamic>;
      expect(body['title'], 'Blue jeans');
      expect(body['warmth_rating'], 2);
      expect(body.containsKey('wear_type'), false);
      expect(body.containsKey('fabric_material'), false);

      await supabase.dispose();
    });

    // Test Plan row 24: valid optional fields update.
    // Checks the other optional update fields.
    test('updates the remaining optional item fields', () async {
      http.Request? capturedRequest;

      final mockHttpClient = MockClient((request) async {
        capturedRequest = request;

        // Fake successful database update response.
        return http.Response(
          '',
          204,
          request: request,
        ); // 204 No Content status code.
      });

      final supabase = await _createSignedInSupabase(mockHttpClient);
      final repository = SupabaseWardrobeRepository(supabase);

      await repository.updateClothingItem(
        id: 'item1',
        photoUrl: 'https://example.com/updated.jpg',
        wearType: 'Smart',
        fabricMaterial: 'Denim',
        waterResistance: true,
        layerCategory: 'Middle layer',
      );

      expect(capturedRequest, isNotNull);

      final body = jsonDecode(capturedRequest!.body) as Map<String, dynamic>;
      expect(body['photo_url'], 'https://example.com/updated.jpg');
      expect(body['wear_type'], 'Smart');
      expect(body['fabric_material'], 'Denim');
      expect(body['water_resistant'], true);
      expect(body['layer_category'], 'Middle layer');

      await supabase.dispose();
    });

    // Test Plan row 27: no fields changed.
    // Checks that no database request is made when there is nothing to update.
    test('does not call the database when no fields are provided', () async {
      var requestCount = 0;

      final mockHttpClient = MockClient((request) async {
        requestCount++;

        // This response should not be used because no request should be made.
        return http.Response('', 204, request: request);
      });

      final supabase = await _createSignedInSupabase(mockHttpClient);
      final repository = SupabaseWardrobeRepository(supabase);

      await repository.updateClothingItem(id: 'item1');

      expect(requestCount, 0);

      await supabase.dispose();
    });

    // Test Plan row 30: different user item.
    // Checks that updates are filtered by both item id and current user id.
    test('uses the current user id when updating an item', () async {
      http.Request? capturedRequest;

      final mockHttpClient = MockClient((request) async {
        capturedRequest = request;

        // Fake successful database update response.
        return http.Response('', 204, request: request);
      });

      final supabase = await _createSignedInSupabase(mockHttpClient);
      final repository = SupabaseWardrobeRepository(supabase);

      await repository.updateClothingItem(
        id: 'item-owned-by-someone-else',
        title: 'New title',
      );

      expect(capturedRequest, isNotNull);
      expect(
        capturedRequest!.url.queryParameters['item_id'],
        'eq.item-owned-by-someone-else',
      );
      expect(capturedRequest!.url.queryParameters['user_id'], 'eq.user-123');

      await supabase.dispose();
    });
  });

  group('SupabaseWardrobeRepository removeClothingItem', () {
    // Test Plan row 33: valid wardrobe item deletion.
    // Checks that deletion is filtered by both item id and current user id.
    test('deletes an item using the current user id', () async {
      http.Request? capturedRequest;

      final mockHttpClient = MockClient((request) async {
        capturedRequest = request;

        // Fake successful database delete response.
        return http.Response(
          '',
          204,
          request: request,
        ); // 204 No Content status code for successful delete.
      });

      final supabase = await _createSignedInSupabase(mockHttpClient);
      final repository = SupabaseWardrobeRepository(supabase);

      await repository.removeClothingItem(id: 'item1');

      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.url.queryParameters['item_id'], 'eq.item1');
      expect(capturedRequest!.url.queryParameters['user_id'], 'eq.user-123');

      await supabase.dispose();
    });

    // Test Plan row 36: database delete error.
    // Checks that removeClothingItem passes a database error back to the app.
    test(
      'throws a PostgrestException when the database delete fails',
      () async {
        final mockHttpClient = MockClient((request) async {
          // Fake failed database delete response.
          return http.Response(
            jsonEncode({
              'message': 'Delete failed',
              'details': 'Fake database error for test',
              'hint': null,
              'code': 'TEST_ERROR',
            }),
            500, // Internal Server Error status code.
            headers: {'content-type': 'application/json'},
            request: request,
          );
        });

        final supabase = await _createSignedInSupabase(mockHttpClient);
        final repository = SupabaseWardrobeRepository(supabase);

        await expectLater(
          repository.removeClothingItem(id: 'item1'),
          throwsA(isA<PostgrestException>()),
        );

        await supabase.dispose();
      },
    );
  });

  group('SupabaseWardrobeRepository getClothingItems', () {
    // Test Plan row 39: logged-in user.
    // Checks that wardrobe items are loaded using the current user's id.
    test('loads items for the current user', () async {
      http.Request? capturedRequest;

      final mockHttpClient = MockClient((request) async {
        capturedRequest = request;

        // Fake successful database select response.
        return http.Response(
          jsonEncode([
            {'item_id': 'item1', 'title': 'Black coat'},
          ]),
          200,
          headers: {'content-type': 'application/json'},
          request: request,
        );
      });

      final supabase = await _createSignedInSupabase(mockHttpClient);
      final repository = SupabaseWardrobeRepository(supabase);

      final items = await repository.getClothingItems();

      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.url.queryParameters['user_id'], 'eq.user-123');
      expect(items, hasLength(1));
      expect(items.first['title'], 'Black coat');

      await supabase.dispose();
    });

    // Test Plan row 45: existing wardrobe items.
    // Checks that item rows returned by the database are returned by the repository.
    test('returns existing wardrobe items', () async {
      final mockHttpClient = MockClient((request) async {
        // Fake database response with two wardrobe item rows.
        return http.Response(
          jsonEncode([
            {'item_id': 'item1', 'title': 'Black coat'},
            {'item_id': 'item2', 'title': 'Blue jeans'},
          ]),
          200, // OK status code.
          headers: {'content-type': 'application/json'},
          request: request,
        );
      });

      final supabase = await _createSignedInSupabase(mockHttpClient);
      final repository = SupabaseWardrobeRepository(supabase);

      final items = await repository.getClothingItems();

      expect(items, hasLength(2));
      expect(items[0]['title'], 'Black coat');
      expect(items[1]['title'], 'Blue jeans');

      await supabase.dispose();
    });
  });

  group('SupabaseWardrobeRepository authentication check', () {
    // Test Plan row 42: no logged-in user.
    // Checks that wardrobe actions cannot run without a current user.
    test('throws an Exception when there is no logged-in user', () async {
      final mockHttpClient = MockClient((request) async {
        // This response should not be used because the repository should fail first.
        return http.Response('', 200, request: request); // 200 OK status code.
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
        repository.getClothingItems(),
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

  // Wardrobe methods need a current user, so the test creates a fake login session.
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
