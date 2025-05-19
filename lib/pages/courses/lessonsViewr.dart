import 'package:almentor_clone/pages/courses/certificatePage.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../models/course.dart';
import '../../models/module.dart';
import '../../models/lesson.dart';

class LessonViewerPage extends StatefulWidget {
  final Course course;
  final List<Module> modules;
  final List<Lesson> lessons;
  final int initialIndex;

  const LessonViewerPage({
    Key? key,
    required this.course,
    required this.modules,
    required this.lessons,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<LessonViewerPage> createState() => _LessonViewerPageState();
}

class _LessonViewerPageState extends State<LessonViewerPage> {
  late int currentIndex;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _loadVideo();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    _chewieController = null;
    _videoPlayerController = null;
    super.dispose();
  }

  Future<void> _loadVideo() async {
    final url = widget.lessons[currentIndex].content.videoUrl;

    _chewieController?.dispose();
    await _videoPlayerController?.dispose();
    _chewieController = null;
    _videoPlayerController = null;

    _videoPlayerController = VideoPlayerController.network(url);

    try {
      await _videoPlayerController!.initialize();
      if (_isDisposed) return;
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
      );
      if (mounted) setState(() {});
    } catch (e) {
      // Optionally handle error
    }
  }

  void _changeLesson(int newIndex) {
    if (newIndex < 0 || newIndex >= widget.lessons.length) return;
    setState(() {
      currentIndex = newIndex;
    });
    _loadVideo();
  }

  void _onNextPressed() {
    if (currentIndex < widget.lessons.length - 1) {
      _changeLesson(currentIndex + 1);
    } else {
      // Course completed, navigate to congratulations page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const CongratulationsPage(),
        ),
      );
    }
  }

  Module? getCurrentModule() {
    for (final module in widget.modules) {
      if (module.lessons.any((l) => l.id == widget.lessons[currentIndex].id)) {
        return module;
      }
    }
    return null;
  }

  Module? getPreviousModule() {
    final currentModule = getCurrentModule();
    if (currentModule == null) return null;
    final idx = widget.modules.indexOf(currentModule);
    if (idx > 0) return widget.modules[idx - 1];
    return null;
  }

  Module? getNextModule() {
    final currentModule = getCurrentModule();
    if (currentModule == null) return null;
    final idx = widget.modules.indexOf(currentModule);
    if (idx < widget.modules.length - 1) return widget.modules[idx + 1];
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lessons[currentIndex];
    final previousLessons = widget.lessons.sublist(0, currentIndex);
    final nextLessons = widget.lessons.sublist(currentIndex + 1);

    final progress = (currentIndex + 1) / widget.lessons.length;

    final previousModule = getPreviousModule();
    final nextModule = getNextModule();
    final currentModule = getCurrentModule();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(lesson.getLocalizedTitle(Localizations.localeOf(context))),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_chewieController != null &&
                  _chewieController!.videoPlayerController.value.isInitialized)
                AspectRatio(
                  aspectRatio: _videoPlayerController!.value.aspectRatio,
                  child: Chewie(controller: _chewieController!),
                )
              else
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  lesson.getLocalizedTitle(Localizations.localeOf(context)),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.grey[300],
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text("${((progress) * 100).toStringAsFixed(0)}%"),
                  ],
                ),
              ),
              // Module navigation
              if (previousModule != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ListTile(
                    leading: const Icon(Icons.arrow_upward),
                    title: Text(
                      "Previous Module: ${previousModule.getLocalizedTitle(Localizations.localeOf(context) as String)}",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    onTap: () {
                      // Go to first lesson of previous module
                      final firstLessonId = previousModule.lessons.first.id;
                      final idx = widget.lessons
                          .indexWhere((l) => l.id == firstLessonId);
                      if (idx != -1) _changeLesson(idx);
                    },
                  ),
                ),
              if (currentModule != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ListTile(
                    leading: const Icon(Icons.folder),
                    title: Text(
                      "Current Module: ${currentModule.getLocalizedTitle(Localizations.localeOf(context) as String)}",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              if (nextModule != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ListTile(
                    leading: const Icon(Icons.arrow_downward),
                    title: Text(
                      "Next Module: ${nextModule.getLocalizedTitle(Localizations.localeOf(context) as String)}",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    onTap: () {
                      // Go to first lesson of next module
                      final firstLessonId = nextModule.lessons.first.id;
                      final idx = widget.lessons
                          .indexWhere((l) => l.id == firstLessonId);
                      if (idx != -1) _changeLesson(idx);
                    },
                  ),
                ),
              // Navigation buttons
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.arrow_back),
                      label: const Text("Previous"),
                      onPressed: currentIndex > 0
                          ? () => _changeLesson(currentIndex - 1)
                          : null,
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(
                        currentIndex == widget.lessons.length - 1
                            ? "Finish"
                            : "Next",
                      ),
                      onPressed: _onNextPressed,
                    ),
                  ],
                ),
              ),
              // Previous Lessons List (vertical)
              if (previousLessons.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    "Previous Lessons",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              if (previousLessons.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: previousLessons.length,
                  itemBuilder: (context, index) {
                    final idx = index;
                    final prevLesson = previousLessons[idx];
                    return Card(
                      color: Colors.grey[100],
                      child: ListTile(
                        leading: const Icon(Icons.play_circle_outline),
                        title: Text(prevLesson.getLocalizedTitle(
                            Localizations.localeOf(context))),
                        onTap: () => _changeLesson(idx),
                      ),
                    );
                  },
                ),
              // Next Lessons List (vertical)
              if (nextLessons.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    "Next Lessons",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              if (nextLessons.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: nextLessons.length,
                  itemBuilder: (context, index) {
                    final idx = currentIndex + 1 + index;
                    final nextLesson = nextLessons[index];
                    return Card(
                      color: Colors.grey[100],
                      child: ListTile(
                        leading: const Icon(Icons.play_circle_outline),
                        title: Text(nextLesson.getLocalizedTitle(
                            Localizations.localeOf(context))),
                        onTap: () => _changeLesson(idx),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
