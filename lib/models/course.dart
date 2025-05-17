import 'package:flutter/material.dart';

class Course {
  final String id;
  final Map<String, String> title; // {en: String, ar: String}
  final Map<String, String> slug; // {en: String, ar: String}
  final String topicId;
  final String? subtopicId;
  final String instructorId;
  final String categoryId;
  final String thumbnail;
  final Map<String, String> description; // {en: String, ar: String}
  final Map<String, String>? shortDescription; // {en: String, ar: String}
  final List<String> moduleIds;
  final List<FreeLesson> freeLessons;
  final Map<String, String> level; // {en: String, ar: String}
  final Map<String, String> language; // {en: String, ar: String}
  final int duration;
  final DateTime lastUpdated;
  final int enrollmentCount;
  final bool isFree;
  final Rating rating;

  Course({
    required this.id,
    required this.title,
    required this.slug,
    required this.topicId,
    this.subtopicId,
    required this.instructorId,
    required this.categoryId,
    required this.thumbnail,
    required this.description,
    this.shortDescription,
    required this.moduleIds,
    required this.freeLessons,
    required this.level,
    required this.language,
    required this.duration,
    required this.lastUpdated,
    required this.enrollmentCount,
    required this.isFree,
    required this.rating,
  });

  // Factory constructor to create a Course from JSON data
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['_id'] ?? '',
      title: {
        'en': json['title']['en'] ?? '',
        'ar': json['title']['ar'] ?? '',
      },
      slug: {
        'en': json['slug']['en'] ?? '',
        'ar': json['slug']['ar'] ?? '',
      },
      topicId: json['topic'] ?? '',
      subtopicId: json['subtopic'],
      instructorId: json['instructor'] ?? '',
      categoryId: json['category'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      description: {
        'en': json['description']['en'] ?? '',
        'ar': json['description']['ar'] ?? '',
      },
      shortDescription: json['shortDescription'] != null
          ? {
              'en': json['shortDescription']['en'] ?? '',
              'ar': json['shortDescription']['ar'] ?? '',
            }
          : null,
      moduleIds:
          json['modules'] != null ? List<String>.from(json['modules']) : [],
      freeLessons: json['freeLessons'] != null
          ? List<FreeLesson>.from(
              json['freeLessons'].map((x) => FreeLesson.fromJson(x)))
          : [],
      level: {
        'en': json['level']['en'] ?? 'beginner',
        'ar': json['level']['ar'] ?? 'مبتدئ',
      },
      language: {
        'en': json['language']['en'] ?? 'Arabic',
        'ar': json['language']['ar'] ?? 'العربية',
      },
      duration: json['duration'] ?? 0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
      enrollmentCount: json['enrollmentCount'] ?? 0,
      isFree: json['isFree'] ?? false,
      rating: Rating.fromJson(json['rating'] ?? {'average': 0, 'count': 0}),
    );
  }

  // Get localized title based on current locale
  String getLocalizedTitle(Locale locale) {
    return title[locale.languageCode] ?? title['en'] ?? '';
  }

  // Get localized description based on current locale
  String getLocalizedDescription(Locale locale) {
    return description[locale.languageCode] ?? description['en'] ?? '';
  }

  // Get localized short description based on current locale
  String? getLocalizedShortDescription(Locale locale) {
    if (shortDescription == null) return null;
    return shortDescription![locale.languageCode] ?? shortDescription!['en'];
  }

  // Get localized level based on current locale
  String getLocalizedLevel(Locale locale) {
    return level[locale.languageCode] ?? level['en'] ?? '';
  }

  // Get localized language based on current locale
  String getLocalizedLanguage(Locale locale) {
    return language[locale.languageCode] ?? language['en'] ?? '';
  }
}

class FreeLesson {
  final String lessonId;
  final String title;
  final int duration;

  FreeLesson({
    required this.lessonId,
    required this.title,
    required this.duration,
  });

  factory FreeLesson.fromJson(Map<String, dynamic> json) {
    return FreeLesson(
      lessonId: json['lessonId'] ?? '',
      title: json['title'] ?? '',
      duration: json['duration'] ?? 0,
    );
  }
}

class Rating {
  final double average;
  final int count;

  Rating({
    required this.average,
    required this.count,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      average: (json['average'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
    );
  }
}
