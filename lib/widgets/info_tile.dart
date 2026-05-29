import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class InfoTile extends StatelessWidget {
  final String  label;
  final String  value;
  final IconData? icon;
  final Color?  valueColor;

  const InfoTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 6),
          ],
          SizedBox(
            width: 116,
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(
                  color: valueColor ?? AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class SectionDivider extends StatelessWidget {
  const SectionDivider({super.key});

  @override
  Widget build(BuildContext context) => const Divider(
      height: 20, thickness: 1, color: AppColors.border);
}
