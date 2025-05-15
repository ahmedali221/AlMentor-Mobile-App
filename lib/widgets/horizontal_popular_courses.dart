import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'popular_courses.dart' as popular;

class HorizontalPopularCourses extends StatelessWidget {
  final List<Map<String, dynamic>> courses;

  const HorizontalPopularCourses({
    super.key,
    required this.courses,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: CarouselSlider(
        options: CarouselOptions(
          height: 170,
          enableInfiniteScroll: false,
          viewportFraction: 0.4, // No spacing between cards
          enlargeCenterPage: false, // No scaling effect
          scrollPhysics: const BouncingScrollPhysics(),
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