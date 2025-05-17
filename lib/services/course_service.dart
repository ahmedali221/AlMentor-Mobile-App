import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course.dart';
import '../Core/Constants/apiConstants.dart';

class CourseService {
  // Get all courses
  Future<List<Course>> getCourses() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.7:5000/api/courses'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> coursesJson = json.decode(response.body);
        print("Courses Data: " + coursesJson.toString());
        return coursesJson.map((json) => Course.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load courses: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching courses: $e");
      // Return demo data for now
      return _getDemoCourses();
    }
  }

  // Get course by ID
  Future<Course> getCourseById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/courses/$id'),
      );

      if (response.statusCode == 200) {
        return Course.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load course: ${response.statusCode}');
      }
    } catch (e) {
      // Return a demo course for now
      return _getDemoCourses().first;
    }
  }

  // Demo data for testing
  List<Course> _getDemoCourses() {
    return [
      Course(
        id: '1',
        title: {
          'en': 'Learn Programming Basics',
          'ar': 'تعلم أساسيات البرمجة',
        },
        slug: {
          'en': 'learn-programming-basics',
          'ar': 'تعلم-أساسيات-البرمجة',
        },
        topicId: '1',
        instructorId: '1',
        categoryId: '1',
        thumbnail: 'assets/images/f1.png',
        description: {
          'en':
              'A comprehensive course to learn programming basics for beginners',
          'ar': 'دورة شاملة لتعلم أساسيات البرمجة للمبتدئين',
        },
        shortDescription: {
          'en': 'Learn programming from scratch',
          'ar': 'تعلم البرمجة من الصفر',
        },
        moduleIds: ['1', '2', '3'],
        freeLessons: [
          FreeLesson(
            lessonId: '1',
            title: 'Introduction to Programming',
            duration: 10,
          ),
        ],
        level: {
          'en': 'beginner',
          'ar': 'مبتدئ',
        },
        language: {
          'en': 'Arabic',
          'ar': 'العربية',
        },
        duration: 120,
        lastUpdated: DateTime.now(),
        enrollmentCount: 1200,
        isFree: false,
        rating: Rating(average: 4.5, count: 120),
      ),
      Course(
        id: '2',
        title: {
          'en': 'Web Development',
          'ar': 'تطوير تطبيقات الويب',
        },
        slug: {
          'en': 'web-development',
          'ar': 'تطوير-تطبيقات-الويب',
        },
        topicId: '2',
        instructorId: '2',
        categoryId: '2',
        thumbnail: 'assets/images/f2.png',
        description: {
          'en': 'Learn how to develop modern web applications',
          'ar': 'تعلم كيفية تطوير تطبيقات الويب الحديثة',
        },
        shortDescription: {
          'en': 'Modern web development',
          'ar': 'تطوير الويب الحديث',
        },
        moduleIds: ['4', '5', '6'],
        freeLessons: [
          FreeLesson(
            lessonId: '2',
            title: 'HTML Basics',
            duration: 15,
          ),
        ],
        level: {
          'en': 'intermediate',
          'ar': 'متوسط',
        },
        language: {
          'en': 'Arabic',
          'ar': 'العربية',
        },
        duration: 180,
        lastUpdated: DateTime.now(),
        enrollmentCount: 850,
        isFree: false,
        rating: Rating(average: 4.7, count: 95),
      ),
      Course(
        id: '3',
        title: {
          'en': 'UI/UX Design',
          'ar': 'تصميم واجهات المستخدم',
        },
        slug: {
          'en': 'ui-ux-design',
          'ar': 'تصميم-واجهات-المستخدم',
        },
        topicId: '3',
        instructorId: '3',
        categoryId: '3',
        thumbnail: 'assets/images/f3.png',
        description: {
          'en': 'Advanced course in user interface design',
          'ar': 'دورة متقدمة في تصميم واجهات المستخدم',
        },
        shortDescription: {
          'en': 'Master UI/UX design',
          'ar': 'إتقان تصميم واجهات المستخدم',
        },
        moduleIds: ['7', '8', '9'],
        freeLessons: [
          FreeLesson(
            lessonId: '3',
            title: 'Design Principles',
            duration: 12,
          ),
        ],
        level: {
          'en': 'advanced',
          'ar': 'متقدم',
        },
        language: {
          'en': 'Arabic',
          'ar': 'العربية',
        },
        duration: 150,
        lastUpdated: DateTime.now(),
        enrollmentCount: 650,
        isFree: true,
        rating: Rating(average: 4.8, count: 75),
      ),
    ];
  }
}
