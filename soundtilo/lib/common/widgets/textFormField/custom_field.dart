import 'package:flutter/material.dart';

class CustomField extends StatefulWidget {
  final String labelText;
  final TextEditingController controller;
  final bool isObscureText;
  final FormFieldValidator<String>? validator;

  const CustomField({
    super.key,
    required this.labelText,
    required this.controller,
    this.isObscureText = false,
    this.validator,
  });

  @override
  State<CustomField> createState() => _CustomFieldState();
}

class _CustomFieldState extends State<CustomField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.isObscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.labelText,
        suffixIcon: widget.isObscureText
            ? IconButton(
                icon: Icon(
                  _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : null,
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
      validator: widget.validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập ${widget.labelText}';
            }
            return null;
          },
      obscureText: _obscured,
      obscuringCharacter: '♥',
    );
  }
}
