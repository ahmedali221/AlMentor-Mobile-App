import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Core/Providers/themeProvider.dart';
import '../../models/course.dart';
import '../../services/course_service.dart';

class CourseDetails extends StatefulWidget {
  final Course? course; // Course object as parameter
  final String? courseId; // Optional course ID if you want to fetch

  const CourseDetails({
    super.key,
    this.course,
    this.courseId,
  }) : assert(course != null || courseId != null,
            'Either course or courseId must be provided');

  @override
  State<CourseDetails> createState() => _CourseDetailsState();
}

class _CourseDetailsState extends State<CourseDetails> {
  Course? course; // Local course state
  bool isLoading = true;
  String errorMessage = '';
  final CourseService _courseService = CourseService();

  @override
  void initState() {
    super.initState();
    // If we received a course object directly, use it
    if (widget.course != null) {
      setState(() {
        course = widget.course;
        isLoading = false;
      });
    } else if (widget.courseId != null) {
      // If we only have the course ID, fetch the course
      _fetchCourse(widget.courseId!);
    }
  }

  Future<void> _fetchCourse(String courseId) async {
    try {
      final fetchedCourse = await _courseService.getCourseById(courseId);
      setState(() {
        course = fetchedCourse;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading course: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final locale = Localizations.localeOf(context);

    return Directionality(
      textDirection:
          locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          title: Text(
            isLoading || course == null
                ? (locale.languageCode == 'ar'
                    ? 'تفاصيل الدورة'
                    : 'Course Details')
                : course!.getLocalizedTitle(locale),
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          actions: [
            IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : course == null
                    ? Center(child: Text('No course data available'))
                    : _buildCourseDetails(context, locale),
      ),
    );
  }

  Widget _buildCourseDetails(BuildContext context, Locale locale) {
    // Ensure course is not null before accessing it
    if (course == null) {
      return Center(child: Text('No course data available'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Thumbnail
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(course!.thumbnail),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  // Handle image loading error
                },
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course Title
                Text(
                  course!.getLocalizedTitle(locale),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 8),

                // Course Level and Language
                Row(
                  children: [
                    _buildInfoChip(
                      context,
                      locale.languageCode == 'ar' ? 'المستوى:' : 'Level:',
                      course!.getLocalizedLevel(locale),
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      context,
                      locale.languageCode == 'ar' ? 'اللغة:' : 'Language:',
                      course!.getLocalizedLanguage(locale),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Course Description
                Text(
                  locale.languageCode == 'ar'
                      ? 'وصف الدورة:'
                      : 'Course Description:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  course!.getLocalizedDescription(locale),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 16),

                // Course Details
                _buildDetailItem(
                  context,
                  Icons.access_time,
                  locale.languageCode == 'ar' ? 'المدة:' : 'Duration:',
                  _formatDuration(course!.duration),
                ),

                _buildDetailItem(
                  context,
                  Icons.update,
                  locale.languageCode == 'ar' ? 'آخر تحديث:' : 'Last Updated:',
                  '${course!.lastUpdated.day}/${course!.lastUpdated.month}/${course!.lastUpdated.year}',
                ),

                _buildDetailItem(
                  context,
                  Icons.people,
                  locale.languageCode == 'ar'
                      ? 'عدد المسجلين:'
                      : 'Enrollment Count:',
                  '${course!.enrollmentCount}',
                ),

                _buildDetailItem(
                  context,
                  Icons.star,
                  locale.languageCode == 'ar' ? 'التقييم:' : 'Rating:',
                  '${course!.rating.average.toStringAsFixed(1)} (${course!.rating.count} ${locale.languageCode == 'ar' ? 'تقييم' : 'reviews'})',
                ),

                const SizedBox(height: 16),

                // Free Lessons Section
                if (course!.freeLessons.isNotEmpty) ...[
                  Text(
                    locale.languageCode == 'ar'
                        ? 'الدروس المجانية:'
                        : 'Free Lessons:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...course!.freeLessons
                      .map((lesson) => _buildLessonItem(context, lesson)),
                ],

                const SizedBox(height: 24),

                // Enroll Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Implement enrollment functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            locale.languageCode == 'ar'
                                ? 'تم التسجيل في الدورة بنجاح!'
                                : 'Successfully enrolled in the course!',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      course!.isFree
                          ? (locale.languageCode == 'ar'
                              ? 'سجل مجاناً'
                              : 'Enroll for Free')
                          : (locale.languageCode == 'ar'
                              ? 'سجل الآن'
                              : 'Enroll Now'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$label $value',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDetailItem(
      BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildLessonItem(BuildContext context, FreeLesson lesson) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.play_circle_outline),
        title: Text(lesson.title),
        subtitle: Text(_formatDuration(lesson.duration)),
        trailing: const Icon(Icons.lock_open),
        onTap: () {
          // Implement lesson playback functionality
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Playing: ${lesson.title}')),
          );
        },
      ),
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours h $minutes min';
    } else {
      return '$minutes min';
    }
  }
}
