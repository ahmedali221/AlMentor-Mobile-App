import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CourseItem {
  final String title;
  final String? instructor;
  final String imageUrl;
  final bool isNew;
  final List<String>? tags;
  final VoidCallback onTap;

  CourseItem({
    required this.title,
    this.instructor,
    required this.imageUrl,
    this.isNew = false,
    this.tags,
    required this.onTap,
  });
}

class TrainingCoursesSection extends StatelessWidget {
  final String sectionTitle;
  final List<CourseItem> courses;
  final Function()? onViewAll;
  final double itemHeight;
  final double itemWidth;
  final double spacing;
  final TextStyle? sectionTitleStyle;
  final TextStyle? courseTitleStyle;
  final TextStyle? instructorStyle;
  final Color backgroundColor;
  final Color textColor;

  const TrainingCoursesSection({
    super.key,
    required this.sectionTitle,
    required this.courses,
    this.onViewAll,
    this.itemHeight = 170,
    this.itemWidth = 160,
    this.spacing = 8,
    this.sectionTitleStyle,
    this.courseTitleStyle,
    this.instructorStyle,
    this.backgroundColor = Colors.transparent,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final courseItems = courses
        .map((course) => CourseCard(
              course: course,
              width: itemWidth,
              height: itemHeight,
              courseTitleStyle: courseTitleStyle,
              instructorStyle: instructorStyle,
              textColor: textColor,
            ))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // View All Button (RTL layout, so this appears on the left)
              InkWell(
                onTap: onViewAll,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: textColor.withValues(alpha:0.2)),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: textColor,
                    size: 16,
                  ),
                ),
              ),

              // Section Title (RTL layout, so this appears on the right)
              Text(
                sectionTitle,
                style: sectionTitleStyle ??
                    TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),

        // CarouselSlider instead of ListView for smoother scrolling
        SizedBox(
          height: itemHeight,
          child: CarouselSlider(
            options: CarouselOptions(
              height: itemHeight,
              enableInfiniteScroll: false,
              viewportFraction: 0.45,
              enlargeCenterPage: false,
              padEnds: false,
              scrollPhysics: const BouncingScrollPhysics(),
            ),
            items: courseItems,
          ),
        ),
      ],
    );
  }
}

class CourseCard extends StatelessWidget {
  final CourseItem course;
  final double width;
  final double height;
  final TextStyle? courseTitleStyle;
  final TextStyle? instructorStyle;
  final Color textColor;

  const CourseCard({
    super.key,
    required this.course,
    required this.width,
    required this.height,
    this.courseTitleStyle,
    this.instructorStyle,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: course.onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    course.imageUrl,
                    width: width,
                    height: height - 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: width,
                        height: height - 60,
                        color: Colors.grey[800],
                        child: Center(
                          child: Icon(Icons.image_not_supported,
                              color: Colors.grey[600]),
                        ),
                      );
                    },
                  ),
                ),
                if (course.isNew)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.lightBlueAccent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'جديد',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              course.title,
              style: courseTitleStyle ??
                  TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
            if (course.instructor != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  course.instructor!,
                  style: instructorStyle ??
                      TextStyle(
                        color: textColor.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Example usage
class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample courses data
    final courses = [
      CourseItem(
        title: 'أساسيات التشفير',
        instructor: 'أحمد البنهاوي',
        imageUrl: 'assets/images/teacher1.png',
        isNew: true,
        onTap: () {
          log('Cryptography course tapped');
        },
      ),
      CourseItem(
        title: 'عزز صمودك النفسي في عالم دائم التغير',
        instructor: 'أحمد الأعور - نهى زهرة',
        imageUrl: 'assets/images/teacher2.png',
        isNew: true,
        onTap: () {
          log('Resilience course tapped');
        },
      ),
      CourseItem(
        title: 'تطوير تطبيقات الموبايل',
        instructor: 'محمد السيد',
        imageUrl: 'assets/images/teacher3.png',
        isNew: true,
        onTap: () {
          log('Mobile development course tapped');
        },
      ),
      CourseItem(
        title: 'تطوير تطبيقات الموبايل',
        instructor: 'محمد السيد',
        imageUrl: 'assets/images/teacher4.png',
        isNew: true,
        onTap: () {
          log('Mobile development course tapped');
        },
      ),
      CourseItem(
        title: 'تطوير تطبيقات الموبايل',
        instructor: 'محمد السيد',
        imageUrl: 'assets/images/teacher5.png',
        isNew: true,
        onTap: () {
          log('Mobile development course tapped');
        },
      ),
    ];

    courses
        .map((course) => CourseCard(
              course: course,
              width: 160,
              height: 170,
              courseTitleStyle: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              instructorStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
              textColor: Colors.white,
            ))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('الدورات التدريبية'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 16),
          TrainingCoursesSection(
            sectionTitle: 'أحدث الدورات التدريبية',
            courses: courses,
            onViewAll: () {
              log('View all courses');
            },
          ),
        ],
      ),
    );
  }
}
