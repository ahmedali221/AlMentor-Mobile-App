class Instructor {
  final String id;
  final String firstName;
  final String lastName;
  final String professionalTitle;
  final String profilePicture;
  final String biography;
  final List<String> expertiseAreas;

  Instructor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.professionalTitle,
    required this.profilePicture,
    required this.biography,
    required this.expertiseAreas,
  });

  factory Instructor.fromJson(Map<String, dynamic> json) {
    final profileData = json['profile'] ?? {};
    final firstNameData = profileData['firstName'] ?? {};
    final lastNameData = profileData['lastName'] ?? {};
    final professionalTitleData = json['professionalTitle'] ?? {};
    final biographyData = json['biography'] ?? {};
    final expertiseAreasData = json['expertiseAreas'] ?? {};
    final List<dynamic> expertiseList = expertiseAreasData['en'] ?? [];

    return Instructor(
      id: json['_id'] ?? '',
      firstName: firstNameData['en'] ?? '',
      lastName: lastNameData['en'] ?? '',
      professionalTitle: professionalTitleData['en'] ?? '',
      profilePicture: profileData['profilePicture'] ?? '',
      biography: biographyData['en'] ?? '',
      expertiseAreas: expertiseList.map((e) => e.toString()).toList(),
    );
  }
}
