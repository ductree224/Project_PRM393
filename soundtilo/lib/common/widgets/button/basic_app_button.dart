import 'package:flutter/material.dart';

class BasicAppButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final double? height;

  const BasicAppButton({
    this.height,
    required this.onPressed,
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: Size.fromHeight(height ?? 56),
        ),
        child: Text(
            title
        ),
    );
  }
}
