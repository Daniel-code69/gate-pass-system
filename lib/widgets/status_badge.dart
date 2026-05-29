import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status; // 'ACTIVE' | 'EXITED'

  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'ACTIVE';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isActive ? AppColors.success : AppColors.textMuted)
            .withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? AppColors.success : AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isActive ? 'Active' : 'Exited',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isActive ? AppColors.success : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
