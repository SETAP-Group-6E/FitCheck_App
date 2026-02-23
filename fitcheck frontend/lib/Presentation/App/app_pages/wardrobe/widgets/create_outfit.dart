import 'package:flutter/material.dart';

class _CreateOutfitTheme {
  static const Color card = Color(0xFF171A20);
  static const Color border = Color(0xFF2A2F38);
  static const Color gold = Color(0xFFD4A017);
  static const Color muted = Color(0xFFA1A1AA);
}

class CreateOutfitModal extends StatefulWidget {
  const CreateOutfitModal({super.key});

  /// Opens the modal and returns true if the user pressed "Save outfit"
  static Future<bool> open(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.60),
      builder: (_) => const Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: CreateOutfitModal(),
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

  bool _isOwned = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _cancel() => Navigator.of(context).pop(false);

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    // UI only: just close + return true
    // Later you can insert into Supabase here.
    Navigator.of(context).pop(true);
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
                            hintText: "e.g. Winter street fit",
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
                          helper: "Optional notes (style, weather, occasion, etc.)",
                          child: _TextArea(
                            controller: _descCtrl,
                            hintText: "Add a short description for this outfit...",
                          ),
                        ),
                        const SizedBox(height: 20),

                        _CheckboxRow(
                          title: "Owned",
                          subtitle: "Tick if you currently own this outfit",
                          value: _isOwned,
                          onChanged: (v) => setState(() => _isOwned = v),
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
                  border: Border(top: BorderSide(color: _CreateOutfitTheme.border)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _SecondaryButton(text: "Cancel", onPressed: _cancel),
                    const SizedBox(width: 12),
                    _PrimaryButton(text: "Save outfit", onPressed: _save),
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

/* ---------------- UI PARTS ---------------- */

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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        label,
        style: const TextStyle(color: _CreateOutfitTheme.muted, fontSize: 12, fontWeight: FontWeight.w600),
      ),
      if (helper != null) ...[
        const SizedBox(height: 4),
        Text(helper!, style: const TextStyle(color: _CreateOutfitTheme.muted, fontSize: 12)),
      ],
      const SizedBox(height: 6),
      child,
    ]);
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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

  const _TextArea({
    required this.controller,
    required this.hintText,
  });

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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Theme(
        data: Theme.of(context).copyWith(
          unselectedWidgetColor: _CreateOutfitTheme.border,
          checkboxTheme: CheckboxThemeData(
            fillColor: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.selected)
                  ? _CreateOutfitTheme.gold
                  : Colors.transparent;
            }),
            side: const BorderSide(
                color: _CreateOutfitTheme.border, width: 1.5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(
                  color: _CreateOutfitTheme.muted, fontSize: 12)),
        ]),
      ),
    ]);
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
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
