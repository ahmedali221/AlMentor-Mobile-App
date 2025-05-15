import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Core/Providers/themeProvider.dart';

class MyCoursesPage extends StatelessWidget {
  const MyCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    // Example data for "Continue where you left off"
    final continueCourses = [
      {
        'image': 'assets/images/co1.png',
        'title': 'الإنجليزية للحصول على الوظيفة',
        'instructor': 'حنان رضوان - وائل عبدالله',
        'progress': 0.02,
      },
      {
        'image': 'assets/images/co2.png',
        'title': '100 مبدأ لإدارة العمل والحياة (دورة مصغرة)',
        'instructor': 'إيهاب فكري',
        'progress': 0.0,
      },
    ];

    // Example data for saved courses
    final savedCourses = [
      {
        'image': 'assets/images/prog1.png',
        'title': 'أساسيات الأمن السيبراني',
        'instructor': 'محمد إبراهيم',
      },
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'تقدمي',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
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
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          // Section: Continue where you left off
          _sectionTitle(context, 'استكمل من حيث غادرت'),
          Row(
            children: continueCourses
                .map((course) => Expanded(
                      child: _CourseCard(
                        image: course['image'] as String,
                        title: course['title'] as String,
                        instructor: course['instructor'] as String,
                        progress: course['progress'] as double,
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: continueCourses
                .map((course) => Expanded(
                      child:
                          _ProgressText(progress: course['progress'] as double),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
          // Section: Downloads
          _sectionTitle(context, 'التنزيلات'),
          _EmptyDownloadsWidget(),
          const SizedBox(height: 40),
          // Section: Saved Courses
          _sectionTitle(context, 'الدورات المحفوظة'),
          ...savedCourses.map((course) => _SavedCourseCard(
                image: course['image']!,
                title: course['title']!,
                instructor: course['instructor']!,
              )),
          const SizedBox(height: 24),
          // Section: Completed Courses
          _sectionTitle(context, 'الدورات المكتملة'),
          _EmptyCompletedWidget(),
          const SizedBox(height: 24),
          // Red Card (subscribe)
          _SubscribeCard(),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

// Course Card Widget
class _CourseCard extends StatelessWidget {
  final String image, title, instructor;
  final double progress;
  const _CourseCard({
    required this.image,
    required this.title,
    required this.instructor,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              image,
              height: 90,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 2),
                Text(
                  instructor,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Progress Text Widget
class _ProgressText extends StatelessWidget {
  final double progress;
  const _ProgressText({required this.progress});
  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).toInt();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        'تم اجتياز $percent% من الدورة',
        style: const TextStyle(color: Colors.white70, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// Empty Downloads Widget
class _EmptyDownloadsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SizedBox(height: 8),
        Icon(Icons.inbox, color: Colors.white38, size: 60),
        SizedBox(height: 8),
        Text(
          'لا توجد تنزيلات',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 4),
        Text(
          'لم تقم بتنزيل أي فيديوهات بعد. ابدأ باستكشاف الدورات وقم بتنزيل دروسك المفضلة للمشاهدة بدون إنترنت.',
          style: TextStyle(color: Colors.white54, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// Saved Course Card Widget
class _SavedCourseCard extends StatelessWidget {
  final String image, title, instructor;
  const _SavedCourseCard({
    required this.image,
    required this.title,
    required this.instructor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF232323), // darker background
        borderRadius: BorderRadius.circular(14),
      ),
      height: 60,
      child: Row(
        children: [
          // Image with only left corners rounded
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(14)),
            child: Image.asset(
              image,
              height: 60,
              width: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          // Texts
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  instructor,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}

// Empty Completed Widget
class _EmptyCompletedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SizedBox(height: 8),
        Icon(Icons.inbox, color: Colors.white38, size: 60),
        SizedBox(height: 8),
        Text(
          'لم تنهِ أي دورة.',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 4),
        Text(
          'قم بإنهاء الدورات، ابدأ رحلة تعلّمك.',
          style: TextStyle(color: Colors.white54, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// Subscribe Card Widget (red card at the bottom)
class _SubscribeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.red[700],
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          // Illustration (replace with your asset if you have one)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.red[400],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.play_arrow, color: Colors.red, size: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Texts and Button
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'احصل على كل الكورسات',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 4),
                const Text(
                  'اشترك للوصول إلى مكتبة الكورسات الكاملة.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('اشترك الآن'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
