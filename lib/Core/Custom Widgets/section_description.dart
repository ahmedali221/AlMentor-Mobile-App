import 'package:flutter/material.dart';

class SectionDescription extends StatelessWidget {
  final String description;
  final Color? color;
  final bool isDark;

  const SectionDescription({
    super.key,
    required this.description,
    this.color,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? (isDark ? Colors.grey[300] : Colors.grey[800]);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
