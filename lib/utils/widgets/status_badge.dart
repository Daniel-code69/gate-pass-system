import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    switch (status) {
      case 'PENDING':
        color = AppColors.warning;
        label = 'Pending';
      case 'ACTIVE':
        color = AppColors.success;
        label = 'Active';
      case 'EXITED':
        color = AppColors.textMuted;
        label = 'Exited';
      default:
        color = AppColors.textMuted;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
