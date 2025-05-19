import 'package:almentor_clone/pages/courses/coursesDetails.dart';
import 'package:almentor_clone/pages/instructors/instructor_details.dart';
import 'package:almentor_clone/pages/Programs/ProgramDetails.dart';
import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  final bool isDark;
  const SectionTitle({
    super.key,
    required this.title,
    this.onSeeAll,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: Text(
                "See All",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class HorizontalList extends StatelessWidget {
  final List<Widget> children;
  final double height;
  const HorizontalList({
    super.key,
    required this.children,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: children.length,
        itemBuilder: (context, index) {
          return children[index];
        },
      ),
    );
  }
}

class PopularCoursesSection extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> future;
  final bool isDark;
  final String locale;
  const PopularCoursesSection(
      {super.key,
      required this.future,
      required this.isDark,
      required this.locale});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: "Popular Courses", isDark: isDark),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                  height: 320,
                  child: Center(child: CircularProgressIndicator()));
            } else if (snapshot.hasError) {
              return SizedBox(
                height: 320,
                child: Center(
                  child: Text(
                    'Error loading courses: ${snapshot.error}',
                    style:
                        TextStyle(color: isDark ? Colors.white : Colors.black),
                  ),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return SizedBox(
                height: 320,
                child: Center(
                  child: Text(
                    'No courses available.',
                    style:
                        TextStyle(color: isDark ? Colors.white : Colors.black),
                  ),
                ),
              );
            }
            final courses = snapshot.data!;
            return HorizontalList(
              height: 320,
              children: courses.map((course) {
                final instructor = course['instructorDetails'] ?? {};
                final profile = instructor['profile'] ?? {};
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CourseDetails(courseId: course['id']),
                      ),
                    );
                  },
                  child: Container(
                    width: 240,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 18),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[850] : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.10),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(22)),
                          child: Image.network(
                            course['thumbnail'] ?? '',
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              height: 180,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, size: 40),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course['title']?[locale] ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 19,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                profile['firstName']?[locale] ?? '',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[700],
                                  fontSize: 15,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class LearningProgramsSection extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> future;
  final bool isDark;
  final String locale;
  const LearningProgramsSection(
      {super.key,
      required this.future,
      required this.isDark,
      required this.locale});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: "Learning Programs", isDark: isDark),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                  height: 420,
                  child: Center(child: CircularProgressIndicator()));
            } else if (snapshot.hasError) {
              return SizedBox(
                height: 420,
                child: Center(
                  child: Text(
                    'Error loading programs: ${snapshot.error}',
                    style:
                        TextStyle(color: isDark ? Colors.white : Colors.black),
                  ),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return SizedBox(
                height: 420,
                child: Center(
                  child: Text(
                    'No programs available.',
                    style:
                        TextStyle(color: isDark ? Colors.white : Colors.black),
                  ),
                ),
              );
            }
            final programs = snapshot.data!;
            return HorizontalList(
              height: 420,
              children: programs.map((program) {
                return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProgramDetails(programId: program['_id']),
                        ),
                      );
                    },
                    child: Container(
                      width: 340,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 18),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[850] : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          if (!isDark)
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.10),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(22)),
                            child: Image.network(
                              program['thumbnail'] ?? '',
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                height: 220,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image, size: 40),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  program['title']?[locale] ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 19,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  program['description']?[locale] ?? '',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[700],
                                    fontSize: 15,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "${program['courses'] != null ? (program['courses'] as List).length : 0} Courses",
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ));
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class TopInstructorsSection extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> future;
  final bool isDark;
  final String locale;
  const TopInstructorsSection(
      {super.key,
      required this.future,
      required this.isDark,
      required this.locale});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: "Top Instructors", isDark: isDark),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                  height: 260,
                  child: Center(child: CircularProgressIndicator()));
            } else if (snapshot.hasError) {
              return SizedBox(
                height: 260,
                child: Center(
                  child: Text(
                    'Error loading instructors: ${snapshot.error}',
                    style:
                        TextStyle(color: isDark ? Colors.white : Colors.black),
                  ),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return SizedBox(
                height: 260,
                child: Center(
                  child: Text(
                    'No instructors available.',
                    style:
                        TextStyle(color: isDark ? Colors.white : Colors.black),
                  ),
                ),
              );
            }
            final instructors = snapshot.data!;
            return SizedBox(
              height: 260,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: instructors.take(8).length,
                itemBuilder: (context, index) {
                  final instructor = instructors[index];
                  final profile = instructor['profile'] ?? {};
                  return GestureDetector(
                    // onTap: () => Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) => InstructorDetailsPage(
                    //       instructorId: instructor['id'],
                    //     ),
                    //   ),
                    // ),
                    child: Container(
                      width: 200,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 18),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[850] : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          if (!isDark)
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.10),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 18),
                          CircleAvatar(
                            backgroundImage:
                                NetworkImage(profile['profilePicture'] ?? ''),
                            radius: 50,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            profile['firstName']?[locale] ?? '',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            instructor['professionalTitle']?[locale] ?? '',
                            style: TextStyle(
                              color:
                                  isDark ? Colors.grey[300] : Colors.grey[700],
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
