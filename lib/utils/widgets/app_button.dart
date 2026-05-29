import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class AppButton extends StatelessWidget {
  final String      label;
  final VoidCallback? onPressed;
  final IconData?   icon;
  final Color       color;
  final bool        outlined;
  final bool        loading;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color    = AppColors.primary,
    this.outlined = false,
    this.loading  = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: loading
          ? const SizedBox(
              key: ValueKey('loading'),
              width: 20, height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2.5, color: Colors.white))
          : Row(
              key: const ValueKey('content'),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(label),
              ],
            ),
    );

    final style = outlined
        ? OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color),
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 20),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            textStyle: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 20),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            textStyle: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600),
          );

    return SizedBox(
      width: double.infinity,
      child: outlined
          ? OutlinedButton(
              style: style, onPressed: loading ? null : onPressed,
              child: content)
          : ElevatedButton(
              style: style, onPressed: loading ? null : onPressed,
              child: content),
    );
  }
}
