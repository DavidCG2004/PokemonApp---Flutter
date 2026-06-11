import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class TypeChip extends StatelessWidget {
  final String type;

  const TypeChip({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.typeColor(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
