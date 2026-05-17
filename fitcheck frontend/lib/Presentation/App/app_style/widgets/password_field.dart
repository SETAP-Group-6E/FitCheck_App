// Small password input field with a toggleable visibility icon.
// Use this where a compact password entry is required in forms.
import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;

  const PasswordField(this.controller, {super.key});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      decoration: InputDecoration(
        hintText: "Password",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 10),
        hintStyle: TextStyle(color: Colors.white54),
        suffixIcon: IconButton(
          // Toggle the visibility of the password. This keeps the
          // widget stateful and focused on the single responsibility of
          // controlling `obscureText` for the input field.
          icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      style: TextStyle(color: Colors.white),
    );
  }
}
