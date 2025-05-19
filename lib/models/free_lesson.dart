import 'package:flutter/material.dart';

class FreeLesson {
  final String lessonId;
  final Map<String, String> title; // {en: String, ar: String}
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

  // Get localized title based on current locale
  String getLocalizedTitle(Locale locale) {
    return title[locale.languageCode] ?? title['en'] ?? '';
  }
}
