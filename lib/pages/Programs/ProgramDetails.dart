import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Core/Providers/themeProvider.dart';
import '../../models/program.dart';
import '../../models/instructor.dart';
import '../../services/program_service.dart';
import '../../services/instructor_service.dart';
import '../courses/coursesDetails.dart';

class ProgramDetails extends StatefulWidget {
  final String programId;

  const ProgramDetails({Key? key, required this.programId}) : super(key: key);

  @override
  State<ProgramDetails> createState() => _ProgramDetailsState();
}

class _ProgramDetailsState extends State<ProgramDetails> {
  Program? program;
  List<Instructor> instructors = [];
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    _loadProgramData();
  }

  Future<void> _loadProgramData() async {
    setState(() {
      isLoading = true;
      error = '';
    });
    try {
      final programService = ProgramService();
      final instructorService = InstructorService();
      final programData = await programService.getProgramById(widget.programId);

      for (var course in programData.courseDetails) {
        if (course['instructor'] != null) {
          print('Course Instructor ID: ${course['instructor']}');
        }
      }
      // print('Program Data: ${programData.courseDetails.instructor}');
      // Collect unique instructor IDs from all courses
      final instructorIds = programData.courseDetails
          .map((c) => c['instructor']?.toString())
          .where((id) => id != null && id.isNotEmpty)
          .toSet()
          .toList();

      // Fetch instructor data
      List<Instructor> fetchedInstructors = [];
      for (final id in instructorIds) {
        if (id != null) {
          try {
            print('Fetching instructor with ID: $id');
            final instructor = await instructorService.getInstructorById(id);
            if (instructor != null) {
              print('Fetched instructor: ${instructor.user.firstNameEn}');
              fetchedInstructors.add(instructor);
            } else {
              print('Instructor not found for ID: $id');
            }
          } catch (e) {
            print('Error fetching instructor with ID $id: $e');
          }
        }
      }

      setState(() {
        program = programData;
        instructors = fetchedInstructors;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error loading program data';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey[300] : Colors.grey[700];
    final cardColor = isDark ? Colors.grey[850] : Colors.white;

    return Scaffold(
      backgroundColor:
          isDark ? Colors.grey[900] : Theme.of(context).scaffoldBackgroundColor,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )
              : program == null
                  ? const Center(child: Text('Program not found'))
                  : CustomScrollView(
                      slivers: [
                        // App Bar
                        SliverAppBar(
                          expandedHeight: 200,
                          pinned: true,
                          backgroundColor: isDark
                              ? Colors.grey[900]
                              : Theme.of(context).appBarTheme.backgroundColor,
                          flexibleSpace: FlexibleSpaceBar(
                            title: Text(
                              program!.title['en'] ?? '',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 20,
                              ),
                            ),
                            background: Image.network(
                              program!.thumbnail,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.error),
                              ),
                            ),
                          ),
                        ),

                        // Content
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Description
                                Text(
                                  program!.description['en'] ?? '',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: subTextColor,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Program Stats
                                Row(
                                  children: [
                                    _buildStat(
                                      Icons.play_lesson,
                                      '${program!.courseDetails.length} Courses',
                                      color: Theme.of(context).primaryColor,
                                      textColor: textColor,
                                    ),
                                    const SizedBox(width: 16),
                                    _buildStat(
                                      Icons.access_time,
                                      '${program!.totalDuration} minutes',
                                      color: Theme.of(context).primaryColor,
                                      textColor: textColor,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Learning Outcomes
                                Text(
                                  'Learning Outcomes',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...program!.learningOutcomes
                                    .map((outcome) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 8),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('• ',
                                                  style: TextStyle(
                                                      color: textColor,
                                                      fontSize: 18)),
                                              Expanded(
                                                child: Text(
                                                  outcome.en,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: textColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                const SizedBox(height: 24),

                                // Instructors Section
                                if (instructors.isNotEmpty) ...[
                                  Text(
                                    'Program Instructors',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 200,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: instructors.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(width: 16),
                                      itemBuilder: (context, index) {
                                        final instructor = instructors[index];
                                        return Column(
                                          children: [
                                            CircleAvatar(
                                              radius: 30,
                                              backgroundImage: NetworkImage(
                                                  instructor
                                                      .user.profilePicture),
                                              backgroundColor: Colors.grey[400],
                                              child: instructor.user
                                                      .profilePicture.isEmpty
                                                  ? const Icon(Icons.person,
                                                      color: Colors.white,
                                                      size: 30)
                                                  : null,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '${instructor.user.firstNameEn} ${instructor.user.lastNameEn}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: textColor,
                                              ),
                                            ),
                                            Text(
                                              instructor.professionalTitleEn,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: subTextColor,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],

                                // Courses Section
                                Text(
                                  'Program Courses',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ...program!.courseDetails.map(
                                  (course) => Card(
                                    color: cardColor,
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(16),
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          course['thumbnail'] ?? '',
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            width: 80,
                                            height: 80,
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        course['title']?['en'] ?? '',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 8),
                                          Text(
                                            course['description']?['en'] ?? '',
                                            style:
                                                TextStyle(color: subTextColor),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(Icons.access_time,
                                                  size: 16,
                                                  color: subTextColor),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${course['duration']} minutes',
                                                style: TextStyle(
                                                    color: subTextColor),
                                              ),
                                              const SizedBox(width: 16),
                                              Icon(Icons.bar_chart,
                                                  size: 16,
                                                  color: subTextColor),
                                              const SizedBox(width: 4),
                                              Text(
                                                course['level']?['en'] ?? '',
                                                style: TextStyle(
                                                    color: subTextColor),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      trailing: Icon(Icons.arrow_forward_ios,
                                          size: 16, color: textColor),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => CourseDetails(
                                                courseId: course['_id']),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildStat(IconData icon, String text,
      {Color? color, Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? Theme.of(context).primaryColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color ?? Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: textColor ?? color ?? Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
