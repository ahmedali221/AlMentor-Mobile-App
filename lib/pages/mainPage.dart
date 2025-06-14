import 'package:almentor_clone/Core/Custom%20Widgets/Home%20Page%20Widgets/homewidgets.dart';
import 'package:almentor_clone/Core/Delegates/search_delegate.dart';
import 'package:almentor_clone/Core/Providers/themeProvider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:almentor_clone/Core/Localization/app_translations.dart';
import 'package:almentor_clone/Core/Providers/language_provider.dart';

// ...existing imports...
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Future<List<Map<String, dynamic>>> _coursesFuture;
  late Future<List<Map<String, dynamic>>> _programsFuture;
  late Future<List<Map<String, dynamic>>> _instructorsFuture;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _coursesFuture = fetchCourses();
      _programsFuture = fetchPrograms();
      _instructorsFuture = fetchInstructors();
    });
  }

  Future<List<Map<String, dynamic>>> fetchCourses() async {
    await Future.delayed(
        const Duration(milliseconds: 500)); // Simulate network delay
    final response = await http.get(Uri.parse(
        'https://al-mentor-database-production.up.railway.app/api/courses'));
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      } else if (decoded is Map) {
        return decoded.values
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
    throw Exception('Failed to load courses');
  }

  Future<List<Map<String, dynamic>>> fetchPrograms() async {
    await Future.delayed(
        const Duration(milliseconds: 800)); // Simulate network delay
    final response = await http.get(Uri.parse(
        'https://al-mentor-database-production.up.railway.app/api/programs'));
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      } else if (decoded is Map) {
        return decoded.values
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
    throw Exception('Failed to load programs');
  }

  Future<List<Map<String, dynamic>>> fetchInstructors() async {
    await Future.delayed(
        const Duration(milliseconds: 700)); // Simulate network delay
    final response = await http.get(Uri.parse(
        'https://al-mentor-database-production.up.railway.app/api/instructors'));
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is Map && decoded['data'] is List) {
        return List<Map<String, dynamic>>.from(decoded['data']);
      } else if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      }
    }
    throw Exception('Failed to load instructors');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final locale = languageProvider.currentLocale.languageCode;
    final isRtl = languageProvider.isArabic;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GestureDetector(
                  onTap: () async {
                    // Wait for all data to be loaded
                    final courses = await _coursesFuture;
                    final programs = await _programsFuture;
                    final instructors = await _instructorsFuture;

                    if (!mounted) return;

                    final selectedId = await showSearch(
                      context: context,
                      delegate: AlmentorSearchDelegate(
                        courses: courses,
                        programs: programs,
                        instructors: instructors,
                        isDark: isDark,
                        locale: locale,
                      ),
                    );

                    if (selectedId != null && selectedId.isNotEmpty) {
                      // Handle navigation based on the selected item
                      // You can determine the type by checking the lists
                      // and navigate accordingly
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[850] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      enabled: false,
                      textDirection:
                          isRtl ? TextDirection.rtl : TextDirection.ltr,
                      textAlign: isRtl ? TextAlign.right : TextAlign.left,
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        hintText:
                            AppTranslations.getText('search_hint', locale),
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search,
                            color:
                                isDark ? Colors.grey[400] : Colors.grey[600]),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Banner
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: isRtl ? Alignment.topRight : Alignment.topLeft,
                        end: isRtl
                            ? Alignment.bottomLeft
                            : Alignment.bottomRight,
                        colors: [
                          Theme.of(context).primaryColor.withOpacity(0.8),
                          Theme.of(context).primaryColor,
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: isRtl ? null : 0,
                          left: isRtl ? 0 : null,
                          bottom: 0,
                          child: Opacity(
                            opacity: 0.2,
                            child: Icon(
                              Icons.school,
                              size: 150,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: isRtl
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppTranslations.getText(
                                    'start_learning', locale),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign:
                                    isRtl ? TextAlign.right : TextAlign.left,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppTranslations.getText(
                                    'access_courses', locale),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                ),
                                textAlign:
                                    isRtl ? TextAlign.right : TextAlign.left,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor:
                                      Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                ),
                                onPressed: () {},
                                icon: Icon(
                                  isRtl
                                      ? Icons.arrow_back
                                      : Icons.arrow_forward,
                                  size: 18,
                                ),
                                label: Text(
                                  AppTranslations.getText(
                                      'explore_now', locale),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Popular Courses
            SliverToBoxAdapter(
              child: PopularCoursesSection(
                future: _coursesFuture,
                isDark: isDark,
                locale: locale,
                isRtl: isRtl,
              ),
            ),

            // Learning Programs
            SliverToBoxAdapter(
              child: LearningProgramsSection(
                future: _programsFuture,
                isDark: isDark,
                locale: locale,
                isRtl: isRtl,
              ),
            ),

            // Top Instructors
            SliverToBoxAdapter(
              child: TopInstructorsSection(
                future: _instructorsFuture,
                isDark: isDark,
                locale: locale,
                isRtl: isRtl,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
