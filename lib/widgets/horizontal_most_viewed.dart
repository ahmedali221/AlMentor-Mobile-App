import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'most_viewed_card.dart';

class HorizontalMostViewed extends StatelessWidget {
  final List<Map<String, dynamic>> courses;

  const HorizontalMostViewed({
    super.key,
    required this.courses,
  });

  @override
  Widget build(BuildContext context) {
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
          scrollPhysics: const BouncingScrollPhysics(),
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
}