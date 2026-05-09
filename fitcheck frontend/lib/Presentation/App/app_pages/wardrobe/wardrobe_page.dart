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
  if (_searchQuery.isEmpty) return _items;

  return _items.where((item) {
    final name = (item['name'] ?? item['title'] ?? '').toString().toLowerCase();
    final wearType = (item['wear_type'] ?? '').toString().toLowerCase();
    return name.contains(_searchQuery) || wearType.contains(_searchQuery);
  }).toList();
}

List<Map<String, dynamic>> _filteredOutfits() {
  if (_searchQuery.isEmpty) return _outfits;

  return _outfits.where((outfit) {
    final name = (outfit['name'] ?? '').toString().toLowerCase();
    final description = (outfit['description'] ?? '').toString().toLowerCase();
    return name.contains(_searchQuery) || description.contains(_searchQuery);
  }).toList();
}

  @override
  void initState() {
    super.initState();
    _wardrobeRepository = SupabaseWardrobeRepository(Supabase.instance.client);
    _loadItems();
    _loadOutfits();
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Item deleted')));
      }
    } catch (e) {
      debugPrint('[WardrobePage] delete error: $e');
      if (removed != null) {
        _items.insert(index, removed);
        if (mounted) setState(() {});
      }
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Outfit deleted')));
      }
    } catch (e) {
      debugPrint('[WardrobePage] delete outfit error: $e');
      if (removed != null) {
        _outfits.insert(index, removed);
        if (mounted) setState(() {});
      }
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
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
      backgroundColor: Colors.black,
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
                                child: GlassFrame(
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
                                            onPressed: () {},
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
    if (isLoading)
      return const Center(
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    if (error != null)
      return const Text(
        'Could not load items',
        style: TextStyle(color: Colors.white70, fontSize: 12),
      );

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
    if (isLoading)
      return const Center(
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    if (error != null)
      return const Text(
        'Could not load outfits',
        style: TextStyle(color: Colors.white70, fontSize: 12),
      );
    if (outfits.isEmpty)
      return const Text(
        'No outfits yet',
        style: TextStyle(color: Colors.white70, fontSize: 12),
      );

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: outfits.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
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
