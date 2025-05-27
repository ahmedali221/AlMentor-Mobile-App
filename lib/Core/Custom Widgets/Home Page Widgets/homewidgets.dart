import 'package:almentor_clone/pages/courses/coursesDetails.dart';
import 'package:almentor_clone/pages/Programs/ProgramDetails.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Localization/app_translations.dart';
import '../../Providers/language_provider.dart';

class SectionTitle extends StatelessWidget {
  final String translationKey;
  final VoidCallback? onSeeAll;
  final bool isDark;

  const SectionTitle({
    super.key,
    required this.translationKey,
    this.onSeeAll,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final locale =
        Provider.of<LanguageProvider>(context).currentLocale.languageCode;
    final isRtl = Provider.of<LanguageProvider>(context).isArabic;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppTranslations.getText(translationKey, locale),
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
                AppTranslations.getText('see_all', locale),
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
  final bool isRtl;

  const PopularCoursesSection({
    super.key,
    required this.future,
    required this.isDark,
    required this.locale,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          translationKey: 'popular_courses',
          isDark: isDark,
          onSeeAll: () => Navigator.pushNamed(context, '/courses'),
        ),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            } else if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            }
            return _buildCoursesList(snapshot.data!);
          },
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const SizedBox(
      height: 320,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState(String error) {
    return SizedBox(
      height: 320,
      child: Center(
        child: Text(
          AppTranslations.getText('error_loading_courses', locale) + error,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 320,
      child: Center(
        child: Text(
          AppTranslations.getText('no_courses_available', locale),
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  Widget _buildCoursesList(List<Map<String, dynamic>> courses) {
    return HorizontalList(
      height: 320,
      children: courses
          .map((course) => _CourseCard(
                course: course,
                isDark: isDark,
                locale: locale,
                isRtl: isRtl,
              ))
          .toList(),
    );
  }
}

class LearningProgramsSection extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> future;
  final bool isDark;
  final String locale;
  final bool isRtl; // Add isRtl parameter

  const LearningProgramsSection(
      {super.key,
      required this.future,
      required this.isDark,
      required this.locale,
      required this.isRtl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          translationKey: 'learning_programs',
          isDark: isDark,
          onSeeAll: () {},
        ),
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
      required this.locale,
      required bool isRtl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          translationKey: 'top_instructors',
          isDark: isDark,
          onSeeAll: () => Navigator.pushNamed(context, '/instructors'),
        ),
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

class _CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final bool isDark;
  final String locale;
  final bool isRtl;

  const _CourseCard({
    required this.course,
    required this.isDark,
    required this.locale,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final instructor = course['instructorDetails'] ?? {};
    final profile = instructor['profile'] ?? {};

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CourseDetails(courseId: course['id']),
        ),
      ),
      child: Container(
        width: 240,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
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
          crossAxisAlignment:
              isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
              child: _buildThumbnail(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment:
                    isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
                    textAlign: isRtl ? TextAlign.right : TextAlign.left,
                  ),
                  Text(
                    profile['firstName']?[locale] ?? '',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: isRtl ? TextAlign.right : TextAlign.left,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Image.network(
      course['thumbnail'] ?? '',
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: 180,
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image, size: 40),
      ),
    );
  }
}
