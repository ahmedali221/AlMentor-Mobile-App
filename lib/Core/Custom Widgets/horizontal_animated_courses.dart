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
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
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
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: widget.courses.length,
              itemBuilder: (context, index) {
                final delay = 100 * index;
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final animationValue = _controller.value;
                    final shouldShow = animationValue > (index * 0.08);
                    return AnimatedOpacity(
                      opacity: shouldShow ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 400),
                      child: Transform.translate(
                        offset: Offset(shouldShow ? 0 : 40, 0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 8),
                          child: AnimatedCourseCard(
                            course: widget.courses[index],
                            onTap: () {
                              if (widget.onCourseTap != null) {
                                widget.onCourseTap!(widget.courses[index]);
                              }
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
