abstract class WardrobeRepository {
  Future<void> addClothingItem({
    required String photoUrl,
    required String title,
    required String wearType,
    required String fabricMaterial,
    required int warmthRating,
    required bool waterResistance,
    required String layerCategory,
  });

  Future<void> removeClothingItem({required String id});

  Future<List<Map<String, dynamic>>> getClothingItems();

  Future<void> updateClothingItem({
    required String id,
    String? photoUrl,
    String? title,
    String? wearType,
    String? fabricMaterial,
    int? warmthRating,
    bool? waterResistance,
    String? layerCategory,
  });

  Future<void> addOutfit({
    required String name,
    required String description,
    required bool isOwned,
    required List<String> clothingItemIds,
  });

  Future<void> removeOutfit({required String id});

  Future<List<Map<String, dynamic>>> getOutfits();

  Future<void> updateOutfit({
    required String id,
    String? name,
    String? description,
    bool? isOwned,
    List<String>? clothingItemIds,
  });
}
