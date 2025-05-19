import 'package:almentor_clone/models/course.dart';
import 'package:almentor_clone/models/module.dart';
import 'package:flutter/material.dart';

class Lesson {
  final String id;
  final Map<String, String> title;
  final Map<String, String> description;
  final LessonContent content;
  final String moduleId;
  final Course course;
  final Module module;
  final int order;
  final int duration;
  final bool isFree;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.moduleId,
    required this.course,
    required this.module,
    required this.order,
    required this.duration,
    required this.isFree,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['_id'] ?? '',
      title: {
        'en': json['title']['en'] ?? '',
        'ar': json['title']['ar'] ?? '',
      },
      description: {
        'en': json['description']['en'] ?? '',
        'ar': json['description']['ar'] ?? '',
      },
      content: LessonContent.fromJson(json['content'] ?? {}),
      moduleId: json['module'] is Map
          ? json['module']['_id'] ?? ''
          : json['module'] ?? '',
      course: Course.fromJson(json['course'] ?? {}),
      module: Module.fromJson(json['module'] is Map ? json['module'] : {}),
      order: json['order'] ?? 0,
      duration: json['duration'] ?? 0,
      isFree: json['isFree'] ?? false,
      isPublished: json['isPublished'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'content': content.toJson(),
      'module': moduleId,
      'course': course.toJson(),
      'order': order,
      'duration': duration,
      'isFree': isFree,
      'isPublished': isPublished,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String getLocalizedTitle(Locale locale) =>
      title[locale.languageCode] ?? title['en'] ?? '';

  String getLocalizedDescription(Locale locale) =>
      description[locale.languageCode] ?? description['en'] ?? '';
}

class LessonContent {
  final Map<String, String> articleText;
  final String videoUrl;
  final List<dynamic> attachments;

  LessonContent({
    required this.articleText,
    required this.videoUrl,
    required this.attachments,
  });

  factory LessonContent.fromJson(Map<String, dynamic> json) {
    return LessonContent(
      articleText: {
        'en': json['articleText']?['en'] ?? '',
        'ar': json['articleText']?['ar'] ?? '',
      },
      videoUrl: json['videoUrl'] ?? '',
      attachments: json['attachments'] != null
          ? List<dynamic>.from(json['attachments'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'articleText': articleText,
      'videoUrl': videoUrl,
      'attachments': attachments,
    };
  }

  String getLocalizedArticleText(Locale locale) =>
      articleText[locale.languageCode] ?? articleText['en'] ?? '';
}
