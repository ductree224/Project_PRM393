import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';

class MiniEqualizer extends StatefulWidget {
  final Color? color;
  const MiniEqualizer({super.key, this.color});

  @override
  State<MiniEqualizer> createState() => _MiniEqualizerState();
}

class _MiniEqualizerState extends State<MiniEqualizer> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(3, (index) => AnimatedBuilder(
        animation: _ctrl,
        builder: (ctx, child) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          width: 3,
          height: 8 + 8 * math.sin(_ctrl.value * 2 * math.pi + (index * 1.5)),
          decoration: BoxDecoration(
            color: widget.color ?? AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      )),
    );
  }
}