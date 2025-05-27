import 'package:almentor_clone/Core/Providers/language_provider.dart';
import 'package:almentor_clone/pages/courses/certificatePage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../Core/Localization/app_translations.dart';
import '../../models/course.dart';
import '../../models/module.dart';
import '../../models/lesson.dart';

class LessonViewerPage extends StatefulWidget {
  final Course course;
  final List<Module> modules;
  final List<Lesson> lessons;
  final int initialIndex;

  const LessonViewerPage({
    super.key,
    required this.course,
    required this.modules,
    required this.lessons,
    required this.initialIndex,
  });

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locale = Localizations.localeOf(context);

    final lesson = widget.lessons[currentIndex];
    final previousLessons = widget.lessons.sublist(0, currentIndex);
    final nextLessons = widget.lessons.sublist(currentIndex + 1);
    final progress = (currentIndex + 1) / widget.lessons.length;

    final currentModule = getCurrentModule();
    final previousModule = getPreviousModule();
    final nextModule = getNextModule();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          lesson.getLocalizedTitle(locale),
          style: theme.textTheme.titleLarge?.copyWith(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          // Video Player Section
          Container(
            color: Colors.black,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  if (_chewieController != null &&
                      _chewieController!
                          .videoPlayerController.value.isInitialized)
                    Chewie(controller: _chewieController!)
                  else
                    Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Content Section
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Course Progress
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.getLocalizedTitle(locale),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[200],
                                color: const Color(0xFFeb2027),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "${(progress * 100).toStringAsFixed(0)}%",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color:
                                    isDark ? Colors.white70 : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Module Navigation
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        if (previousModule != null)
                          _buildModuleNavItem(
                            context,
                            Icons.arrow_upward,
                            AppTranslations.getText(
                                'previous_module',
                                context
                                    .read<LanguageProvider>()
                                    .currentLocale
                                    .languageCode),
                            previousModule,
                            () {
                              final firstLessonId =
                                  previousModule.lessons.first.id;
                              final idx = widget.lessons
                                  .indexWhere((l) => l.id == firstLessonId);
                              if (idx != -1) _changeLesson(idx);
                            },
                          ),
                        if (currentModule != null)
                          _buildModuleNavItem(
                            context,
                            Icons.folder,
                            AppTranslations.getText(
                                'current_module',
                                context
                                    .read<LanguageProvider>()
                                    .currentLocale
                                    .languageCode),
                            currentModule,
                            null,
                          ),
                        if (nextModule != null)
                          _buildModuleNavItem(
                            context,
                            Icons.arrow_downward,
                            AppTranslations.getText(
                                'next_module',
                                context
                                    .read<LanguageProvider>()
                                    .currentLocale
                                    .languageCode),
                            nextModule,
                            () {
                              final firstLessonId = nextModule.lessons.first.id;
                              final idx = widget.lessons
                                  .indexWhere((l) => l.id == firstLessonId);
                              if (idx != -1) _changeLesson(idx);
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                // Lessons Lists
                if (previousLessons.isNotEmpty)
                  _buildLessonsList(
                    context,
                    AppTranslations.getText(
                        'previous_lessons',
                        context
                            .read<LanguageProvider>()
                            .currentLocale
                            .languageCode),
                    previousLessons,
                    isDark,
                    (index) => _changeLesson(index),
                  ),

                if (nextLessons.isNotEmpty)
                  _buildLessonsList(
                    context,
                    AppTranslations.getText(
                        'next_lessons',
                        context
                            .read<LanguageProvider>()
                            .currentLocale
                            .languageCode),
                    nextLessons,
                    isDark,
                    (index) => _changeLesson(currentIndex + 1 + index),
                  ),

                const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
              ],
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, -2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: Text(AppTranslations.getText('previous_lesson',
                  context.read<LanguageProvider>().currentLocale.languageCode)),
              onPressed: currentIndex > 0
                  ? () => _changeLesson(currentIndex - 1)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFeb2027),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey,
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: Text(
                currentIndex == widget.lessons.length - 1
                    ? AppTranslations.getText(
                        'course_completed',
                        context
                            .read<LanguageProvider>()
                            .currentLocale
                            .languageCode)
                    : AppTranslations.getText(
                        'next_lesson',
                        context
                            .read<LanguageProvider>()
                            .currentLocale
                            .languageCode),
              ),
              onPressed: _onNextPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFeb2027),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleNavItem(
    BuildContext context,
    IconData icon,
    String label,
    Module module,
    VoidCallback? onTap,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? Colors.white70 : Colors.grey[700],
      ),
      title: Text(
        "$label: ${module.getLocalizedTitle(Localizations.localeOf(context) as String)}",
        style: theme.textTheme.titleMedium?.copyWith(
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildLessonsList(
    BuildContext context,
    String title,
    List<Lesson> lessons,
    bool isDark,
    Function(int) onTap,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                ),
              );
            }

            final lesson = lessons[index - 1];
            return Card(
              color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  Icons.play_circle_outline,
                  color: isDark ? Colors.white70 : Colors.grey[700],
                ),
                title: Text(
                  lesson.getLocalizedTitle(Localizations.localeOf(context)),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                ),
                onTap: () => onTap(index - 1),
              ),
            );
          },
          childCount: lessons.length + 1,
        ),
      ),
    );
  }
}
