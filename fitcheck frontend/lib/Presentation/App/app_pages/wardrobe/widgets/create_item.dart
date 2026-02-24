import 'package:flutter/material.dart';
import 'package:fitcheck/Domain/repositories/wardrobe_repository.dart';

class _CreateItemTheme {
  static const Color card = Color(0xFF171A20);
  static const Color border = Color(0xFF2A2F38);
  static const Color gold = Color(0xFFD4A017);
  static const Color muted = Color(0xFFA1A1AA);
  static const Color inputFill = Color(0xFFE5E5E5);
  static const Color bg = Color(0xFF0F1115);
  static const Color textDark = Color(0xFF111111);
  static const Color textHint = Color(0xFF6B7280);
}

class CreateItem extends StatefulWidget {
  const CreateItem({super.key, required this.repository});

  final WardrobeRepository repository;

  static Future<bool> open(
    BuildContext context, {
    required WardrobeRepository repository,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder:
          (_) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: CreateItem(repository: repository),
          ),
    );
    return result ?? false;
  }

  @override
  State<CreateItem> createState() => _CreateItemState();
}

class _CreateItemState extends State<CreateItem> {
  static const wearTypes = <String>[
    "Smart",
    "Casual",
    "Formal",
  ];
  static const fabricMaterials = <String>[
    "Cotton",
    "Denim",
    "Wool",
    "Leather",
    "Polyester",
    "Nylon",
    "Other",
  ];
  static const layerCategories = <String>[
    "coat",
    "jumper",
    "sweater",
    "Single layer",
  ];

  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();

  String _wearType = wearTypes.first;
  String _fabricMaterial = fabricMaterials.first;
  String _layerCategory = layerCategories.first;
  int _warmthRating = 3;
  bool _waterResistant = false;

  bool _hasPhoto = false;
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  void _cancel() => Navigator.of(context).pop(false);

  void _fakePickImage() {
    setState(() => _hasPhoto = true);
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      await widget.repository.addClothingItem(
        photoUrl: _hasPhoto ? 'local-upload-pending' : '',
        title: _titleCtrl.text.trim(),
        wearType: _wearType,
        fabricMaterial: _fabricMaterial,
        warmthRating: _warmthRating,
        waterResistance: _waterResistant,
        layerCategory: _layerCategory,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save item: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 720),
      child: Container(
        decoration: BoxDecoration(
          color: _CreateItemTheme.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _CreateItemTheme.border),
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
              _Header(onClose: _cancel),
              Container(height: 1, color: _CreateItemTheme.border),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Label("Photo"),
                        const SizedBox(height: 12),
                        _PhotoBoxUIOnly(
                          hasPhoto: _hasPhoto,
                          onUpload: _fakePickImage,
                        ),
                        const SizedBox(height: 24),
                        _Field(
                          label: "Item name",
                          child: _PillTextField(
                            controller: _titleCtrl,
                            hintText: "e.g. Black puffer jacket",
                            validator:
                                (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? "Item name is required"
                                        : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _Field(
                          label: "Wear type",
                          child: _PillDropdown(
                            value: _wearType,
                            items: wearTypes,
                            onChanged: (v) => setState(() => _wearType = v),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _Field(
                          label: "Fabric material",
                          child: _PillDropdown(
                            value: _fabricMaterial,
                            items: fabricMaterials,
                            onChanged:
                                (v) => setState(() => _fabricMaterial = v),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _Field(
                          label: "Layer category",
                          helper: "Used for outfit layering logic",
                          child: _PillDropdown(
                            value: _layerCategory,
                            items: layerCategories,
                            onChanged:
                                (v) => setState(() => _layerCategory = v),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const _Label("Warmth rating"),
                        const SizedBox(height: 10),
                        _WarmthSlider(
                          value: _warmthRating,
                          onChanged: (v) => setState(() => _warmthRating = v),
                        ),
                        const SizedBox(height: 20),
                        _CheckboxRow(
                          title: "Water resistant",
                          subtitle: "Tick if it handles rain",
                          value: _waterResistant,
                          onChanged: (v) => setState(() => _waterResistant = v),
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
                  color: _CreateItemTheme.card,
                  border: Border(
                    top: BorderSide(color: _CreateItemTheme.border),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _SecondaryButton(text: "Cancel", onPressed: _cancel),
                    const SizedBox(width: 12),
                    _PrimaryButton(
                      text: _saving ? "Saving..." : "Save item",
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
  const _Header({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 22, 20, 18),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Add new item",
              style: TextStyle(
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
              color: _CreateItemTheme.muted,
              splashRadius: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _CreateItemTheme.muted,
        fontSize: 12,
        fontWeight: FontWeight.w600,
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
            color: _CreateItemTheme.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 4),
          Text(
            helper!,
            style: const TextStyle(color: _CreateItemTheme.muted, fontSize: 12),
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

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(color: _CreateItemTheme.textDark, fontSize: 14),
      cursorColor: _CreateItemTheme.gold,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: _CreateItemTheme.textHint,
          fontSize: 14,
        ),
        filled: true,
        fillColor: _CreateItemTheme.inputFill,
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
          borderSide: const BorderSide(color: _CreateItemTheme.gold, width: 2),
        ),
      ),
    );
  }
}

class _PillDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  const _PillDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: _CreateItemTheme.inputFill,
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: _CreateItemTheme.bg,
          iconEnabledColor: _CreateItemTheme.muted,
          style: const TextStyle(
            color: _CreateItemTheme.textDark,
            fontSize: 14,
          ),
          items:
              items
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
          onChanged: (v) => onChanged(v ?? value),
        ),
      ),
    );
  }
}

class _WarmthSlider extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _WarmthSlider({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 6,
                  activeTrackColor: _CreateItemTheme.gold,
                  inactiveTrackColor: _CreateItemTheme.border,
                  thumbColor: Colors.white,
                  overlayColor: _CreateItemTheme.gold.withValues(alpha: 0.15),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 9,
                  ),
                ),
                child: Slider(
                  min: 1,
                  max: 5,
                  divisions: 4,
                  value: value.toDouble(),
                  onChanged: (v) => onChanged(v.round()),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _CreateItemTheme.bg,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: _CreateItemTheme.border),
              ),
              child: Text(
                value.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          "1 = Light   5 = Very warm",
          style: TextStyle(color: _CreateItemTheme.muted, fontSize: 12),
        ),
      ],
    );
  }
}

class _CheckboxRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _CheckboxRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Theme(
          data: Theme.of(context).copyWith(
            unselectedWidgetColor: _CreateItemTheme.border,
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.resolveWith(
                (states) =>
                    states.contains(WidgetState.selected)
                        ? _CreateItemTheme.gold
                        : Colors.transparent,
              ),
              side: const BorderSide(
                color: _CreateItemTheme.border,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              checkColor: WidgetStateProperty.all(Colors.white),
            ),
          ),
          child: Semantics(
            enabled: true,
            label: title,
            child: Checkbox(
              value: value,
              onChanged: (v) => onChanged(v ?? false),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _CreateItemTheme.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PhotoBoxUIOnly extends StatelessWidget {
  final bool hasPhoto;
  final VoidCallback onUpload;
  const _PhotoBoxUIOnly({required this.hasPhoto, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 312,
          width: 312,
          decoration: BoxDecoration(
            color: _CreateItemTheme.bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _CreateItemTheme.border),
          ),
          child:
              hasPhoto
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image,
                        size: 64,
                        color: _CreateItemTheme.muted,
                      ),
                    ),
                  )
                  : Center(
                    child: Semantics(
                      label: "Photo upload area",
                      child: Text(
                        "Upload item photo",
                        style: const TextStyle(
                          color: _CreateItemTheme.muted,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 312,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _CreateItemTheme.gold,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            onPressed: onUpload,
            child: Text(hasPhoto ? "Change photo" : "Upload"),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  const _PrimaryButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _CreateItemTheme.gold,
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: _CreateItemTheme.border),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 18),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
