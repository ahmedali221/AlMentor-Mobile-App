import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'course_card.dart';

class HorizontalCourseList extends StatelessWidget {
  final List<Map<String, dynamic>> courses;

  const HorizontalCourseList({
    super.key,
    required this.courses,
  });

  @override
  Widget build(BuildContext context) {
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
          scrollPhysics: const BouncingScrollPhysics(), // smoother natural scroll
          pageSnapping: true,
          scrollDirection: Axis.horizontal,
          autoPlay: false, // you can set this to true if needed
        ),
        items: courses.map((course) {
          return Builder(
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                child: CourseCard(
                  title: course['title'] as String,
                  instructor: course['instructor'] as String,
                  tags: (course['tags'] as List<dynamic>).cast<String>(),
                  imageUrl: course['image'] as String,
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}