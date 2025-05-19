import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
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
  List<Lesson> clips = [];
  bool isLoading = true;
  int? currentClipIndex;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    fetchClips();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> fetchClips() async {
    setState(() {
      isLoading = true;
    });
    final lessons =
        await _lessonService.getLessonsByCourse("68229da9d1c55a309691728c");
    if (lessons.isNotEmpty) {
      final lessonClips = lessons
          .map((json) => Lesson.fromJson(json))
          .where((lesson) =>
              lesson.content.videoUrl != null &&
              lesson.content.videoUrl!.isNotEmpty)
          .toList();
      lessonClips.shuffle(Random());
      setState(() {
        clips = lessonClips;
        currentClipIndex = 0;
        isLoading = false;
      });
      await _initializeVideo(clips[0].content.videoUrl!);
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _initializeVideo(String url) async {
    _videoController?.dispose();
    _videoController = VideoPlayerController.network(url);
    await _videoController!.initialize();
    _videoController!.setLooping(true);
    _videoController!.play();
    setState(() {});
  }

  void showNextClip() async {
    if (clips.isNotEmpty) {
      final nextIndex = (currentClipIndex! + 1) % clips.length;
      setState(() {
        currentClipIndex = nextIndex;
      });
      await _initializeVideo(clips[nextIndex].content.videoUrl!);
    }
  }

  void showPreviousClip() async {
    if (clips.isNotEmpty) {
      final prevIndex = (currentClipIndex! - 1 + clips.length) % clips.length;
      setState(() {
        currentClipIndex = prevIndex;
      });
      await _initializeVideo(clips[prevIndex].content.videoUrl!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading || clips.isEmpty || currentClipIndex == null
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
                strokeWidth: 3,
              ),
            )
          : GestureDetector(
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity != null) {
                  if (details.primaryVelocity! < 0) {
                    // Swipe up
                    showNextClip();
                  } else if (details.primaryVelocity! > 0) {
                    // Swipe down
                    showPreviousClip();
                  }
                }
              },
              child: Stack(
                children: [
                  // Video player
                  Positioned.fill(
                    child: _videoController != null &&
                            _videoController!.value.isInitialized
                        ? AspectRatio(
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: VideoPlayer(_videoController!),
                          )
                        : Container(
                            color: Colors.black,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),

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

                  // Instructor info overlay with gradient background
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 20, // Moved lower
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          // Instructor photo
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              image: DecorationImage(
                                image: NetworkImage(
                                  clips[currentClipIndex!]
                                          .course
                                          ?.instructor
                                          ?.user
                                          ?.profilePicture ??
                                      'https://via.placeholder.com/50',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Instructor details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${clips[currentClipIndex!].course?.instructor?.user?.firstNameEn}'
                                  '${clips[currentClipIndex!].course?.instructor?.user?.lastNameEn}',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (clips[currentClipIndex!]
                                        .course
                                        ?.instructor
                                        ?.professionalTitleEn !=
                                    null)
                                  Text(
                                    clips[currentClipIndex!]
                                        .course!
                                        .instructor!
                                        .professionalTitleEn,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // Follow button
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Follow',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
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
                        const Text('Like',
                            style:
                                TextStyle(color: Colors.white, fontSize: 14)),
                        const SizedBox(height: 18),
                        IconButton(
                          icon: const Icon(Icons.share,
                              color: Colors.white, size: 32),
                          onPressed: () {},
                        ),
                        const Text('Share',
                            style:
                                TextStyle(color: Colors.white, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
