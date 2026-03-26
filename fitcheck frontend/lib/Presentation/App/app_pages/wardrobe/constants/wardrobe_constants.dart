class WardrobeConstants {
  static const List<String> wearTypes = [
    "Smart",
    "Casual",
    "Formal",
  ];

  static const List<String> fabricMaterials = [
    "Cotton",
    "Denim",
    "Wool",
    "Leather",
    "Polyester",
    "Nylon",
    "Other",
  ];

  static const List<String> layerCategories = [
    "Base layer",
    "Mid layer",
    "Outer layer",
    "Single layer",
  ];

  static const int minWarmthRating = 1;
  static const int maxWarmthRating = 5;

  static const String defaultItemNameHint = "e.g. Black puffer jacket";
  static const String defaultOutfitNameHint = "e.g. Winter street fit";
  static const String defaultOutfitDescriptionHint =
      "Add a short description for this outfit...";
  static const String outfitDescriptionHelper =
      "Optional notes (style, weather, occasion, etc.)";
}