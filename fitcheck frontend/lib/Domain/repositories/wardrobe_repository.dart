abstract class WardrobeRepository {

  Future<void> addClothingItem({
    required String photoUrl,
    required String title,
    required Enum wearType,
    required Enum fabricMaterial,
    required int warmthRating,
    required bool waterResistance,
    required Enum layerCategory,
  });

  Future<void> removeClothingItem({
    required String id,
  });

  Future<List<Map<String, dynamic>>> getClothingItems();

  Future<void> updateClothingItem({
    required String id,
    String? photoUrl,
    String? title,
    Enum? wearType,
    Enum? fabricMaterial,
    int? warmthRating,
    bool? waterResistance,
    Enum? layerCategory,
  });

  Future<void> addOutfit({
    required String name,
    required String description,
    required bool isOwned,
    required List<String> clothingItemIds,
  });

  Future<void> removeOutfit({
    required String id,
  });

  Future<List<Map<String, dynamic>>> getOutfits();

  Future<void> updateOutfit({
    required String id,
    String? name,
    String? description,
    bool? isOwned,
    List<String>? clothingItemIds,
  });
}