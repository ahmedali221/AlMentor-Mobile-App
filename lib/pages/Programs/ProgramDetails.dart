import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Core/Providers/themeProvider.dart';
import '../../Core/Providers/language_provider.dart';
import '../../Core/Localization/app_translations.dart';
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
    final languageProvider = context.read<LanguageProvider>();
    final isDark = themeProvider.isDarkMode;
    final locale = languageProvider.currentLocale.languageCode;
    final isRtl = languageProvider.isArabic;

    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey[300] : Colors.grey[700];
    final cardColor = isDark ? Colors.grey[850] : Colors.white;

    return Scaffold(
      backgroundColor:
          isDark ? Colors.grey[900] : Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark
            ? Colors.grey[900]
            : Theme.of(context).appBarTheme.backgroundColor,
        leading: IconButton(
          icon: Icon(
            isRtl ? Icons.arrow_forward : Icons.arrow_back,
            color: textColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppTranslations.getText('program_details', locale),
          style: TextStyle(color: textColor),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    AppTranslations.getText('loading_program', locale),
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
            )
          : error.isNotEmpty
              ? Center(
                  child: Text(
                    AppTranslations.getText('error_loading_program', locale),
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : program == null
                  ? Center(
                      child: Text(
                        AppTranslations.getText('program_not_found', locale),
                        style: TextStyle(color: textColor),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: isRtl
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            // Top Card: Program Image + Title/Description
                            Card(
                              color: cardColor,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        program!.thumbnail,
                                        width: 110,
                                        height: 110,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                          width: 110,
                                          height: 110,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: isRtl
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            program!.title[locale] ?? '',
                                            style: TextStyle(
                                              color: textColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22,
                                            ),
                                            textAlign: isRtl
                                                ? TextAlign.right
                                                : TextAlign.left,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            program!.description[locale] ?? '',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: subTextColor,
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: isRtl
                                                ? TextAlign.right
                                                : TextAlign.left,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Program Stats
                            Row(
                              textDirection:
                                  isRtl ? TextDirection.rtl : TextDirection.ltr,
                              children: [
                                _buildStat(
                                  Icons.play_lesson,
                                  AppTranslations.getText(
                                    'courses_count',
                                    locale,
                                    args: [program!.courseDetails.length],
                                  ),
                                  color: Theme.of(context).primaryColor,
                                  textColor: textColor,
                                ),
                                const SizedBox(width: 16),
                                _buildStat(
                                  Icons.access_time,
                                  AppTranslations.getText(
                                    'duration_minutes',
                                    locale,
                                    args: [program!.totalDuration],
                                  ),
                                  color: Theme.of(context).primaryColor,
                                  textColor: textColor,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Learning Outcomes
                            Text(
                              AppTranslations.getText(
                                  'learning_outcomes', locale),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                              textAlign:
                                  isRtl ? TextAlign.right : TextAlign.left,
                            ),
                            const SizedBox(height: 12),
                            ...program!.learningOutcomes.map(
                              (outcome) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  textDirection: isRtl
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                  children: [
                                    Text(
                                      '• ',
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        locale == 'ar'
                                            ? outcome.ar
                                            : outcome.en,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: textColor,
                                        ),
                                        textAlign: isRtl
                                            ? TextAlign.right
                                            : TextAlign.left,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Instructors Section
                            if (instructors.isNotEmpty) ...[
                              Text(
                                AppTranslations.getText(
                                    'program_instructors', locale),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                                textAlign:
                                    isRtl ? TextAlign.right : TextAlign.left,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 200,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  reverse: isRtl,
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
                                            instructor.user.profilePicture,
                                          ),
                                          backgroundColor: Colors.grey[400],
                                          child: instructor
                                                  .user.profilePicture.isEmpty
                                              ? const Icon(Icons.person,
                                                  color: Colors.white, size: 30)
                                              : null,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          locale == 'ar'
                                              ? '${instructor.user.firstNameAr} ${instructor.user.lastNameAr}'
                                              : '${instructor.user.firstNameEn} ${instructor.user.lastNameEn}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: textColor,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          locale == 'ar'
                                              ? instructor.professionalTitleAr
                                              : instructor.professionalTitleEn,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: subTextColor,
                                          ),
                                          textAlign: TextAlign.center,
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
                              AppTranslations.getText(
                                  'program_courses', locale),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                              textAlign:
                                  isRtl ? TextAlign.right : TextAlign.left,
                            ),
                            const SizedBox(height: 16),
                            ...program!.courseDetails.map(
                              (course) => Card(
                                color: cardColor,
                                margin: const EdgeInsets.only(bottom: 16),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: Stack(
                                    children: [
                                      ClipRRect(
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
                                      if (course['isFree'] == true)
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              AppTranslations.getText(
                                                  'free_course', locale),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  title: Text(
                                    course['title']?[locale] ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                    textAlign: isRtl
                                        ? TextAlign.right
                                        : TextAlign.left,
                                  ),
                                  subtitle: Text(
                                    course['description']?[locale] ?? '',
                                    style: TextStyle(
                                      color: subTextColor,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: isRtl
                                        ? TextAlign.right
                                        : TextAlign.left,
                                  ),
                                  trailing: Icon(
                                    isRtl
                                        ? Icons.arrow_back_ios_new
                                        : Icons.arrow_forward_ios,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CourseDetails(
                                          courseId: course['id'],
                                        ),
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
        ));
  }
}
