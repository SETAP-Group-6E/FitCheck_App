import 'package:supabase_flutter/supabase_flutter.dart';
import '../../Domain/repositories/wardrobe_repository.dart';

class SupabaseWardrobeRepository implements WardrobeRepository {
  static const List<String> _clothingItemsTables = ['item'];
  static const List<String> _outfitsTables = ['outfit'];
  static const List<String> _outfitItemsTables = ['outfit_item'];

  final SupabaseClient _supabase;

  SupabaseWardrobeRepository(this._supabase);

  @override
  Future<void> addClothingItem({
    required String photoUrl,
    required String title,
    required String wearType,
    required String fabricMaterial,
    required int warmthRating,
    required bool waterResistance,
    required String layerCategory,
  }) async {
    final userId = _currentUserIdOrThrow();

    final data = <String, dynamic>{
      'user_id': userId,
      'title': title,
      'wear_type': wearType,
      'fabric_material': fabricMaterial,
      'warmth_rating': warmthRating,
      'water_resistant': waterResistance,
      'layer_category': layerCategory,
    };

    if (photoUrl.trim().isNotEmpty) {
      data['photo_url'] = photoUrl;
    }

    await _insertWithTableFallback(_clothingItemsTables, data);
  }

  String _currentUserIdOrThrow() {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user. Please sign in and try again.');
    }
    return user.id;
  }

  @override
  Future<void> removeClothingItem({required String id}) async {
    await _deleteWithTableFallback(
      _clothingItemsTables,
      id,
      idColumn: 'item_id',
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getClothingItems() async {
    final userId = _currentUserIdOrThrow();
    final data = await _supabase.from('item').select().eq('user_id', userId);
    return List<Map<String, dynamic>>.from(data as List);
  }

  @override
  Future<void> updateClothingItem({
    required String id,
    String? photoUrl,
    String? title,
    String? wearType,
    String? fabricMaterial,
    int? warmthRating,
    bool? waterResistance,
    String? layerCategory,
  }) async {
    final updateData = <String, dynamic>{};

    if (photoUrl != null && photoUrl.trim().isNotEmpty) {
      updateData['photo_url'] = photoUrl;
    }
    if (title != null) updateData['title'] = title;
    if (wearType != null) updateData['wear_type'] = wearType;
    if (fabricMaterial != null) updateData['fabric_material'] = fabricMaterial;
    if (warmthRating != null) updateData['warmth_rating'] = warmthRating;
    if (waterResistance != null) {
      updateData['water_resistant'] = waterResistance;
    }
    if (layerCategory != null) updateData['layer_category'] = layerCategory;

    await _updateWithTableFallback(
      _clothingItemsTables,
      id,
      updateData,
      idColumn: 'item_id',
    );
  }

  @override
  Future<void> addOutfit({
    required String name,
    required String description,
    required bool isOwned,
    required List<String> clothingItemIds,
  }) async {
    final userId = _currentUserIdOrThrow();
    final data = <String, dynamic>{
      'user_id': userId,
      'name': name,
      'description': description,
      'is_owned': isOwned,
    };

    final outfitId = await _insertOutfitAndGetId(data);

    if (clothingItemIds.isNotEmpty) {
      await _insertOutfitItemLinks(
        outfitId: outfitId,
        clothingItemIds: clothingItemIds,
        userId: userId,
      );
    }
  }

  @override
  Future<void> removeOutfit({required String id}) async {
    await _deleteWithTableFallback(_outfitsTables, id, idColumn: 'outfit_id');
  }

  @override
  Future<List<Map<String, dynamic>>> getOutfits() async {
    final userId = _currentUserIdOrThrow();
    final data = await _supabase.from('outfit').select().eq('user_id', userId);
    return List<Map<String, dynamic>>.from(data as List);
  }

  @override
  Future<void> updateOutfit({
    required String id,
    String? name,
    String? description,
    bool? isOwned,
    List<String>? clothingItemIds,
  }) async {
    final updateData = <String, dynamic>{};

    if (name != null) updateData['name'] = name;
    if (description != null) updateData['description'] = description;
    if (isOwned != null) updateData['is_owned'] = isOwned;
    if (clothingItemIds != null && clothingItemIds.isNotEmpty) {
      updateData['clothing_item_ids'] = clothingItemIds;
    }

    await _updateWithTableFallback(
      _outfitsTables,
      id,
      updateData,
      idColumn: 'outfit_id',
    );
  }

  Future<void> _insertWithTableFallback(
    List<String> tables,
    Map<String, dynamic> data,
  ) async {
    PostgrestException? lastException;

    for (final table in tables) {
      try {
        await _supabase.from(table).insert(data);
        return;
      } on PostgrestException catch (e) {
        lastException = e;
        if (!_isTableMissingError(e)) {
          rethrow;
        }
      }
    }

    throw Exception(
      'Could not find a valid table for insert. Last error: ${lastException?.message ?? 'unknown error'}',
    );
  }

  Future<String> _insertOutfitAndGetId(Map<String, dynamic> data) async {
    PostgrestException? lastException;

    for (final table in _outfitsTables) {
      try {
        final response =
            await _supabase
                .from(table)
                .insert(data)
                .select('outfit_id')
                .single();
        final row = Map<String, dynamic>.from(response);
        final outfitId = row['outfit_id']?.toString();
        if (outfitId == null || outfitId.isEmpty) {
          throw Exception(
            'Outfit insert succeeded but no outfit id was returned.',
          );
        }
        return outfitId;
      } on PostgrestException catch (e) {
        lastException = e;

        if (_isColumnMissingError(e) &&
            e.message.toLowerCase().contains('user_id')) {
          final dataWithoutUserId = Map<String, dynamic>.from(data)
            ..remove('user_id');
          try {
            final response =
                await _supabase
                    .from(table)
                    .insert(dataWithoutUserId)
                    .select('outfit_id')
                    .single();
            final row = Map<String, dynamic>.from(response);
            final outfitId = row['outfit_id']?.toString();
            if (outfitId == null || outfitId.isEmpty) {
              throw Exception(
                'Outfit insert succeeded but no outfit id was returned.',
              );
            }
            return outfitId;
          } on PostgrestException catch (e2) {
            lastException = e2;
            if (_isTableMissingError(e2) || _isColumnMissingError(e2)) {
              continue;
            }
            rethrow;
          }
        }

        if (_isTableMissingError(e) || _isColumnMissingError(e)) {
          continue;
        }
        rethrow;
      }
    }

    throw Exception(
      'Could not insert outfit and resolve outfit id. Last error: ${lastException?.message ?? 'unknown error'}',
    );
  }

  Future<void> _insertOutfitItemLinks({
    required String outfitId,
    required List<String> clothingItemIds,
    required String userId,
  }) async {
    PostgrestException? lastException;

    final columnVariants = <Map<String, String>>[
      {'outfit_id': 'outfit_id', 'item_id': 'item_id'},
      {'outfit_id': 'outfit_id', 'item_id': 'clothing_item_id'},
    ];

    for (final table in _outfitItemsTables) {
      for (final columns in columnVariants) {
        final payload =
            clothingItemIds
                .map(
                  (itemId) => <String, dynamic>{
                    columns['outfit_id']!: outfitId,
                    columns['item_id']!: itemId,
                    'user_id': userId,
                  },
                )
                .toList();

        try {
          await _supabase.from(table).insert(payload);
          return;
        } on PostgrestException catch (e) {
          lastException = e;

          if (_isColumnMissingError(e) &&
              e.message.toLowerCase().contains('user_id')) {
            final payloadWithoutUserId =
                clothingItemIds
                    .map(
                      (itemId) => <String, dynamic>{
                        columns['outfit_id']!: outfitId,
                        columns['item_id']!: itemId,
                      },
                    )
                    .toList();
            try {
              await _supabase.from(table).insert(payloadWithoutUserId);
              return;
            } on PostgrestException catch (e2) {
              lastException = e2;
              if (_isTableMissingError(e2) || _isColumnMissingError(e2)) {
                continue;
              }
              rethrow;
            }
          }

          if (_isTableMissingError(e) || _isColumnMissingError(e)) {
            continue;
          }
          rethrow;
        }
      }
    }

    throw Exception(
      'Could not insert outfit-item links. Last error: ${lastException?.message ?? 'unknown error'}',
    );
  }

  Future<void> _deleteWithTableFallback(
    List<String> tables,
    String id, {
    required String idColumn,
  }) async {
    PostgrestException? lastException;

    for (final table in tables) {
      try {
        await _supabase.from(table).delete().eq(idColumn, id);
        return;
      } on PostgrestException catch (e) {
        lastException = e;
        if (!_isTableMissingError(e)) {
          rethrow;
        }
      }
    }

    throw Exception(
      'Could not find a valid table for delete. Last error: ${lastException?.message ?? 'unknown error'}',
    );
  }

  Future<void> _updateWithTableFallback(
    List<String> tables,
    String id,
    Map<String, dynamic> data, {
    required String idColumn,
  }) async {
    PostgrestException? lastException;

    for (final table in tables) {
      try {
        await _supabase.from(table).update(data).eq(idColumn, id);
        return;
      } on PostgrestException catch (e) {
        lastException = e;
        if (!_isTableMissingError(e)) {
          rethrow;
        }
      }
    }

    throw Exception(
      'Could not find a valid table for update. Last error: ${lastException?.message ?? 'unknown error'}',
    );
  }

  bool _isTableMissingError(PostgrestException e) {
    return e.code == '42P01' ||
        e.code == 'PGRST205' ||
        e.message.toLowerCase().contains('relation') ||
        e.message.toLowerCase().contains('schema cache') ||
        e.message.toLowerCase().contains('does not exist');
  }

  bool _isColumnMissingError(PostgrestException e) {
    return e.code == '42703' || e.message.toLowerCase().contains('column');
  }
}
