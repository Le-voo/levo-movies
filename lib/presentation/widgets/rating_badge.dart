import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class RatingBadge extends StatelessWidget {
  final double rating;
  final double size;
  final bool isCompact;

  const RatingBadge({
    super.key,
    required this.rating,
    this.size = 36,
    this.isCompact = false,
  });

  Color _getRatingColor(double score) {
    if (score >= 7.5) return const Color(0xFF10B981); // Emerald Green
    if (score >= 6.0) return AppColors.primaryGold; // Amber/Gold
    if (score > 0.0) return const Color(0xFFF97316); // Orange
    return AppColors.darkTextMuted;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getRatingColor(rating);
    final formatted = rating > 0 ? rating.toStringAsFixed(1) : 'NR';

    if (isCompact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.6), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_rounded, color: color, size: 14),
            const SizedBox(width: 3),
            Text(
              formatted,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF0F172A).withValues(alpha: 0.9),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          formatted,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: size * 0.36,
          ),
        ),
      ),
    );
  }
}
