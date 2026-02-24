import 'package:supabase_flutter/supabase_flutter.dart';
import '../../Domain/repositories/wardrobe_repository.dart';

class SupabaseWardrobeRepository implements WardrobeRepository {
  static const List<String> _clothingItemsTables = [
    'item',
    'items',
    'clothing_item',
    'clothing_items',
  ];
  static const List<String> _outfitsTables = ['outfit', 'outfits'];

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
    await _deleteWithTableFallback(_clothingItemsTables, id);
  }

  @override
  Future<List<Map<String, dynamic>>> getClothingItems() async {
    return _selectWithTableFallback(_clothingItemsTables);
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
    if (waterResistance != null)
      updateData['water_resistant'] = waterResistance;
    if (layerCategory != null) updateData['layer_category'] = layerCategory;

    await _updateWithTableFallback(_clothingItemsTables, id, updateData);
  }

  @override
  Future<void> addOutfit({
    required String name,
    required String description,
    required bool isOwned,
    required List<String> clothingItemIds,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'description': description,
      'is_owned': isOwned,
    };

    if (clothingItemIds.isNotEmpty) {
      data['clothing_item_ids'] = clothingItemIds;
    }

    await _insertWithTableFallback(_outfitsTables, data);
  }

  @override
  Future<void> removeOutfit({required String id}) async {
    await _deleteWithTableFallback(_outfitsTables, id);
  }

  @override
  Future<List<Map<String, dynamic>>> getOutfits() async {
    return _selectWithTableFallback(_outfitsTables);
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
    if (clothingItemIds != null && clothingItemIds.isNotEmpty)
      updateData['clothing_item_ids'] = clothingItemIds;

    await _updateWithTableFallback(_outfitsTables, id, updateData);
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

  Future<void> _deleteWithTableFallback(List<String> tables, String id) async {
    PostgrestException? lastException;

    for (final table in tables) {
      try {
        await _supabase.from(table).delete().eq('id', id);
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

  Future<List<Map<String, dynamic>>> _selectWithTableFallback(
    List<String> tables,
  ) async {
    PostgrestException? lastException;

    for (final table in tables) {
      try {
        final data = await _supabase.from(table).select();
        return List<Map<String, dynamic>>.from(data as List);
      } on PostgrestException catch (e) {
        lastException = e;
        if (!_isTableMissingError(e)) {
          rethrow;
        }
      }
    }

    throw Exception(
      'Could not find a valid table for select. Last error: ${lastException?.message ?? 'unknown error'}',
    );
  }

  Future<void> _updateWithTableFallback(
    List<String> tables,
    String id,
    Map<String, dynamic> data,
  ) async {
    PostgrestException? lastException;

    for (final table in tables) {
      try {
        await _supabase.from(table).update(data).eq('id', id);
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
        e.message.toLowerCase().contains('relation') ||
        e.message.toLowerCase().contains('does not exist');
  }
}
