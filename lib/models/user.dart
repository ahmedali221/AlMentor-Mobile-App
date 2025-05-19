class User {
  final String id;
  final String username;
  final String email;
  final String profilePicture;
  final String firstNameEn;
  final String firstNameAr;
  final String lastNameEn;
  final String lastNameAr;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.profilePicture,
    required this.firstNameEn,
    required this.firstNameAr,
    required this.lastNameEn,
    required this.lastNameAr,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      username: json['username'],
      email: json['email'],
      profilePicture: json['profilePicture'],
      firstNameEn: json['firstName']['en'],
      firstNameAr: json['firstName']['ar'],
      lastNameEn: json['lastName']['en'],
      lastNameAr: json['lastName']['ar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profilePicture': profilePicture,
      'firstNameEn': firstNameEn,
      'firstNameAr': firstNameAr,
      'lastNameEn': lastNameEn,
      'lastNameAr': lastNameAr,
    };
  }
}
