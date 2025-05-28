class UserSavedCourse {
  final String id;
  final String userId;
  final Map<String, dynamic> course;
  final DateTime savedAt;
  final int version;

  UserSavedCourse({
    required this.id,
    required this.userId,
    required this.course,
    required this.savedAt,
    required this.version,
  });

  factory UserSavedCourse.fromJson(Map<String, dynamic> json) {
    return UserSavedCourse(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      course: Map<String, dynamic>.from(json['courseId'] ?? {}),
      savedAt: DateTime.tryParse(json['savedAt'] ?? '') ?? DateTime.now(),
      version: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'courseId': course,
      'savedAt': savedAt.toIso8601String(),
      '__v': version,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSavedCourse &&
        other.id == id &&
        other.userId == userId &&
        other.course == course;
  }

  @override
  int get hashCode {
    return id.hashCode ^ userId.hashCode ^ course.hashCode;
  }

  @override
  String toString() {
    return 'UserSavedCourse(id: $id, userId: $userId, courseTitle: ${course['title']?['en']}, savedAt: $savedAt)';
  }
}
