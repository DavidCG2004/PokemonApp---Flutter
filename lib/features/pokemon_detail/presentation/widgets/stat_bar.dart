import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../pokemon_list/data/models/pokemon_model.dart';

class StatBar extends StatelessWidget {
  final PokemonStat stat;
  static const _maxStat = 255.0;

  const StatBar({super.key, required this.stat});

  Color _statColor(int value) {
    if (value >= 100) return const Color(0xFF66BB6A);
    if (value >= 60) return AppColors.accent;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final ratio = (stat.baseStat / _maxStat).clamp(0.0, 1.0);
    final color = _statColor(stat.baseStat);

    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(
            stat.displayName,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 38,
          child: Text(
            stat.baseStat.toString(),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: ratio),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (_, value, __) => LinearProgressIndicator(
                value: value,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 6,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
