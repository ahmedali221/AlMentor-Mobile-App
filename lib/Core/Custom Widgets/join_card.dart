import 'package:flutter/material.dart';

class PromoCardWidget extends StatelessWidget {
  const PromoCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE53935), Color(0xFFD32F2F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          // Image or illustration (you can use your own asset)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              width: 100,
              child: Image.asset(
                'assets/images/join.png', // Replace with your actual image path
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Text + Button section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'اكتشف قدراتك',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'كورسات المنتور هتساعدك في الوصول لأهدافك.',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text('اشترك الآن'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
