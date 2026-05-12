import 'package:supabase_flutter/supabase_flutter.dart';
import '../../Domain/repositories/wardrobe_repository.dart';

class SupabaseWardrobeRepository implements WardrobeRepository {
  final SupabaseClient _supabase;

  SupabaseWardrobeRepository(this._supabase);

  String _currentUserIdOrThrow() {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('No authenticated user.');
    return user.id;
  }

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

    if (photoUrl.trim().isNotEmpty) data['item_photo_url'] = photoUrl;

    await _supabase.from('item').insert(data);
  }

  @override
  Future<void> removeClothingItem({required String id}) async {
    final userId = _currentUserIdOrThrow();
    await _supabase
        .from('item')
        .delete()
        .eq('item_id', id)
        .eq('user_id', userId);
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
    final userId = _currentUserIdOrThrow();
    final updateData = <String, dynamic>{};

    if (photoUrl != null && photoUrl.trim().isNotEmpty)
      updateData['item_photo_url'] = photoUrl;
    if (title != null) updateData['title'] = title;
    if (wearType != null) updateData['wear_type'] = wearType;
    if (fabricMaterial != null) updateData['fabric_material'] = fabricMaterial;
    if (warmthRating != null) updateData['warmth_rating'] = warmthRating;
    if (waterResistance != null)
      updateData['water_resistant'] = waterResistance;
    if (layerCategory != null) updateData['layer_category'] = layerCategory;

    if (updateData.isEmpty) return;

    await _supabase
        .from('item')
        .update(updateData)
        .eq('item_id', id)
        .eq('user_id', userId);
  }

  @override
  Future<void> addOutfit({
    required String name,
    required String description,
    required bool isOwned,
    String? photoUrl,
    required List<String> clothingItemIds,
  }) async {
    final userId = _currentUserIdOrThrow();
    final data = <String, dynamic>{
      'user_id': userId,
      'name': name,
      'description': description,
      'is_owned': isOwned,
    };

    if (photoUrl != null && photoUrl.trim().isNotEmpty) {
      data['outfit_photo_url'] = photoUrl;
    }

    final response =
        await _supabase
            .from('outfit')
            .insert(data)
            .select('outfit_id')
            .single();
    final row = Map<String, dynamic>.from(response);
    final outfitId = row['outfit_id']?.toString();
    if (outfitId == null || outfitId.isEmpty)
      throw Exception('Failed to create outfit');

    if (clothingItemIds.isNotEmpty) {
      final payload =
          clothingItemIds
              .map(
                (itemId) => {
                  'outfit_id': outfitId,
                  'item_id': itemId,
                  'user_id': userId,
                },
              )
              .toList();
      await _supabase.from('outfit_item').insert(payload);
    }
  }

  @override
  Future<void> removeOutfit({required String id}) async {
    final userId = _currentUserIdOrThrow();
    await _supabase
        .from('outfit_item')
        .delete()
        .eq('outfit_id', id)
        .eq('user_id', userId);
    await _supabase
        .from('outfit')
        .delete()
        .eq('outfit_id', id)
        .eq('user_id', userId);
  }

  @override
  Future<List<Map<String, dynamic>>> getOutfits() async {
    final userId = _currentUserIdOrThrow();
    final data = await _supabase.from('outfit').select().eq('user_id', userId);
    final outfits = List<Map<String, dynamic>>.from(data as List);

    final linksData = await _supabase
        .from('outfit_item')
        .select()
        .eq('user_id', userId);
    final links = List<Map<String, dynamic>>.from(linksData as List);

    final itemsData = await _supabase
        .from('item')
        .select()
        .eq('user_id', userId);
    final itemsList = List<Map<String, dynamic>>.from(itemsData as List);
    final Map<String, Map<String, dynamic>> itemById = {};
    for (final it in itemsList) {
      final iid = (it['item_id'] ?? it['id'] ?? '').toString();
      itemById[iid] = Map<String, dynamic>.from(it);
    }

    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final link in links) {
      final outfitId = (link['outfit_id'] ?? '').toString();
      final itemId = (link['item_id'] ?? '').toString();
      final itemRecord = itemById[itemId] ?? {'item_id': itemId};
      grouped.putIfAbsent(outfitId, () => []).add(itemRecord);
    }

    for (final outfit in outfits) {
      final oid = (outfit['outfit_id'] ?? outfit['id'] ?? '').toString();
      outfit['items'] = grouped[oid] ?? <Map<String, dynamic>>[];
    }

    return outfits;
  }

  @override
  Future<void> updateOutfit({
    required String id,
    String? name,
    String? description,
    bool? isOwned,
    String? photoUrl,
    List<String>? clothingItemIds,
  }) async {
    final userId = _currentUserIdOrThrow();
    final updateData = <String, dynamic>{};
    if (name != null) updateData['name'] = name;
    if (description != null) updateData['description'] = description;
    if (isOwned != null) updateData['is_owned'] = isOwned;
    if (photoUrl != null && photoUrl.trim().isNotEmpty) {
      updateData['outfit_photo_url'] = photoUrl;
    }

    if (updateData.isNotEmpty) {
      await _supabase
          .from('outfit')
          .update(updateData)
          .eq('outfit_id', id)
          .eq('user_id', userId);
    }

    if (clothingItemIds != null) {
      await _supabase
          .from('outfit_item')
          .delete()
          .eq('outfit_id', id)
          .eq('user_id', userId);
      if (clothingItemIds.isNotEmpty) {
        final payload =
            clothingItemIds
                .map(
                  (itemId) => {
                    'outfit_id': id,
                    'item_id': itemId,
                    'user_id': userId,
                  },
                )
                .toList();
        await _supabase.from('outfit_item').insert(payload);
      }
    }
  }
}
