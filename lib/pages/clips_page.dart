import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Core/Providers/themeProvider.dart';
import '../models/lesson.dart';
import '../services/lesson_service.dart';

class ClipsPage extends StatefulWidget {
  const ClipsPage({super.key});

  @override
  State<ClipsPage> createState() => _ClipsPageState();
}

class _ClipsPageState extends State<ClipsPage> {
  final LessonService _lessonService = LessonService();
  Lesson? randomLesson;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRandomLesson();
  }

  Future<void> fetchRandomLesson() async {
    final lessons =
        await _lessonService.getLessonsByCourse("68229da9d1c55a309691728c");
    if (lessons.isNotEmpty) {
      final random = Random();
      setState(() {
        randomLesson = Lesson.fromJson(lessons[random.nextInt(lessons.length)]);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: isLoading || randomLesson == null
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
                strokeWidth: 3,
              ),
            )
          : Stack(
              children: [
                // Background image or fallback
                // Positioned.fill(
                //   child: randomLesson!.videoUrl != null
                //       ? Image.asset(
                //           'assets/images/teacher2.png', // Can be thumbnail later
                //           fit: BoxFit.cover,
                //         )
                //       : Container(color: Colors.grey[900]),
                // ),

                // Theme toggle
                Positioned(
                  top: 40,
                  right: 16,
                  child: IconButton(
                    icon: Icon(
                      themeProvider.isDarkMode
                          ? Icons.light_mode
                          : Icons.dark_mode,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      themeProvider.toggleTheme();
                    },
                  ),
                ),

                // Subtitle + Button
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 90,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "ar",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 80),
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: () {},
                          child: const Text("اكتشف المزيد",
                              style:
                                  TextStyle(fontSize: 15, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),

                // Left side buttons
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
                      const Text('اعجبني',
                          style: TextStyle(color: Colors.white, fontSize: 14)),
                      const SizedBox(height: 18),
                      IconButton(
                        icon: const Icon(Icons.share,
                            color: Colors.white, size: 32),
                        onPressed: () {},
                      ),
                      const Text('مشاركة',
                          style: TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
