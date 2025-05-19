import 'package:almentor_clone/models/module.dart';
import 'package:almentor_clone/pages/courses/lessonsViewr.dart';
import 'package:flutter/material.dart';

import '../../models/course.dart';
import '../../models/lesson.dart';
import '../../services/course_service.dart';
import '../../services/module_service.dart';
import '../../services/lesson_service.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:provider/provider.dart';
import '../../Core/Providers/themeProvider.dart';

class CourseDetails extends StatefulWidget {
  final String courseId;

  const CourseDetails({Key? key, required this.courseId}) : super(key: key);

  @override
  State<CourseDetails> createState() => _CourseDetailsState();
}

class _CourseDetailsState extends State<CourseDetails>
    with SingleTickerProviderStateMixin {
  final CourseService _courseService = CourseService();
  final ModuleService _moduleService = ModuleService();
  final LessonService _lessonService = LessonService();

  late TabController _tabController;
  Course? course;
  List<Module> modules = [];
  List<Lesson> lessons = [];
  bool isLoading = true;
  String errorMessage = '';
  int selectedModuleIndex = 0;
  int? selectedLessonIndex;

  // For video player
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool isVideoInitialized = false;
  String? currentVideoUrl;

  void _onLessonTap(int index) {
    final lesson = lessons[index];
    final hasVideo = lesson.content.videoUrl.isNotEmpty;

    if (hasVideo) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LessonViewerPage(
            course: course!,
            modules: modules,
            lessons: lessons,
            initialIndex: index,
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCourseData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _loadCourseData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      // 1. Load course details
      final courseData = await _courseService.getCourseById(widget.courseId);

      // 2. Load all lessons for the course at once
      final lessonsData =
          await _lessonService.getLessonsByCourse(widget.courseId);

      // 3. Load modules
      final modulesData =
          await _moduleService.getModulesByCourse(widget.courseId);
      modulesData.sort((a, b) => a['order'].compareTo(b['order']));

      setState(() {
        course = courseData;
        modules = modulesData.map((m) => Module.fromJson(m)).toList();
        lessons = lessonsData.map((l) => Lesson.fromJson(l)).toList();
        isLoading = false;
      });

      // If there are modules, show lessons for the first module
      if (modules.isNotEmpty) {
        _filterLessonsForModule(modules[0].id);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading course: $e';
      });
    }
  }

  void _filterLessonsForModule(String moduleId) {
    setState(() {
      selectedLessonIndex = null;
    });
    // Lessons are already loaded, we just filter them
    final filteredLessons =
        lessons.where((l) => l.moduleId == moduleId).toList();
    filteredLessons.sort((a, b) => a.order.compareTo(b.order));

    setState(() {
      lessons = filteredLessons;
    });
  }

  void _initializeVideo(String videoUrl) {
    if (currentVideoUrl == videoUrl && isVideoInitialized) return;

    // Dispose previous controllers
    _videoPlayerController?.dispose();
    _chewieController?.dispose();

    setState(() {
      isVideoInitialized = false;
      currentVideoUrl = videoUrl;
    });

    _videoPlayerController = VideoPlayerController.network(videoUrl);

    _videoPlayerController!.initialize().then((_) {
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: 16 / 9,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              'Error loading video: $errorMessage',
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );

      setState(() {
        isVideoInitialized = true;
      });
    }).catchError((error) {
      print('Error initializing video: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final locale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor:
          isDark ? Colors.grey[900] : Theme.of(context).scaffoldBackgroundColor,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : course == null
                  ? const Center(child: Text('Course not found'))
                  : CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          pinned: true,
                          expandedHeight: 220,
                          backgroundColor: isDark
                              ? Colors.grey[900]
                              : Theme.of(context).appBarTheme.backgroundColor,
                          flexibleSpace: FlexibleSpaceBar(
                            title: Text(
                              course!.getLocalizedTitle(locale),
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            background:
                                isVideoInitialized && _chewieController != null
                                    ? Chewie(controller: _chewieController!)
                                    : Image.network(
                                        course!.thumbnail,
                                        fit: BoxFit.cover,
                                      ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildCourseMetadata(isDark),
                                const SizedBox(height: 16),
                                TabBar(
                                  controller: _tabController,
                                  labelColor: isDark
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.primary,
                                  unselectedLabelColor: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[700],
                                  indicatorColor:
                                      Theme.of(context).colorScheme.primary,
                                  tabs: const [
                                    Tab(text: 'Content'),
                                    Tab(text: 'About'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverFillRemaining(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildContentTab(locale, isDark),
                              _buildAboutTab(locale, isDark),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildCourseMetadata(bool isDark) {
    return Row(
      children: [
        Icon(Icons.access_time,
            size: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
        const SizedBox(width: 4),
        Text('${course!.duration} hours',
            style:
                TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
        const SizedBox(width: 16),
        Icon(Icons.star, size: 16, color: Colors.amber),
        const SizedBox(width: 4),
        Text(
          '${course!.rating.average.toStringAsFixed(1)} (${course!.rating.count})',
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildContentTab(Locale locale, bool isDark) {
    return ListView.builder(
      itemCount: modules.length,
      itemBuilder: (context, moduleIndex) {
        final module = modules[moduleIndex];
        final moduleLessons = lessons
            .where((l) => l.moduleId == module.id)
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order));

        return Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: ExpansionTile(
            initiallyExpanded: moduleIndex == selectedModuleIndex,
            backgroundColor: isDark ? Colors.grey[850] : Colors.grey[100],
            collapsedBackgroundColor: isDark ? Colors.grey[900] : Colors.white,
            title: Text(
              module.getLocalizedTitle(locale.languageCode),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            onExpansionChanged: (expanded) {
              if (expanded) {
                setState(() {
                  selectedModuleIndex = moduleIndex;
                });
              }
            },
            children: moduleLessons.isEmpty
                ? [
                    ListTile(
                      title: Text(
                        'No lessons available for this module',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                        ),
                      ),
                    )
                  ]
                : moduleLessons.map((lesson) {
                    final hasVideo = lesson.content.videoUrl.isNotEmpty;
                    final lessonGlobalIndex = lessons.indexWhere((l) =>
                        l.id == lesson.id && l.moduleId == lesson.moduleId);

                    return ListTile(
                      leading: Icon(
                        hasVideo ? Icons.play_circle : Icons.article,
                        color: hasVideo
                            ? Theme.of(context).colorScheme.primary
                            : (isDark ? Colors.white : Colors.black54),
                      ),
                      title: Text(
                        lesson.getLocalizedTitle(locale),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      subtitle: Text('${lesson.duration} min'),
                      onTap: () => _onLessonTap(lessonGlobalIndex),
                    );
                  }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildAboutTab(Locale locale, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Description', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(course!.getLocalizedDescription(locale)),
          const SizedBox(height: 16),
          Text('Level: ${course!.getLocalizedLevel(locale)}'),
          const SizedBox(height: 8),
          Text('Language: ${course!.getLocalizedLanguage(locale)}'),
          const SizedBox(height: 24),
          Divider(),
          Text('Instructor', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Column(
            children: [
              CircleAvatar(
                backgroundImage:
                    NetworkImage(course!.instructor.user.profilePicture),
                radius: 30,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // Combine first and last name for full name
                      '${course!.instructor.user.firstNameEn} ${course!.instructor.user.lastNameEn}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      // Show professional title from Instructor model
                      course!.instructor.professionalTitleEn,
                      style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
