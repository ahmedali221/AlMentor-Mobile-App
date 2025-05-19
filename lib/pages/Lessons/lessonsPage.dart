import 'package:almentor_clone/models/lesson.dart';
import 'package:almentor_clone/services/lesson_service.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class LessonsPage extends StatefulWidget {
  final String courseId;

  const LessonsPage({Key? key, required this.courseId}) : super(key: key);

  @override
  State<LessonsPage> createState() => _LessonsPageState();
}

class _LessonsPageState extends State<LessonsPage> {
  final LessonService _lessonService = LessonService();
  List<Lesson> lessons = [];
  bool isLoading = true;
  String errorMessage = '';
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    fetchLessons();
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> fetchLessons() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final List<dynamic> data =
          await _lessonService.getLessonsByCourse(widget.courseId);
      lessons = data.map((json) => Lesson.fromJson(json)).toList();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading lessons: $e';
      });
    }
  }

  void playVideo(String videoUrl) {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();

    _videoPlayerController = VideoPlayerController.network(videoUrl);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true,
      looping: false,
    );

    _videoPlayerController!.initialize().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: const Text('Lessons')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                  itemCount: lessons.length,
                  itemBuilder: (context, index) {
                    final lesson = lessons[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(lesson.getLocalizedTitle(lang)),
                        subtitle: Text('${lesson.duration} minutes'),
                        trailing: lesson.videoUrl != null
                            ? IconButton(
                                icon: const Icon(Icons.play_circle_outline),
                                onPressed: () => playVideo(lesson.videoUrl!),
                              )
                            : null,
                      ),
                    );
                  },
                ),
      bottomNavigationBar: _chewieController != null &&
              _videoPlayerController!.value.isInitialized
          ? SizedBox(
              height: 250,
              child: Chewie(controller: _chewieController!),
            )
          : null,
    );
  }
}
