import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAllPressed;

  const SectionTitle({
    super.key,
    required this.title,
    this.onSeeAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Arrow button
          InkWell(
            onTap: onSeeAllPressed,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(0, 0, 0, 0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),

          // Title
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}