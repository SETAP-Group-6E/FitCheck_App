import 'package:flutter/material.dart';

class _CreateItemTheme {
  static const Color card = Color(0xFF171A20);
  static const Color border = Color(0xFF2A2F38);
  static const Color gold = Color(0xFFD4A017);
  static const Color muted = Color(0xFFA1A1AA);
  static const Color inputFill = Color(0xFFE5E5E5);
  static const Color textDark = Color(0xFF111111);
  static const Color textHint = Color(0xFF6B7280);
}

class CreateItem extends StatefulWidget {
  const CreateItem({super.key});

  static Future<bool> open(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      builder:
          (_) => const Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: CreateItem(),
          ),
    );
    return result ?? false;
  }

  @override
  State<CreateItem> createState() => _CreateItemState();
}

class _CreateItemState extends State<CreateItem> {
  static const wearTypes = [
    "Top",
    "Bottom",
    "Footwear",
    "Outerwear",
    "Accessory",
  ];

  static const fabricMaterials = [
    "Cotton",
    "Denim",
    "Wool",
    "Leather",
    "Polyester",
    "Nylon",
    "Other",
  ];

  static const layerCategories = [
    "Base layer",
    "Mid layer",
    "Outer layer",
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
    if (!mounted) return;
    Navigator.of(context).pop(true);
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
              color: Colors.black.withOpacity(0.25),
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

          dropdownColor: _CreateItemTheme.inputFill,

          iconEnabledColor: _CreateItemTheme.textHint,

          style: const TextStyle(
            color: _CreateItemTheme.textDark,
            fontSize: 14,
          ),

          items:
              items
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(
                        s,
                        style: const TextStyle(
                          color: _CreateItemTheme.textDark,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                  .toList(),

          onChanged: (v) => onChanged(v ?? value),
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
      padding: const EdgeInsets.fromLTRB(32, 20, 32, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Create item",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: onClose,
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
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _PhotoBoxUIOnly extends StatelessWidget {
  final bool hasPhoto;
  final VoidCallback onUpload;

  const _PhotoBoxUIOnly({required this.hasPhoto, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onUpload,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: _CreateItemTheme.inputFill,
          borderRadius: BorderRadius.circular(16),
          border:
              hasPhoto
                  ? null
                  : Border.all(
                    color: _CreateItemTheme.border,
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
        ),
        child: Center(
          child:
              hasPhoto
                  ? const Icon(
                    Icons.check_circle,
                    size: 48,
                    color: Colors.green,
                  )
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 48,
                        color: _CreateItemTheme.textHint,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Upload photo",
                        style: TextStyle(
                          color: _CreateItemTheme.textHint,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
        ),
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
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            if (helper != null) ...[
              const SizedBox(width: 8),
              Tooltip(
                message: helper,
                child: Icon(
                  Icons.info_outline,
                  size: 16,
                  color: _CreateItemTheme.textHint,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
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
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: _CreateItemTheme.textHint),
        filled: true,
        fillColor: _CreateItemTheme.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      style: const TextStyle(color: _CreateItemTheme.textDark, fontSize: 14),
      validator: validator,
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
        Slider(
          value: value.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          onChanged: (v) => onChanged(v.toInt()),
          activeColor: _CreateItemTheme.gold,
          inactiveColor: _CreateItemTheme.border,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (i) {
            final level = i + 1;
            return Text(
              level.toString(),
              style: TextStyle(
                fontSize: 12,
                color:
                    level == value
                        ? _CreateItemTheme.gold
                        : _CreateItemTheme.textHint,
                fontWeight:
                    level == value ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }),
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _CreateItemTheme.border),
      ),
      child: CheckboxListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: _CreateItemTheme.textHint),
        ),
        value: value,
        onChanged: (v) => onChanged(v ?? false),
        activeColor: _CreateItemTheme.gold,
        checkColor: Colors.black,
        tileColor: Colors.transparent,
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
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.white24),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const _PrimaryButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _CreateItemTheme.gold,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        disabledBackgroundColor: _CreateItemTheme.muted,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: _CreateItemTheme.textDark,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
