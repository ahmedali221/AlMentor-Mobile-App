import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../widgets/course_card.dart';
import '../widgets/featured_courses_slider.dart';
import '../widgets/programme_card.dart';
import '../widgets/most_viewed_card.dart';
import '../widgets/popular_courses.dart' as popular;
import '../widgets/featured_course_card.dart';
import '../widgets/tabs_widget.dart';
import '../widgets/join_card.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class MainHomeContent extends StatelessWidget {
  const MainHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Example static data
    final featuredCourses = [
      {
        'title': 'عزز صمودك النفسي في عالم دائم التغير',
        'subtitle': 'علم النفس والسلامة الذهنية',
        'image': 'assets/images/num1.png',
      },
      {
        'title': 'التسويق باستخدام الذكاء الاصطناعي',
        'subtitle': 'التسويق',
        'image': 'assets/images/num2.png',
      },
      {
        'title': 'القيادة من القلب والإدارة بالابتكار',
        'subtitle': 'الإدارة',
        'image': 'assets/images/num3.png',
      },
      {
        'title': 'صناعة البودكاست',
        'subtitle': 'الإعلام الرقمي',
        'image': 'assets/images/num4.png',
      },
      {
        'title': 'برنامج التعلم الذاتي',
        'subtitle': 'تطوير الذات',
        'image': 'assets/images/num5.png',
      },
      {
        'title': 'الإنجليزية للوظيفة',
        'subtitle': 'اللغة الإنجليزية',
        'image': 'assets/images/num6.png',
      },
      {
        'title': 'البرمجة للجميع',
        'subtitle': 'تكنولوجيا',
        'image': 'assets/images/num7.png',
      },
    ];
    final courses = [
      {
        'title': '100 مبدأ لإدارة العمل والحياة (دورة مصغرة)',
        'instructor': 'إيهاب فكري',
        'tags': ['مجاني', 'جديد'],
        'image': 'assets/images/teacher1.png',
      },
      {
        'title': 'القيادة من القلب والإدارة بالابتكار',
        'instructor': 'عبد الله سلام',
        'tags': ['جديد'],
        'image': 'assets/images/teacher2.png',
      },
      {
        'title': 'تعلم الإنجليزية للوظيفة',
        'instructor': 'نور محمد',
        'tags': ['مجاني'],
        'image': 'assets/images/teacher3.png',
      },
      {
        'title': 'صناعة البودكاست',
        'instructor': 'ديانا رياض',
        'tags': ['جديد'],
        'image': 'assets/images/teacher4.png',
      },
      {
        'title': 'تحول الأعمال التجارية للقادة',
        'instructor': 'مدحت ياسين',
        'tags': ['جديد'],
        'image': 'assets/images/teacher5.png',
      },
    ];
    final learningPrograms = [
      {
        'imageUrl': 'assets/images/num1.png',
        'title': 'برنامج التعلم الذاتي',
        'description': 'اكتشف مهارات جديدة وطور نفسك مع أفضل الدورات.',
        'buttonText': 'عرض البرنامج',
      },
      {
        'imageUrl': 'assets/images/num2.png',
        'title': 'برنامج تطوير الذات',
        'description': 'دورات متخصصة في تطوير الذات والقيادة.',
        'buttonText': 'عرض البرنامج',
      },
      {
        'imageUrl': 'assets/images/num3.png',
        'title': 'برنامج القيادة',
        'description': 'تعلم مهارات القيادة الحديثة من خبراء المجال.',
        'buttonText': 'عرض البرنامج',
      },
      {
        'imageUrl': 'assets/images/num4.png',
        'title': 'برنامج الإعلام الرقمي',
        'description': 'كل ما تحتاجه لتصبح محترفًا في الإعلام الرقمي.',
        'buttonText': 'عرض البرنامج',
      },
      {
        'imageUrl': 'assets/images/num5.png',
        'title': 'برنامج اللغة الإنجليزية',
        'description': 'طور لغتك الإنجليزية مع أفضل الدورات.',
        'buttonText': 'عرض البرنامج',
      },
    ];
    final mostWatched = [
      {
        'title': 'الإنجليزية للحصول على الوظيفة',
        'instructor': 'حنان رضوان',
        'tags': ['جديد'],
        'image': 'assets/images/prog1.png',
      },
      {
        'title': 'البرمجة للجميع',
        'instructor': 'سامي علي',
        'tags': ['مجاني'],
        'image': 'assets/images/prog2.png',
      },
      {
        'title': 'إدارة الوقت بفعالية',
        'instructor': 'منى أحمد',
        'tags': ['جديد'],
        'image': 'assets/images/prog3.png',
      },
      {
        'title': 'أساسيات التسويق الرقمي',
        'instructor': 'خالد يوسف',
        'tags': ['مجاني'],
        'image': 'assets/images/co1.png',
      },
      {
        'title': 'القيادة الحديثة',
        'instructor': 'سارة محمد',
        'tags': ['جديد'],
        'image': 'assets/images/co2.png',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Carousel Slider
              FeaturedCoursesSlider(courses: featuredCourses),
              const SizedBox(height: 16),
              // Selected Courses
              sectionTitle('الدورات المختارة', onSeeAllPressed: () {
                // Navigate to selected courses page
              }),
              const SizedBox(height: 16),
              horizontalCourseList(courses),
              // Learning Programs
              sectionTitle('برامج التعلم', onSeeAllPressed: () {
                // Navigate to learning programs page
              }),
              sectionDiscription(
                  'اكتشف دورات مجمعة مصممه لبناء المهارات الاساسية'),
              horizontalLearningPrograms(learningPrograms),
              // Featured course section
              sectionTitle('الأعلى مشاهدة', onSeeAllPressed: () {
                // Navigate to most viewed page
              }),
              const SizedBox(height: 16),
              horizontalMostViewed(mostWatched),
              // Popular Courses section
              sectionTitle('أجدد الدورات التدريبية', onSeeAllPressed: () {
                // Navigate to popular courses page
              }),
              horizontalPopularCourses(courses),
              const SizedBox(height: 24),
              sectionTitle('أجدد الدورات التدريبية', onSeeAllPressed: () {
                // Navigate to popular courses page
              }),
              horizontalCourseList(courses),
              const SizedBox(height: 24),
              // Add Categories section
              sectionTitle('الفئات', onSeeAllPressed: () {
                // Navigate to popular courses page
              }),
              const CategoryButtonWidget(),
              const SizedBox(height: 24),
              sectionTitle('أطفالنا و خطر التحرش الجنسي', onSeeAllPressed: () {
                // Navigate to popular courses page
              }),
              horizontalCourseList(courses),
              const SizedBox(height: 24),
              sectionTitle('طور علامتك و تميز في السوق', onSeeAllPressed: () {
                // Navigate to popular courses page
              }),
              horizontalCourseList(courses),
              const SizedBox(height: 24),
              sectionTitle('تعلم واتقن اللغة الانجليزية', onSeeAllPressed: () {
                // Navigate to popular courses page
              }),
              horizontalCourseList(courses),
              const SizedBox(height: 24),
              sectionTitle('فكر كـقائد و ابدأ التأثير الحقيقي',
                  onSeeAllPressed: () {
                // Navigate to popular courses page
              }),
              horizontalCourseList(courses),
              const SizedBox(height: 24),
              sectionTitle('الدورات المفضلة في السعودية', onSeeAllPressed: () {
                // Navigate to popular courses page
              }),
              horizontalCourseList(courses),
              const SizedBox(height: 24),
              sectionTitle('احترف صناعة المحتوي', onSeeAllPressed: () {
                // Navigate to popular courses page
              }),
              horizontalCourseList(courses),
              const SizedBox(height: 24),
              sectionTitle('تعلم أساسيات الإدارة والأعمال',
                  onSeeAllPressed: () {
                // Navigate to popular courses page
              }),
              horizontalCourseList(courses),
              const SizedBox(height: 24),
              sectionTitle('افهم المال و قد أعمالك بذكاء', onSeeAllPressed: () {
                // Navigate to popular courses page
              }),
              horizontalCourseList(courses),
              const SizedBox(height: 24),
              sectionTitle('ابدأ طريقك لريادة الأعمال', onSeeAllPressed: () {
                // Navigate to popular courses page
              }),
              horizontalCourseList(courses),
              const SizedBox(height: 24),
              sectionTitle('الدورات الأكثر شيوعا', onSeeAllPressed: () {
                // Navigate to popular courses page
              }),
              horizontalCourseList(courses),
              const SizedBox(height: 24),
              sectionTitle('الدورات التدريبية المجانية', onSeeAllPressed: () {
                // Navigate to popular courses page
              }),
              horizontalCourseList(courses),
              const PromoCardWidget(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 4,
        onTap: (index) {},
      ),
    );
  }

  Widget sectionTitle(String title, {VoidCallback? onSeeAllPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Arrow button
          InkWell(
            onTap: onSeeAllPressed,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(0, 0, 0, 0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),

          // Title
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget sectionDiscription(String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget horizontalCourseList(List<Map<String, dynamic>> courses) {
    return SizedBox(
      height: 240,
      child: CarouselSlider(
        options: CarouselOptions(
          height: 230,
          enableInfiniteScroll: false,
          viewportFraction: 0.42, // slightly larger to make cards closer
          enlargeCenterPage: true,
          enlargeStrategy: CenterPageEnlargeStrategy.height,
          enlargeFactor: 0.12, // less exaggeration
          scrollPhysics: BouncingScrollPhysics(), // smoother natural scroll
          pageSnapping: true,
          scrollDirection: Axis.horizontal,
          autoPlay: false, // you can set this to true if needed
        ),
        items: courses.map((course) {
          return Builder(
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 4.0), // tighter spacing
                child: CourseCard(
                  title: course['title'] ?? '',
                  instructor: course['instructor'] ?? '',
                  tags: List<String>.from(course['tags'] ?? []),
                  imageUrl: course['image'] ?? '',
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget horizontalLearningPrograms(List<Map<String, dynamic>> programs) {
    return SizedBox(
      height: 320,
      child: CarouselSlider(
        options: CarouselOptions(
          height: 310,
          enableInfiniteScroll: false,
          viewportFraction: 0.62,
          enlargeCenterPage: true,
          enlargeStrategy: CenterPageEnlargeStrategy.height,
          enlargeFactor: 0.12,
          scrollPhysics: BouncingScrollPhysics(),
          pageSnapping: true,
          scrollDirection: Axis.horizontal,
          autoPlay: false,
        ),
        items: programs.map((program) {
          return Builder(
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ProgrammeCard(
                  imageUrl: program['imageUrl'] ?? '',
                  title: program['title'] ?? '',
                  description: program['description'] ?? '',
                  buttonText: program['buttonText'] ?? '',
                  coursesCount: program['coursesCount'] ?? 0,
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget horizontalMostViewed(List<Map<String, dynamic>> courses) {
    return SizedBox(
      height: 190,
      child: CarouselSlider(
        options: CarouselOptions(
          height: 190,
          enableInfiniteScroll: false,
          viewportFraction: 0.65,
          enlargeCenterPage: true,
          enlargeStrategy: CenterPageEnlargeStrategy.height,
          enlargeFactor: 0.4,
          scrollPhysics: BouncingScrollPhysics(),
          pageSnapping: true,
          scrollDirection: Axis.horizontal,
          autoPlay: false,
        ),
        items: courses.map((course) {
          return Builder(
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: MostViewedCard(
                    imageUrl: course['image'] as String,
                    title: course['title'] as String,
                    subtitle: 'دورة تدريبية',
                    instructorName: course['instructor'] as String,
                    onTap: () {},
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget horizontalLatestCourses(List<Map<String, dynamic>> courses) {
    return SizedBox(
      height: 350,
      child: CarouselSlider(
        options: CarouselOptions(
          height: 350,
          enableInfiniteScroll: true,
          viewportFraction: 0.8,
          enlargeCenterPage: true,
          padEnds: false,
        ),
        items: courses.map((course) {
          return Builder(
            builder: (context) {
              return FeaturedCourseCard(
                imageUrl: course['image'] as String,
                title: course['title'] as String,
                instructorName: course['instructor'] as String,
                tags: (course['tags'] as List<dynamic>).cast<String>(),
                onTap: () {},
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget horizontalPopularCourses(List<Map<String, dynamic>> courses) {
    return SizedBox(
      height: 170,
      child: CarouselSlider(
        options: CarouselOptions(
          height: 170,
          enableInfiniteScroll: false,
          viewportFraction: 0.4, // No spacing between cards
          enlargeCenterPage: false, // No scaling effect
          scrollPhysics: BouncingScrollPhysics(),
          pageSnapping: true,
          scrollDirection: Axis.horizontal,
          autoPlay: false,
        ),
        items: courses.map((course) {
          return Builder(
            builder: (context) {
              return popular.CourseCard(
                course: popular.CourseItem(
                  title: course['title'] ?? '',
                  instructor: course['instructor'],
                  imageUrl: course['image'] ?? '',
                  isNew: (course['tags'] ?? []).contains('جديد'),
                  onTap: () {},
                ),
                width: 160,
                height: 170,
              );
            },
          );
        }).toList(),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFFFFFF),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFeb2027),
//         title: const Text(
//           'Home',
//           style: TextStyle(color: Colors.white),
//         ),
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             DrawerHeader(
//               decoration: BoxDecoration(
//                 color: Color(0xFFeb2027),
//               ),
//               child: Text(
//                 'Menu',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                 ),
//               ),
//             ),
//             ListTile(
//               leading: Icon(Icons.home),
//               title: Text('Home'),
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.logout),
//               title: Text('Logout'),
//               onTap: () async {
//                 final prefs = await SharedPreferences.getInstance();
//                 await prefs.remove('jwt_token');
//                 Navigator.pushReplacementNamed(context, '/');
//               },
//             ),
//           ],
//         ),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               'Welcome to Almentor Clone!',
//               style: TextStyle(
//                 fontSize: 26,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF000000),
//               ),
//             ),
//             const SizedBox(height: 32),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFeb2027),
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               onPressed: () async {
//                 // Remove token from SharedPreferences
//                 final prefs = await SharedPreferences.getInstance();
//                 await prefs.remove('jwt_token');
//                 Navigator.pushReplacementNamed(context, '/');
//               },
//               child: const Text(
//                 'Logout',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
