import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Core/Providers/themeProvider.dart';
import '../widgets/section_title.dart';
import '../widgets/section_description.dart';
import '../widgets/horizontal_course_list.dart';
import '../widgets/horizontal_learning_programs.dart';
import '../widgets/horizontal_most_viewed.dart';
import '../widgets/horizontal_popular_courses.dart';
import '../data/home_demo_data.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Directionality(
      textDirection: TextDirection.rtl, // Set RTL direction for Arabic content
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          title: const Text('Almentor'),
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
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align content to the right in RTL
            children: [
              const SizedBox(height: 16),
              
              // Popular Courses Section
              SectionTitle(
                title: 'الدورات الشائعة',
                onSeeAllPressed: () {},
              ),
              SectionDescription(
                description: 'استكشف الدورات الأكثر شعبية على المنصة',
              ),
              HorizontalPopularCourses(
                courses: HomePageDemoData.featuredCourses,
              ),
              
              const SizedBox(height: 24),
              
              // Regular Courses Section
              SectionTitle(
                title: 'دورات مميزة',
                onSeeAllPressed: () {},
              ),
              SectionDescription(
                description: 'دورات تدريبية مختارة خصيصاً لك',
              ),
              HorizontalCourseList(
                courses: HomePageDemoData.courses,
              ),
              
              const SizedBox(height: 24),
              
              // Learning Programs Section
              SectionTitle(
                title: 'برامج تعليمية',
                onSeeAllPressed: () {},
              ),
              SectionDescription(
                description: 'برامج متكاملة لتطوير مهاراتك',
              ),
              HorizontalLearningPrograms(
                programs: HomePageDemoData.learningPrograms,
              ),
              
              const SizedBox(height: 24),
              
              // Most Watched Section
              SectionTitle(
                title: 'الأكثر مشاهدة',
                onSeeAllPressed: () {},
              ),
              SectionDescription(
                description: 'الدورات الأكثر مشاهدة على المنصة',
              ),
              HorizontalMostViewed(
                courses: HomePageDemoData.mostWatched,
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}