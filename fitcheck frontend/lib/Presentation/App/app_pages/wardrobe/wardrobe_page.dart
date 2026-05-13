// Wardrobe page: displays user's wardrobe items and outfits, with search
// and filter controls and outfit creation flows. Integrates with
// Supabase via `SupabaseWardrobeRepository` and optionally uses
// `WeatherService` to suggest items.
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fitcheck/Data/repositories/supabase_wardrobe_repository.dart';
import 'package:fitcheck/Presentation/App/app_pages/wardrobe/widgets/create_item.dart';
import 'package:fitcheck/Presentation/App/app_pages/wardrobe/widgets/create_outfit.dart';
import 'package:fitcheck/Presentation/App/app_style/widgets/dashed_box.dart';
import 'package:fitcheck/Presentation/App/app_style/widgets/floating_nav_bar.dart';
import 'package:fitcheck/Presentation/App/app_style/glass_frame.dart';
import 'package:fitcheck/Presentation/App/app_style/widgets/search_bar.dart';
import 'package:fitcheck/Presentation/App/app_pages/wardrobe/styles/wardrobe_styles.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../app_style/widgets/app_toast.dart';
import 'package:fitcheck/Data/services/weather_service.dart';
import 'dart:async';

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key});

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  late final SupabaseWardrobeRepository _wardrobeRepository;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _items = [];
  bool _isLoadingOutfits = true;
  String? _outfitsError;
  List<Map<String, dynamic>> _outfits = [];
  bool _showOutfits = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  String _searchQuery = '';
  final Set<String> _selectedWearTypes = {};
  final Set<String> _selectedLayerCategories = {};
  WeatherService? _weatherService;
  Map<String, dynamic>? _currentWeather;
  List<String> _recommendedTags = [];

  Map<String, int> _getWearTypeCounts() {
    final counts = <String, int>{};
    for (final item in _items) {
      final wearType = (item['wear_type'] ?? 'Unknown').toString();
      counts[wearType] = (counts[wearType] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, int> _getLayerCategoryCounts() {
    final counts = <String, int>{};
    for (final item in _items) {
      final layer = (item['layer_category'] ?? 'Unknown').toString();
      counts[layer] = (counts[layer] ?? 0) + 1;
    }
    return counts;
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _searchQuery = value.trim().toLowerCase();
      });
    });
  }

  List<Map<String, dynamic>> _filteredItems() {
    var result = _items;

    if (_searchQuery.isNotEmpty) {
      result =
          result.where((item) {
            final name =
                (item['name'] ?? item['title'] ?? '').toString().toLowerCase();
            final wearType = (item['wear_type'] ?? '').toString().toLowerCase();
            return name.contains(_searchQuery) ||
                wearType.contains(_searchQuery);
          }).toList();
    }

    if (_selectedWearTypes.isNotEmpty) {
      result =
          result.where((item) {
            final wearType = (item['wear_type'] ?? '').toString();
            return _selectedWearTypes.contains(wearType);
          }).toList();
    }

    if (_selectedLayerCategories.isNotEmpty) {
      result =
          result.where((item) {
            final layer = (item['layer_category'] ?? '').toString();
            return _selectedLayerCategories.contains(layer);
          }).toList();
    }

    return result;
  }

  List<Map<String, dynamic>> _filteredOutfits() {
    var result = _outfits;

    if (_searchQuery.isNotEmpty) {
      result =
          result.where((outfit) {
            final name = (outfit['name'] ?? '').toString().toLowerCase();
            final description =
                (outfit['description'] ?? '').toString().toLowerCase();
            return name.contains(_searchQuery) ||
                description.contains(_searchQuery);
          }).toList();
    }

    if (_selectedWearTypes.isNotEmpty) {
      result =
          result.where((outfit) {
            final wearType = (outfit['wear_type'] ?? '').toString();
            return _selectedWearTypes.contains(wearType);
          }).toList();
    }

    return result;
  }

  void _showFilterModal() {
    final wearTypeCounts = _getWearTypeCounts();
    final layerCategoryCounts = _getLayerCategoryCounts();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1F26),
            title: const Text('Filter', style: TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Wear Type',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...wearTypeCounts.entries.map((entry) {
                    return CheckboxListTile(
                      title: Text(
                        '${entry.key} (${entry.value})',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      value: _selectedWearTypes.contains(entry.key),
                      onChanged: (selected) {
                        setState(() {
                          if (selected == true) {
                            _selectedWearTypes.add(entry.key);
                          } else {
                            _selectedWearTypes.remove(entry.key);
                          }
                        });
                      },
                      activeColor: const Color(0xFFD4A017),
                      checkColor: Colors.black,
                    );
                  }),
                  const SizedBox(height: 16),
                  const Text(
                    'Layer Category',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...layerCategoryCounts.entries.map((entry) {
                    return CheckboxListTile(
                      title: Text(
                        '${entry.key} (${entry.value})',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      value: _selectedLayerCategories.contains(entry.key),
                      onChanged: (selected) {
                        setState(() {
                          if (selected == true) {
                            _selectedLayerCategories.add(entry.key);
                          } else {
                            _selectedLayerCategories.remove(entry.key);
                          }
                        });
                      },
                      activeColor: const Color(0xFFD4A017),
                      checkColor: Colors.black,
                    );
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Done',
                  style: TextStyle(color: Color(0xFFD4A017)),
                ),
              ),
            ],
          ),
    );
  }

  List<String> _recommendTagsFromWeather(Map<String, dynamic> w) {
    final temp = (w['temp'] ?? 0.0) as double;
    final cond = (w['condition'] ?? '').toString().toLowerCase();
    final tags = <String>[];
    if (temp >= 25) {
      tags.add('warm');
    } else if (temp >= 15)
      tags.add('mild');
    else
      tags.add('cold');
    if (cond.contains('rain') || cond.contains('drizzle')) tags.add('rain');
    if (cond.contains('snow')) tags.add('snow');
    if (cond.contains('clear')) tags.add('clear');
    return tags;
  }

  Future<void> _loadWeatherAndRecommend() async {
    final key = dotenv.env['OPENWEATHER_API_KEY'] ?? '';
      if (key.isEmpty) {
      debugPrint('[WardrobePage] OPENWEATHER_API_KEY missing');
      if (mounted) {
        showAppMessage(context, 'Weather API key missing', error: true);
      }
      return;
    }
    _weatherService ??= WeatherService(key);
    try {
      final w = await _weatherService!.getCurrentWeatherByCoords(
        51.5074,
        -0.1278,
      );
      if (!mounted) return;
      setState(() {
        _currentWeather = w;
        _recommendedTags = _recommendTagsFromWeather(w);
      });
      debugPrint('[WardrobePage] Weather loaded: $w');
      if (mounted) {
        showAppMessage(context, 'Weather: ${w['temp']}C ${w['condition']}');
      }
    } catch (e) {
      debugPrint('[WardrobePage] Weather load error: $e');
      if (mounted) {
        showAppMessage(context, 'Weather fetch failed', error: true);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _wardrobeRepository = SupabaseWardrobeRepository(Supabase.instance.client);
    _loadItems();
    _loadOutfits();
    _loadWeatherAndRecommend();
  }

  Future<void> _loadItems() async {
    try {
      final items = await _wardrobeRepository.getClothingItems();
      if (!mounted) return;
      setState(() {
        _items = items;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _loadOutfits() async {
    try {
      final outfits = await _wardrobeRepository.getOutfits();
      if (!mounted) return;
      setState(() {
        _outfits = outfits;
        _isLoadingOutfits = false;
        _outfitsError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingOutfits = false;
        _outfitsError = e.toString();
      });
    }
  }

  Future<void> _deleteItem(String id) async {
    if (id.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete item?'),
            content: const Text('This will remove the item permanently.'),
            actions: [
              TextButton(
                style: WardrobeStyles.dialogCancelButtonStyle,
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                style: WardrobeStyles.dialogDeleteButtonStyle,
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (confirm != true) return;

    final index = _items.indexWhere(
      (m) => ((m['item_id'] ?? m['id'] ?? '').toString()) == id,
    );
    Map<String, dynamic>? removed;
    if (index != -1) {
      removed = _items.removeAt(index);
      if (mounted) setState(() {});
    }

    try {
      debugPrint('[WardrobePage] deleting item id=$id');
      await _wardrobeRepository.removeClothingItem(id: id);
      await _loadItems();
      if (mounted) {
        showAppMessage(context, 'Item deleted');
      }
    } catch (e) {
      debugPrint('[WardrobePage] delete error: $e');
      if (removed != null) {
        _items.insert(index, removed);
        if (mounted) setState(() {});
      }
      if (mounted) {
        showAppMessage(context, 'Delete failed: $e', error: true);
      }
    }
  }

  Future<void> _deleteOutfit(String id) async {
    if (id.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete outfit?'),
            content: const Text('This will remove the outfit permanently.'),
            actions: [
              TextButton(
                style: WardrobeStyles.dialogCancelButtonStyle,
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                style: WardrobeStyles.dialogDeleteButtonStyle,
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (confirm != true) return;

    final index = _outfits.indexWhere(
      (m) => ((m['outfit_id'] ?? m['id'] ?? '').toString()) == id,
    );
    Map<String, dynamic>? removed;
    if (index != -1) {
      removed = _outfits.removeAt(index);
      if (mounted) setState(() {});
    }

    try {
      debugPrint('[WardrobePage] deleting outfit id=$id');
      await _wardrobeRepository.removeOutfit(id: id);
      await _loadOutfits();
      if (mounted) {
        showAppMessage(context, 'Outfit deleted');
      }
    } catch (e) {
      debugPrint('[WardrobePage] delete outfit error: $e');
      if (removed != null) {
        _outfits.insert(index, removed);
        if (mounted) setState(() {});
      }
      if (mounted) {
        showAppMessage(context, 'Delete failed: $e', error: true);
      }
    }
  }

  void _openEditItem(Map<String, dynamic> item) {
    CreateItem.open(
      context,
      repository: _wardrobeRepository,
      existingItem: item,
    ).then((didSave) {
      if (didSave) _loadItems();
    });
  }

  void _openEditOutfit(Map<String, dynamic> outfit) {
    CreateOutfitModal.open(
      context,
      repository: _wardrobeRepository,
      existingOutfit: outfit,
    ).then((didSave) {
      if (didSave) _loadOutfits();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 50),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              SizedBox(
                                // Removed GlassFrame wrapper: render the back
                                // button directly with the same compact
                                // container styling so it visually matches but
                                // without the frosted glass effect.
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(0, 0, 0, 0.2),
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.arrow_back_ios_sharp,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                              ),
                              const Expanded(child: SizedBox()),
                              SizedBox(
                                child: GlassFrame(
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(0, 0, 0, 0.2),
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                    child: Row(
                                      children: [
                                        SearchBarRow(
                                          controller: _searchController,
                                          onChanged: _onSearchChanged,
                                        ),
                                        SizedBox(
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.filter_list_outlined,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            onPressed: _showFilterModal,
                                          ),
                                        ),
                                        SizedBox(
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.grid_view,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            onPressed: () {},
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 50),
                        const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 30.0, bottom: 20),
                              child: Text(
                                'Wardrobe',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 35,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_recommendedTags.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30.0,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Weather ${_currentWeather?['temp']?.toStringAsFixed(0) ?? '--'}C (${_currentWeather?['condition'] ?? 'Unknown'}) | Recommended: ${_recommendedTags.join(', ')}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: Row(
                            children: [
                              ChoiceChip(
                                label: const Text('Items'),
                                selected: !_showOutfits,
                                onSelected:
                                    (_) => setState(() => _showOutfits = false),
                                selectedColor: const Color(0xFFD4A017),
                                backgroundColor: const Color(0xFF2A2F38),
                                labelStyle: TextStyle(
                                  color:
                                      !_showOutfits
                                          ? Colors.white
                                          : Colors.white70,
                                ),
                              ),
                              const SizedBox(width: 10),
                              ChoiceChip(
                                label: const Text('Outfits'),
                                selected: _showOutfits,
                                onSelected:
                                    (_) => setState(() => _showOutfits = true),
                                selectedColor: const Color(0xFFD4A017),
                                backgroundColor: const Color(0xFF2A2F38),
                                labelStyle: TextStyle(
                                  color:
                                      _showOutfits
                                          ? Colors.white
                                          : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (!_showOutfits)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30.0,
                            ),
                            child: _WardrobeItemsGrid(
                              isLoading: _isLoading,
                              error: _error,
                              items: _filteredItems(),
                              onDelete: _deleteItem,
                              onEdit: _openEditItem,
                              onCreatePressed: () async {
                                final didSave = await CreateItem.open(
                                  context,
                                  repository: _wardrobeRepository,
                                );
                                if (didSave) await _loadItems();
                              },
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30.0,
                            ),
                            child: _WardrobeOutfitsList(
                              isLoading: _isLoadingOutfits,
                              error: _outfitsError,
                              outfits: _filteredOutfits(),
                              onDelete: _deleteOutfit,
                              onEdit: _openEditOutfit,
                            ),
                          ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          FloatingNavbar(onOutfitCreated: _loadOutfits),
        ],
      ),
    );
  }
}

class _WardrobeItemsGrid extends StatelessWidget {
  const _WardrobeItemsGrid({
    required this.isLoading,
    required this.error,
    required this.items,
    this.onDelete,
    this.onEdit,
    this.onCreatePressed,
  });

  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> items;
  final Future<void> Function(String id)? onDelete;
  final void Function(Map<String, dynamic> item)? onEdit;
  final VoidCallback? onCreatePressed;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (error != null) {
      return const Text(
        'Could not load items',
        style: TextStyle(color: Colors.white70, fontSize: 12),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = ((screenWidth - 60) / 125).floor().clamp(2, 6);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return InkWell(
            onTap: onCreatePressed,
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
                Container(
                  color: Colors.black12,
                  child: const DashedBox(
                    color: Colors.black,
                    strokeWidth: 7.0,
                    gap: 11.1,
                  ),
                ),
                Center(child: Icon(Icons.add, color: Colors.white, size: 30)),
              ],
            ),
          );
        }

        final itemIndex = index - 1;
        final item = items[itemIndex];
        final title = (item['name'] ?? item['title'] ?? '').toString();
        final wearType = (item['wear_type'] ?? '').toString();
        final id = (item['item_id'] ?? item['id'] ?? '').toString();

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onEdit?.call(item),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.checkroom_outlined,
                        color: Colors.white70,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title.isEmpty ? 'Untitled item' : title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      if (wearType.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          wearType,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: SizedBox(
                    height: 28,
                    width: 28,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed:
                          id.isEmpty
                              ? null
                              : () async => await onDelete?.call(id),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                        size: 18,
                      ),
                      tooltip: 'Delete item',
                      visualDensity: VisualDensity.compact,
                      splashRadius: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WardrobeOutfitsList extends StatelessWidget {
  const _WardrobeOutfitsList({
    required this.isLoading,
    required this.error,
    required this.outfits,
    this.onDelete,
    this.onEdit,
  });

  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> outfits;
  final Future<void> Function(String id)? onDelete;
  final void Function(Map<String, dynamic> outfit)? onEdit;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (error != null) {
      return const Text(
        'Could not load outfits',
        style: TextStyle(color: Colors.white70, fontSize: 12),
      );
    }
    if (outfits.isEmpty) {
      return const Text(
        'No outfits yet',
        style: TextStyle(color: Colors.white70, fontSize: 12),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: outfits.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final outfit = outfits[index];
        final name = (outfit['name'] ?? 'Untitled outfit').toString();
        final description = (outfit['description'] ?? '').toString();
        final isOwned = outfit['is_owned'] == true;
        final id = (outfit['outfit_id'] ?? outfit['id'] ?? '').toString();

        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => onEdit?.call(outfit),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isOwned)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4A017),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Owned',
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                  ],
                ),
                if (description.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 8),
                if ((outfit['items'] is List) &&
                    (outfit['items'] as List).isNotEmpty) ...[
                  SizedBox(
                    height: 64,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: (outfit['items'] as List).length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final it = Map<String, dynamic>.from(
                          (outfit['items'] as List)[i] as Map<String, dynamic>,
                        );
                        final title =
                            (it['name'] ?? it['title'] ?? '').toString();
                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.checkroom_outlined,
                                color: Colors.white70,
                                size: 20,
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                width: 80,
                                child: Text(
                                  title.isEmpty ? 'Untitled' : title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 32,
                    width: 32,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed:
                          id.isEmpty
                              ? null
                              : () async => await onDelete?.call(id),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                        size: 18,
                      ),
                      tooltip: 'Delete outfit',
                      visualDensity: VisualDensity.compact,
                      splashRadius: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
