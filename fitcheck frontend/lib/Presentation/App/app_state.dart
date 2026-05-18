import 'package:flutter/foundation.dart';

/// Global UI state for small cross-cutting flags.
/// Only include very small, low-risk flags here; prefer providers for
/// larger application state.
final ValueNotifier<bool> navbarVisible = ValueNotifier<bool>(true);
final ValueNotifier<int> wardrobeOutfitsVersion = ValueNotifier<int>(0);
