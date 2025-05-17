import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../models/course.dart';
import 'animated_course_card.dart';

class HorizontalAnimatedCourses extends StatefulWidget {
  final List<Course> courses;
  final String? title;
  final String? description;
  final Function(Course)? onCourseTap;

  const HorizontalAnimatedCourses({
    super.key,
    required this.courses,
    this.title,
    this.description,
    this.onCourseTap,
  });

  @override
  State<HorizontalAnimatedCourses> createState() =>
      _HorizontalAnimatedCoursesState();
}

class _HorizontalAnimatedCoursesState extends State<HorizontalAnimatedCourses>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    // Start the animation when the widget is first built
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null || widget.description != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.title != null)
                    Text(
                      widget.title!,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  if (widget.description != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        widget.description!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ),
                ],
              ),
            ),
          SizedBox(
            height: 300,
            child: CarouselSlider(
              options: CarouselOptions(
                height: 300,
                enableInfiniteScroll: false,
                viewportFraction: 0.45,
                enlargeCenterPage: true,
                enlargeStrategy: CenterPageEnlargeStrategy.height,
                enlargeFactor: 0.15,
                scrollPhysics: const BouncingScrollPhysics(),
                pageSnapping: true,
                scrollDirection: Axis.horizontal,
                autoPlay: false,
              ),
              items: widget.courses.map((course) {
                return Builder(
                  builder: (context) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 4),
                      child: AnimatedCourseCard(
                        course: course,
                        onTap: () {
                          if (widget.onCourseTap != null) {
                            widget.onCourseTap!(course);
                          }
                        },
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
