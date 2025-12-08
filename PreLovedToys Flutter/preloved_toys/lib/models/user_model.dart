class User {
  final int id;
  final String mobile;
  final String? name;
  final String? email;
  final String? gender;
  final String? occupation;
  final String? collegeOrUniversity;
  final String? aboutMe;
  final String? purpose;
  final List<String>? interestedIn;
  final String role;
  final bool isActive;
  final String? token;

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

  factory User.fromJson(Map<String, dynamic> json, {String? token}) {
    // --- DEBUGGING PRINTS ---
    print("--- PARSING USER JSON ---");
    print("Raw Email value: ${json['email']}");
    print("Raw Gender value: ${json['gender']}");
    print("Full JSON keys: ${json.keys.toList()}");
    // ------------------------

    // Helper to safely parse the 'interestedIn' array or string
    List<String> interests = [];
    if (json['interestedIn'] != null) {
      if (json['interestedIn'] is List) {
        interests = List<String>.from(json['interestedIn']);
      } else if (json['interestedIn'] is String) {
        interests = json['interestedIn'].toString().split(',');
      }
    }

    return User(
      id: json['id'],
      mobile: json['mobile'] ?? '',
      name: json['name'],
      // Ensure we treat it as a string, or null if missing
      email: json['email']?.toString(),
      gender: json['gender']?.toString(),
      occupation: json['occupation'],
      collegeOrUniversity: json['collegeOrUniversity'],
      aboutMe: json['aboutMe'],
      purpose: json['purpose'],
      interestedIn: interests,
      role: json['role'] ?? 'user',
      isActive: json['isActive'] ?? true,
      token: token,
    );
  }
}
