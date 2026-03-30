import 'package:flutter/material.dart';
import 'package:fitcheck/Domain/repositories/wardrobe_repository.dart';
import '../constants/wardrobe_constants.dart';

class _CreateOutfitTheme {
  static const Color card = Color(0xFF171A20);
  static const Color border = Color(0xFF2A2F38);
  static const Color gold = Color(0xFFD4A017);
  static const Color muted = Color(0xFFA1A1AA);
}

class CreateOutfitModal extends StatefulWidget {
  const CreateOutfitModal({super.key, required this.repository});

  final WardrobeRepository repository;

  static Future<bool> open(
    BuildContext context, {
    required WardrobeRepository repository,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.60),
      builder:
          (_) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
            child: CreateOutfitModal(repository: repository),
          ),
    );
    return result ?? false;
  }

  @override
  State<CreateOutfitModal> createState() => _CreateOutfitModalState();
}

class _CreateOutfitModalState extends State<CreateOutfitModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  List<Map<String, dynamic>> _items = [];
  Set<String> _selectedItemIds = {};
  bool _loadingItems = true;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final items = await widget.repository.getClothingItems();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loadingItems = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingItems = false;
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _cancel() => Navigator.of(context).pop(false);

  void _toggleItemSelection(String itemId) {
    if (itemId.isEmpty) return;
    setState(() {
      if (_selectedItemIds.contains(itemId)) {
        _selectedItemIds.remove(itemId);
      } else {
        _selectedItemIds.add(itemId);
      }
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedItemIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least one item for this outfit'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await widget.repository.addOutfit(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        isOwned: true,
        clothingItemIds: _selectedItemIds.toList(),
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save outfit: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 720),
      child: Container(
        decoration: BoxDecoration(
          color: _CreateOutfitTheme.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _CreateOutfitTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Header(onClose: _cancel, title: "Create outfit"),
              Container(height: 1, color: _CreateOutfitTheme.border),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Field(
                          label: "Outfit name",
                          child: _PillTextField(
                            controller: _nameCtrl,
                            hintText: WardrobeConstants.defaultOutfitNameHint,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return "Outfit name is required";
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        _Field(
                          label: "Description",
                          helper: WardrobeConstants.outfitDescriptionHelper,
                          child: _TextArea(
                            controller: _descCtrl,
                            hintText:
                                WardrobeConstants.defaultOutfitDescriptionHint,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _Field(
                          label: 'Select wardrobe items',
                          helper:
                              'Pick one or more items to include in this outfit',
                          child:
                              _loadingItems
                                  ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Center(
                                      child: SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                  )
                                  : _items.isEmpty
                                  ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      'No wardrobe items found.',
                                      style: TextStyle(
                                        color: _CreateOutfitTheme.muted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                  : Container(
                                    constraints: const BoxConstraints(
                                      maxHeight: 220,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: _CreateOutfitTheme.border,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListView.builder(
                                      itemCount: _items.length,
                                      itemBuilder: (context, index) {
                                        final item = _items[index];
                                        final itemId =
                                            (item['item_id'] ??
                                                    item['id'] ??
                                                    '')
                                                .toString();
                                        final title =
                                            (item['title'] ?? 'Untitled item')
                                                .toString();
                                        final selected = _selectedItemIds
                                            .contains(itemId);

                                        return Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap:
                                                itemId.isEmpty
                                                    ? null
                                                    : () =>
                                                        _toggleItemSelection(
                                                          itemId,
                                                        ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 2,
                                                  ),
                                              child: Row(
                                                children: [
                                                  Checkbox(
                                                    value: selected,
                                                    onChanged:
                                                        itemId.isEmpty
                                                            ? null
                                                            : (_) =>
                                                                _toggleItemSelection(
                                                                  itemId,
                                                                ),
                                                    activeColor:
                                                        _CreateOutfitTheme.gold,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      title,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(32, 12, 32, 20),
                decoration: BoxDecoration(
                  color: _CreateOutfitTheme.card,
                  border: Border(
                    top: BorderSide(color: _CreateOutfitTheme.border),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _SecondaryButton(text: "Cancel", onPressed: _cancel),
                    const SizedBox(width: 12),
                    _PrimaryButton(
                      text: _saving ? "Saving..." : "Save outfit",
                      onPressed: _saving ? null : _save,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onClose;
  final String title;

  const _Header({required this.onClose, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 22, 20, 18),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Semantics(
            button: true,
            label: "Close dialog",
            child: IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close),
              color: _CreateOutfitTheme.muted,
              splashRadius: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String? helper;
  final Widget child;

  const _Field({required this.label, this.helper, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _CreateOutfitTheme.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 4),
          Text(
            helper!,
            style: const TextStyle(
              color: _CreateOutfitTheme.muted,
              fontSize: 12,
            ),
          ),
        ],
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _PillTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;

  const _PillTextField({
    required this.controller,
    required this.hintText,
    this.validator,
  });

  static const gold = Color(0xFFD4A017);
  static const inputFill = Color(0xFFE5E5E5);
  static const textDark = Color(0xFF111111);
  static const textHint = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(color: textDark, fontSize: 14),
      cursorColor: gold,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: textHint, fontSize: 14),
        filled: true,
        fillColor: inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: gold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
      ),
    );
  }
}

class _TextArea extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const _TextArea({required this.controller, required this.hintText});

  static const gold = Color(0xFFD4A017);
  static const inputFill = Color(0xFFE5E5E5);
  static const textDark = Color(0xFF111111);
  static const textHint = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      minLines: 4,
      maxLines: 6,
      style: const TextStyle(color: textDark, fontSize: 14),
      cursorColor: gold,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: textHint, fontSize: 14),
        filled: true,
        fillColor: inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: gold, width: 2),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const _PrimaryButton({required this.text, required this.onPressed});

  static const gold = Color(0xFFD4A017);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _SecondaryButton({required this.text, required this.onPressed});

  static const border = Color(0xFF2A2F38);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: border),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 18),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
