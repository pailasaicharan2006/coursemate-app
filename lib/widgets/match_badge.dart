import 'package:flutter/material.dart';

class MatchBadge extends StatelessWidget {
  final double matchScore;

  const MatchBadge({
    super.key,
    required this.matchScore,
  });

  Color _getBadgeColor() {
    if (matchScore >= 80) return Colors.green;
    if (matchScore >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getBadgeColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${matchScore.toInt()}% Match',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
