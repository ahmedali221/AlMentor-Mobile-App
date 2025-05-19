import 'lesson.dart';

class Module {
  final String id;
  final Map<String, String> title;
  final String courseId;
  final int order;
  final int duration;
  final bool isPublished;
  final String completionCriteria;
  final Map<String, String> level;
  final List<Lesson> lessons;

  Module({
    required this.id,
    required this.title,
    required this.courseId,
    required this.order,
    required this.duration,
    required this.isPublished,
    required this.completionCriteria,
    required this.level,
    required this.lessons,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['_id'],
      title: {
        'en': json['title']['en'] ?? '',
        'ar': json['title']['ar'] ?? '',
      },
      courseId: json['course'],
      order: json['order'],
      duration: json['duration'] ?? 0,
      isPublished: json['isPublished'] ?? false,
      completionCriteria: json['completionCriteria'] ?? 'all-lessons',
      level: {
        'en': json['level']['en'] ?? 'beginner',
        'ar': json['level']['ar'] ?? 'مبتدئ',
      },
      lessons: json['lessons'] != null
          ? List<Lesson>.from(json['lessons'].map((x) => Lesson.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'course': courseId,
      'order': order,
      'duration': duration,
      'isPublished': isPublished,
      'completionCriteria': completionCriteria,
      'level': level,
      'lessons': lessons.map((l) => l.toJson()).toList(),
    };
  }

  // Localization Helpers
  String getLocalizedTitle(String lang) {
    return title[lang] ?? title['en'] ?? '';
  }

  String getLocalizedLevel(String lang) {
    return level[lang] ?? level['en'] ?? '';
  }
}
