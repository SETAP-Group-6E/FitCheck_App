import 'package:fitcheck/Data/repositories/supabase_wardrobe_repository.dart';
import 'package:fitcheck/Presentation/App/app_pages/wardrobe/widgets/create_item.dart';
import 'package:fitcheck/Presentation/App/app_style/dashed_box.dart';
import 'package:fitcheck/Presentation/App/app_style/floating_nav_bar.dart';
import 'package:fitcheck/Presentation/App/app_style/glass_frame.dart';
import 'package:fitcheck/Presentation/App/app_style/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  @override
  void initState() {
    super.initState();
    _wardrobeRepository = SupabaseWardrobeRepository(Supabase.instance.client);
    _loadItems();
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
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
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
                                        SearchBarRow(),
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
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 40.0,
                            right: 16.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    height: 125,
                                    width: 125,
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
                                    height: 125,
                                    width: 125,
                                    color: Colors.black12,
                                    child: const DashedBox(
                                      color: Colors.black,
                                      strokeWidth: 7.0,
                                      gap: 11.1,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 125,
                                    width: 125,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      onPressed: () async {
                                        final didSave = await CreateItem.open(
                                          context,
                                          repository: _wardrobeRepository,
                                        );
                                        if (didSave) {
                                          await _loadItems();
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _WardrobeItemsGrid(
                                  isLoading: _isLoading,
                                  error: _error,
                                  items: _items,
                                ),
                              ),
                            ],
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
          FloatingNavbar(),
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
  });

  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> items;

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

    if (items.isEmpty) {
      return const Text(
        'No items yet',
        style: TextStyle(color: Colors.white70, fontSize: 12),
      );
    }

    return SizedBox(
      height: 125,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          final title = (item['title'] ?? '').toString().trim();
          final wearType = (item['wear_type'] ?? '').toString().trim();
          return Container(
            width: 125,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24, width: 1.2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.checkroom_outlined, color: Colors.white70),
                const SizedBox(height: 8),
                Text(
                  title.isEmpty ? 'Untitled item' : title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                if (wearType.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    wearType,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
