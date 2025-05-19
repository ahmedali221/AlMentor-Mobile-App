import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAllPressed;
  final Color? color;
  final bool isDark;

  const SectionTitle({
    super.key,
    required this.title,
    this.onSeeAllPressed,
    this.color,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? (isDark ? Colors.white : Colors.black);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.left,
          ),
          // See All button (arrow)
          if (onSeeAllPressed != null)
            InkWell(
              onTap: onSeeAllPressed,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: textColor,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
