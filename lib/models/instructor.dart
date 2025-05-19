import 'user.dart';

class Instructor {
  final String id;
  final String professionalTitleEn;
  final String professionalTitleAr;
  final List<String> expertiseEn;
  final List<String> expertiseAr;
  final String biographyEn;
  final String biographyAr;
  final int yearsOfExperience;
  final String approvalStatus;
  final User user;
  final Map<String, String> socialMediaLinks;

  Instructor({
    required this.id,
    required this.professionalTitleEn,
    required this.professionalTitleAr,
    required this.expertiseEn,
    required this.expertiseAr,
    required this.biographyEn,
    required this.biographyAr,
    required this.yearsOfExperience,
    required this.approvalStatus,
    required this.user,
    required this.socialMediaLinks,
  });

  factory Instructor.fromJson(Map<String, dynamic> json) {
    return Instructor(
      id: json['_id'],
      professionalTitleEn: json['professionalTitle']['en'],
      professionalTitleAr: json['professionalTitle']['ar'],
      expertiseEn: List<String>.from(json['expertiseAreas']['en']),
      expertiseAr: List<String>.from(json['expertiseAreas']['ar']),
      biographyEn: json['biography']['en'],
      biographyAr: json['biography']['ar'],
      yearsOfExperience: json['yearsOfExperience'] ?? 0,
      approvalStatus: json['approvalStatus'],
      user: User.fromJson(json['user']),
      socialMediaLinks: Map<String, String>.from(json['socialMediaLinks'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'professionalTitleEn': professionalTitleEn,
      'professionalTitleAr': professionalTitleAr,
      'expertiseEn': expertiseEn,
      'expertiseAr': expertiseAr,
      'biographyEn': biographyEn,
      'biographyAr': biographyAr,
      'yearsOfExperience': yearsOfExperience,
      'approvalStatus': approvalStatus,
      'user': user.toJson(), // Assuming User class has a toJson method
      'socialMediaLinks': socialMediaLinks,
    };
  }
}
