class Lesson {
  final String id;
  final Map<String, String> title;
  final String moduleId;
  final String? courseId;
  final Map<String, String> description;
  final int order;
  final int duration;
  final bool isFree;
  final bool isPublished;
  final String? videoUrl;
  final Map<String, String>? articleText;
  final List<Attachment> attachments;

  Lesson({
    required this.id,
    required this.title,
    required this.moduleId,
    this.courseId,
    required this.description,
    required this.order,
    required this.duration,
    required this.isFree,
    required this.isPublished,
    this.videoUrl,
    this.articleText,
    required this.attachments,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['_id'],
      title: {
        'en': json['title']['en'] ?? '',
        'ar': json['title']['ar'] ?? '',
      },
      moduleId: json['module'],
      courseId: json['course'],
      description: {
        'en': json['description']?['en'] ?? '',
        'ar': json['description']?['ar'] ?? '',
      },
      order: json['order'],
      duration: json['duration'] ?? 0,
      isFree: json['isFree'] ?? false,
      isPublished: json['isPublished'] ?? false,
      videoUrl: json['content']?['videoUrl'],
      articleText: json['content']?['articleText'] != null
          ? Map<String, String>.from(json['content']['articleText'])
          : null,
      attachments: json['content']?['attachments'] != null
          ? List<Attachment>.from(
              json['content']['attachments'].map((x) => Attachment.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'module': moduleId,
      'course': courseId,
      'description': description,
      'order': order,
      'duration': duration,
      'isFree': isFree,
      'isPublished': isPublished,
      'content': {
        'videoUrl': videoUrl,
        'articleText': articleText,
        'attachments': attachments.map((a) => a.toJson()).toList(),
      },
    };
  }

  // Localization Helpers
  String getLocalizedTitle(String lang) {
    return title[lang] ?? title['en'] ?? '';
  }

  String getLocalizedDescription(String lang) {
    return description[lang] ?? description['en'] ?? '';
  }

  String? getLocalizedArticleText(String lang) {
    return articleText?[lang] ?? articleText?['en'];
  }
}

class Attachment {
  final Map<String, String> name;
  final String url;
  final String type;

  Attachment({
    required this.name,
    required this.url,
    required this.type,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      name: {
        'en': json['name']['en'] ?? '',
        'ar': json['name']['ar'] ?? '',
      },
      url: json['url'] ?? '',
      type: json['type'] ?? 'pdf',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'type': type,
    };
  }

  String getLocalizedName(String lang) {
    return name[lang] ?? name['en'] ?? '';
  }
}
