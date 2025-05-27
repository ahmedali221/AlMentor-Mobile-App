
class Program {
  final String id;
  final Map<String, String> title;
  final Map<String, String> slug;
  final Map<String, String> description;
  final Map<String, String> level;
  final Map<String, String> category;
  final String thumbnail;
  final String language;
  final int totalDuration;
  final List<String> courseIds;
  final List<LearningOutcome> learningOutcomes;
  final List<Map<String, dynamic>> courseDetails; // <-- changed here

  Program({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.level,
    required this.category,
    required this.thumbnail,
    required this.language,
    required this.totalDuration,
    required this.courseIds,
    required this.learningOutcomes,
    required this.courseDetails, // <-- changed here
  });

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      id: json['_id'] ?? json['id'] ?? '',
      title: Map<String, String>.from(json['title'] ?? {}),
      slug: Map<String, String>.from(json['slug'] ?? {}),
      description: Map<String, String>.from(json['description'] ?? {}),
      level: Map<String, String>.from(json['level'] ?? {}),
      category: Map<String, String>.from(json['category'] ?? {}),
      thumbnail: json['thumbnail'] ?? '',
      language: json['language'] ?? '',
      totalDuration: json['totalDuration'] ?? 0,
      courseIds: (json['courses'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      learningOutcomes: (json['learningOutcomes'] as List<dynamic>?)
              ?.map((e) => LearningOutcome.fromJson(e))
              .toList() ??
          [],
      courseDetails: (json['courseDetails'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
    );
  }
}

class LearningOutcome {
  final String id;
  final String en;
  final String ar;

  LearningOutcome({
    required this.id,
    required this.en,
    required this.ar,
  });

  factory LearningOutcome.fromJson(Map<String, dynamic> json) {
    return LearningOutcome(
      id: json['_id'] ?? json['id'] ?? '',
      en: json['en'] ?? '',
      ar: json['ar'] ?? '',
    );
  }
}
