import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Core/Providers/themeProvider.dart';

class ClipsPage extends StatelessWidget {
  const ClipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Example data
    final String subtitle = "إعادة بناء حياتك بعد الطلاق";
    final String discoverText = "اكتشف المزيد";
    final String videoImage =
        "assets/images/teacher2.png"; // Replace with your image asset
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Video/Image
          Positioned.fill(
            child: Image.asset(
              videoImage,
              fit: BoxFit.cover,
            ),
          ),
          // Centered loading spinner (simulate loading)
          Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
              strokeWidth: 3,
            ),
          ),
          // Theme toggle button
          Positioned(
            top: 40,
            right: 16,
            child: IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: Colors.white,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
            ),
          ),
          // Bottom overlays
          Positioned(
            left: 0,
            right: 0,
            bottom: 90,
            child: Column(
              children: [
                // Subtitle
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                // Discover more button
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 80),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: () {},
                    child: Text(
                      discoverText,
                      style: const TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Left side buttons (Like, Share)
          Positioned(
            left: 12,
            bottom: 110,
            child: Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border,
                      color: Colors.white, size: 32),
                  onPressed: () {},
                ),
                const Text(
                  'اعجبني',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 18),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white, size: 32),
                  onPressed: () {},
                ),
                const Text(
                  'مشاركة',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
