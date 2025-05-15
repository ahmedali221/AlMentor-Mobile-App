import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'programme_card.dart';

class HorizontalLearningPrograms extends StatelessWidget {
  final List<Map<String, dynamic>> programs;

  const HorizontalLearningPrograms({
    super.key,
    required this.programs,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: CarouselSlider(
        options: CarouselOptions(
          height: 350,
          enableInfiniteScroll: false,
          viewportFraction: 0.8,
          enlargeCenterPage: true,
          enlargeStrategy: CenterPageEnlargeStrategy.height,
          enlargeFactor: 0.2,
          scrollPhysics: const BouncingScrollPhysics(),
          pageSnapping: true,
          scrollDirection: Axis.horizontal,
          autoPlay: false,
        ),
        items: programs.map((program) {
          return Builder(
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: ProgrammeCard(
                  imageUrl: program['imageUrl'] as String,
                  title: program['title'] as String,
                  description: program['description'] as String,
                  buttonText: program['buttonText'] as String,
                  coursesCount: program['coursesCount'] ?? 0,
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}