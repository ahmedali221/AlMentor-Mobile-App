import 'package:almentor_clone/models/instructor.dart';
import 'package:almentor_clone/models/module.dart';
import 'package:flutter/material.dart';

class Course {
  final String id;
  final Map<String, String> title;
  final Map<String, String> slug;
  final Map<String, String> description;
  final Map<String, String>? shortDescription;
  final Map<String, String> level;
  final Map<String, String> language;
  final String thumbnail;
  final int duration;
  final int enrollmentCount;
  final bool isFree;
  final Rating rating;
  final DateTime lastUpdated;

  final String topicId;
  final String? subtopicId;
  final String categoryId;
  final List<Module> modules;
  final List<FreeLesson> freeLessons;
  final Instructor instructor;

  Course({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    this.shortDescription,
    required this.level,
    required this.language,
    required this.thumbnail,
    required this.duration,
    required this.enrollmentCount,
    required this.isFree,
    required this.rating,
    required this.lastUpdated,
    required this.topicId,
    this.subtopicId,
    required this.categoryId,
    required this.modules,
    required this.freeLessons,
    required this.instructor,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    String getLang(Map? map) => map?['en'] ?? map?.values.first ?? '';

    return Course(
      id: json['_id'] ?? '',
      title: {
        'en': getLang(json['title']['en']),
        'ar': getLang(json['title']['ar']),
      },
      slug: {
        'en': getLang(json['slug']['en']),
        'ar': getLang(json['slug']['ar']),
      },
      description: {
        'en': getLang(json['description']['en']),
        'ar': getLang(json['description']['ar']),
      },
      shortDescription: json['shortDescription'] != null
          ? {
              'en': getLang(json['shortDescription']['en']),
              'ar': getLang(json['shortDescription']['ar']),
            }
          : null,
      level: {
        'en': getLang(json['level']['en']) ?? 'beginner',
        'ar': getLang(json['level']['ar']) ?? 'مبتدئ',
      },
      language: {
        'en': getLang(json['language']['en']) ?? 'Arabic',
        'ar': getLang(json['language']['ar']) ?? 'العربية',
      },
      thumbnail: getLang(json['thumbnail']),
      duration: json['duration'] != null
          ? (json['duration'] is int
              ? json['duration']
              : int.tryParse(json['duration'].toString()) ?? 0)
          : 0,
      enrollmentCount: json['enrollmentCount'] != null
          ? (json['enrollmentCount'] is int
              ? json['enrollmentCount']
              : int.tryParse(json['enrollmentCount'].toString()) ?? 0)
          : 0,
      isFree: json['isFree'] ?? false,
      rating: Rating.fromJson(json['rating'] ?? {'average': 0, 'count': 0}),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
      topicId: getLang(json['topic']),
      subtopicId: getLang(json['subtopic']),
      categoryId: getLang(json['category']),
      modules: json['modules'] != null
          ? List<Module>.from(json['modules'].map((x) => Module.fromJson(x)))
          : [],
      freeLessons: json['freeLessons'] != null
          ? List<FreeLesson>.from(
              json['freeLessons'].map((x) => FreeLesson.fromJson(x)))
          : [],
      instructor: Instructor.fromJson(json['instructor']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'description': description,
      'shortDescription': shortDescription,
      'level': level,
      'language': language,
      'thumbnail': thumbnail,
      'duration': duration,
      'enrollmentCount': enrollmentCount,
      'isFree': isFree,
      'rating': rating.toJson(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'topicId': topicId,
      'subtopicId': subtopicId,
      'categoryId': categoryId,
      'modules': modules.map((m) => m.toJson()).toList(),
      'freeLessons': freeLessons.map((l) => l.toJson()).toList(),
      'instructor':
          instructor.toJson(), // Call toJson() on the instructor object
    };
  }

  String getLocalizedTitle(Locale locale) =>
      title[locale.languageCode] ?? title['en'] ?? '';

  String getLocalizedDescription(Locale locale) =>
      description[locale.languageCode] ?? description['en'] ?? '';

  String? getLocalizedShortDescription(Locale locale) =>
      shortDescription?[locale.languageCode] ?? shortDescription?['en'];

  String getLocalizedLevel(Locale locale) =>
      level[locale.languageCode] ?? level['en'] ?? '';

  String getLocalizedLanguage(Locale locale) =>
      language[locale.languageCode] ?? language['en'] ?? '';
}

class FreeLesson {
  final String lessonId;
  final Map<String, String> title;
  final int duration;

  FreeLesson({
    required this.lessonId,
    required this.title,
    required this.duration,
  });

  factory FreeLesson.fromJson(Map<String, dynamic> json) {
    return FreeLesson(
      lessonId: json['lessonId'] ?? '',
      title: json['title'] is Map
          ? Map<String, String>.from(json['title'])
          : {'en': json['title'] ?? '', 'ar': json['title'] ?? ''},
      duration: json['duration'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'title': title,
      'duration': duration,
    };
  }

  String getLocalizedTitle(Locale locale) {
    return title[locale.languageCode] ?? title['en'] ?? '';
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

  Map<String, dynamic> toJson() {
    return {
      'average': average,
      'count': count,
    };
  }
}
