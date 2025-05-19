class Program {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int coursesCount;
  final String buttonText;
  final List<String>? courseIds;

  Program({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.coursesCount,
    required this.buttonText,
    this.courseIds,
  });

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      id: json['_id'] ?? '',
      title: json['title']?['ar'] ?? '',
      description: json['description']?['ar'] ?? '',
      imageUrl: json['imageUrl'] ?? 'assets/images/placeholder.jpg',
      coursesCount: json['coursesCount'] ?? 0,
      buttonText: json['buttonText'] ?? 'برنامج تعليمي',
      courseIds: json['courseIds'] != null
          ? List<String>.from(json['courseIds'])
          : null,
    );
  }

  // Demo programs for testing
  static List<Program> getDemoPrograms() {
    return [
      Program(
        id: '1',
        title: 'تطوير الذات',
        description: 'برنامج شامل لتطوير المهارات الشخصية والمهنية',
        imageUrl: 'assets/images/program1.jpg',
        coursesCount: 5,
        buttonText: 'برنامج تعليمي',
      ),
      Program(
        id: '2',
        title: 'تعلم البرمجة',
        description: 'برنامج متكامل لتعلم أساسيات البرمجة والتطوير',
        imageUrl: 'assets/images/program2.jpg',
        coursesCount: 8,
        buttonText: 'برنامج تعليمي',
      ),
      Program(
        id: '3',
        title: 'مهارات الإدارة',
        description: 'برنامج لتطوير مهارات القيادة والإدارة',
        imageUrl: 'assets/images/program3.jpg',
        coursesCount: 4,
        buttonText: 'برنامج تعليمي',
      ),
    ];
  }
}
