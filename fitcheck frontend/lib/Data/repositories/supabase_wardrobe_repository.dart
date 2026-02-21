import 'package:supabase_flutter/supabase_flutter.dart';
import '../../Domain/repositories/wardrobe_repository.dart';

class SupabaseWardrobeRepository implements WardrobeRepository {
  static const String _clothingItemsTable = 'item';
  static const String _outfitsTable = 'outfit';

  final SupabaseClient _supabase;

  SupabaseWardrobeRepository(this._supabase);

  @override
  Future<void> addClothingItem({
    required String photoUrl,
    required String title,
    required Enum wearType,
    required Enum fabricMaterial,
    required int warmthRating,
    required bool waterResistance,
    required Enum layerCategory,
  }) async {
    await _supabase.from(_clothingItemsTable).insert({
      'photo_url': photoUrl,
      'title': title,
      'wear_type': wearType.toString(),
      'fabric_material': fabricMaterial.toString(),
      'warmth_rating': warmthRating,
      'water_resistance': waterResistance,
      'layer_category': layerCategory.toString(),
    });
  }

  @override
  Future<void> removeClothingItem({required String id}) async {
    await _supabase.from(_clothingItemsTable).delete().eq('id', id);
  }

  @override
  Future<List<Map<String, dynamic>>> getClothingItems() async {
    final data = await _supabase.from(_clothingItemsTable).select();
    return List<Map<String, dynamic>>.from(data as List);
  }

  @override
  Future<void> updateClothingItem({
    required String id,
    String? photoUrl,
    String? title,
    Enum? wearType,
    Enum? fabricMaterial,
    int? warmthRating,
    bool? waterResistance,
    Enum? layerCategory,
  }) async {
    final updateData = <String, dynamic>{};

    if (photoUrl != null) updateData['photo_url'] = photoUrl;
    if (title != null) updateData['title'] = title;
    if (wearType != null) updateData['wear_type'] = wearType.toString();
    if (fabricMaterial != null) updateData['fabric_material'] = fabricMaterial.toString();
    if (warmthRating != null) updateData['warmth_rating'] = warmthRating;
    if (waterResistance != null) updateData['water_resistance'] = waterResistance;
    if (layerCategory != null) updateData['layer_category'] = layerCategory.toString();

    await _supabase.from(_clothingItemsTable).update(updateData).eq('id', id);
  }

  @override
  Future<void> addOutfit({
    required String name,
    required String description,
    required bool isOwned,
    required List<String> clothingItemIds,
  }) async {
    await _supabase.from(_outfitsTable).insert({
      'name': name,
      'description': description,
      'is_owned': isOwned,
      'clothing_item_ids': clothingItemIds,
    });
  }

  @override
  Future<void> removeOutfit({required String id}) async {
    await _supabase.from(_outfitsTable).delete().eq('id', id);
  }

  @override
  Future<List<Map<String, dynamic>>> getOutfits() async {
    final data = await _supabase.from(_outfitsTable).select();
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
    if (clothingItemIds != null) updateData['clothing_item_ids'] = clothingItemIds;

    await _supabase.from(_outfitsTable).update(updateData).eq('id', id);
  }
}
