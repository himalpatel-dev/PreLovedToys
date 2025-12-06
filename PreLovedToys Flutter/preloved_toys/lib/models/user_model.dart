class User {
  final int id; // Changed to int because Sequelize uses DataTypes.INTEGER
  final String mobile;
  final String? name;
  final String? email;
  final String? gender;
  final String? occupation;
  final String? collegeOrUniversity;
  final String? aboutMe;
  final String? purpose;
  final List<dynamic>? interestedIn; // Handles the DataTypes.JSON array
  final String role;
  final bool isActive;
  final String? token; // To store the JWT

  User({
    required this.id,
    required this.mobile,
    this.name,
    this.email,
    this.gender,
    this.occupation,
    this.collegeOrUniversity,
    this.aboutMe,
    this.purpose,
    this.interestedIn,
    required this.role,
    required this.isActive,
    this.token,
  });

  // Factory constructor to create a User from JSON
  factory User.fromJson(Map<String, dynamic> json, {String? token}) {
    return User(
      id: json['id'], 
      mobile: json['mobile'],
      name: json['name'],
      email: json['email'],
      gender: json['gender'],
      occupation: json['occupation'],
      collegeOrUniversity: json['collegeOrUniversity'],
      aboutMe: json['aboutMe'],
      purpose: json['purpose'],
      interestedIn: json['interestedIn'] != null ? List<dynamic>.from(json['interestedIn']) : [],
      role: json['role'] ?? 'user',
      isActive: json['isActive'] ?? true,
      token: token,
    );
  }
}