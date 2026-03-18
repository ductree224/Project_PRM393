import 'package:flutter/material.dart';

class CustomField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final bool isObscureText;

  const CustomField({
    super.key,
    required this.labelText,
    required this.controller,
    this.isObscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
      ).applyDefaults(
          Theme.of(context).inputDecorationTheme
      ),
      validator: (value) {
        if (value!.trim().isEmpty) return 'Vui lòng nhập $labelText';
        return null;
      },
      obscureText: isObscureText,
      obscuringCharacter: '♥',
    );
  }
}
