import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/course.dart';
import '../../services/course_service.dart';
import '../../services/module_service.dart';
import '../../services/lesson_service.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:provider/provider.dart';
import '../../Core/Providers/themeProvider.dart';
import '../../Core/Custom Widgets/horizontal_animated_courses.dart';

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
  List<dynamic> modules = [];
  List<dynamic> lessons = [];
  bool isLoading = true;
  String errorMessage = '';
  int selectedModuleIndex = 0;
  int? selectedLessonIndex;

  // For video player
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool isVideoInitialized = false;
  String? currentVideoUrl;

  @override
  void initState() {
    print('CourseDetails initialized with courseId: ${widget.courseId}');
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchCourseDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> fetchCourseDetails() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      print('Fetching course details for ID: ${widget.courseId}');
      // Fetch course details

      // Convert response to Course object
      final courseData = await _courseService.getCourseById(widget.courseId);
      print('Raw course data: ${jsonEncode(courseData)}'); // ✅ This now works

      print('Raw course data: ${jsonEncode(courseData)}');

      // Fetch modules for this course
      final moduleData =
          await _moduleService.getModulesByCourse(widget.courseId);
      print('Fetched ${moduleData.length} modules for course');

      // Sort modules by order
      moduleData.sort((a, b) => a['order'].compareTo(b['order']));

      setState(() {
        course = courseData;
        modules = moduleData;
        isLoading = false;
      });

      // If there are modules, fetch lessons for the first module
      if (modules.isNotEmpty) {
        print('Fetching lessons for first module: ${modules[0]['_id']}');
        fetchLessonsForModule(modules[0]['_id'], 0);
      } else {
        print('No modules found for this course');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching course details: $e';
      });
      print('Error in fetchCourseDetails: $e');
    }
  }

  Future<void> fetchLessonsForModule(String moduleId, int moduleIndex) async {
    try {
      setState(() {
        lessons = [];
        selectedModuleIndex = moduleIndex;
        selectedLessonIndex = null;
      });

      print('Fetching lessons for module: $moduleId');
      final lessonData = await _lessonService.getLessonsByModule(moduleId);
      print('Fetched ${lessonData.length} lessons for module');

      // Sort lessons by order
      lessonData.sort((a, b) => a['order'].compareTo(b['order']));

      setState(() {
        lessons = lessonData;
      });
    } catch (e) {
      print('Error fetching lessons: $e');
      setState(() {
        lessons = [];
      });
    }
  }

  void initializeVideo(String videoUrl) {
    if (currentVideoUrl == videoUrl && isVideoInitialized) {
      return; // Video already initialized
    }

    print('Initializing video player with URL: $videoUrl');
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
      print('Video player initialized successfully');
    }).catchError((error) {
      print('Error initializing video player: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final locale = Localizations.localeOf(context);
    final lang = locale.languageCode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                          floating: false,
                          expandedHeight: 220,
                          backgroundColor:
                              Theme.of(context).appBarTheme.backgroundColor,
                          flexibleSpace: FlexibleSpaceBar(
                            title: Text(
                              course!.getLocalizedTitle(locale),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: Theme.of(context)
                                            .appBarTheme
                                            .titleTextStyle
                                            ?.color ??
                                        Theme.of(context).primaryColor,
                                  ),
                            ),
                            background: isVideoInitialized &&
                                    _chewieController != null
                                ? Chewie(controller: _chewieController!)
                                : Image.network(
                                    course!.thumbnail,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Icon(Icons.error),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          actions: [
                            IconButton(
                              icon: Icon(
                                themeProvider.isDarkMode
                                    ? Icons.light_mode
                                    : Icons.dark_mode,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: () {
                                themeProvider.toggleTheme();
                              },
                            ),
                          ],
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.access_time,
                                        size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${(course!.duration / 60).round()} minutes',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(Icons.star,
                                        size: 16, color: Colors.amber),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${course!.rating.average.toStringAsFixed(1)} (${course!.rating.count})',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _SliverTabBarDelegate(
                            TabBar(
                              controller: _tabController,
                              tabs: const [
                                Tab(text: 'Content'),
                                Tab(text: 'About'),
                              ],
                              labelColor: Theme.of(context).primaryColor,
                              unselectedLabelColor:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                              indicatorColor: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        SliverFillRemaining(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildContentTab(locale),
                              _buildAboutTab(locale),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildContentTab(Locale locale) {
    final lang = locale.languageCode;

    if (modules.isEmpty) {
      return Center(child: Text('No modules available for this course'));
    }

    return Row(
      children: [
        // Left side - Module list (30% width)
        Container(
          width: MediaQuery.of(context).size.width * 0.3,
          color: Theme.of(context).colorScheme.surface,
          child: ListView.builder(
            itemCount: modules.length,
            itemBuilder: (context, index) {
              final module = modules[index];
              final isSelected = index == selectedModuleIndex;

              return Container(
                color: isSelected
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : null,
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  title: Text(
                    module['title'][lang] ??
                        module['title']['en'] ??
                        'Module ${index + 1}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Theme.of(context).primaryColor : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    fetchLessonsForModule(module['_id'], index);
                  },
                ),
              );
            },
          ),
        ),

        // Right side - Lesson list (70% width)
        Expanded(
          child: lessons.isEmpty
              ? Center(child: Text('No lessons available for this module'))
              : ListView.builder(
                  itemCount: lessons.length,
                  itemBuilder: (context, index) {
                    final lesson = lessons[index];
                    final bool hasVideo = lesson['content'] != null &&
                        lesson['content']['videoUrl'] != null &&
                        lesson['content']['videoUrl'].toString().isNotEmpty;
                    final bool isSelected = index == selectedLessonIndex;

                    return Card(
                      margin:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      elevation: isSelected ? 3 : 1,
                      color: isSelected
                          ? Theme.of(context).primaryColor.withOpacity(0.1)
                          : null,
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            hasVideo
                                ? Icons.play_circle_outline
                                : Icons.article,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        title: Text(
                          lesson['title'][lang] ??
                              lesson['title']['en'] ??
                              'Lesson ${index + 1}',
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          '${lesson['duration'] ?? 0} minutes',
                          style: TextStyle(fontSize: 12),
                        ),
                        onTap: () {
                          setState(() {
                            selectedLessonIndex = index;
                          });
                          if (hasVideo) {
                            initializeVideo(lesson['content']['videoUrl']);
                          }
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAboutTab(Locale locale) {
    final lang = locale.languageCode;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About this course',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            course!.description[lang] ?? course!.description['en'] ?? '',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Level: ${course!.level[lang] ?? course!.level['en'] ?? ''}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Language: ${course!.language[lang] ?? course!.language['en'] ?? ''}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (course!.freeLessons.isNotEmpty) ...[
            Text(
              'Free Lessons',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...course!.freeLessons
                .map((lesson) => Card(
                      margin: EdgeInsets.only(bottom: 8.0),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.play_circle_outline,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        title: Text(
                            lesson.title[lang] ?? lesson.title['en'] ?? ''),
                        subtitle: Text('${lesson.duration} minutes'),
                        onTap: () {
                          // Handle free lesson tap
                          print('Free lesson tapped');
                        },
                      ),
                    ))
                .toList(),
          ]
        ],
      ),
    );
  }
}

// Helper for sticky tab bar in slivers
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
