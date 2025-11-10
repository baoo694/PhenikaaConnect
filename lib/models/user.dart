class User {
  final String id;
  final String name;
  final String studentId;
  final String major;
  final String year;
  final String email;
  final String phone;
  final String? avatar;
  final List<String> interests;
  final int mutualFriends;

  const User({
    required this.id,
    required this.name,
    required this.studentId,
    required this.major,
    required this.year,
    required this.email,
    required this.phone,
    this.avatar,
    this.interests = const [],
    this.mutualFriends = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      studentId: json['student_id'] ?? '',
      major: json['major'] ?? '',
      year: json['year'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatar: json['avatar_url'],
      interests: List<String>.from(json['interests'] ?? []),
      mutualFriends: json['mutualFriends'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'student_id': studentId,
      'major': major,
      'year': year,
      'email': email,
      'phone': phone,
      'avatar_url': avatar,
      'interests': interests,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? studentId,
    String? major,
    String? year,
    String? email,
    String? phone,
    String? avatar,
    List<String>? interests,
    int? mutualFriends,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      studentId: studentId ?? this.studentId,
      major: major ?? this.major,
      year: year ?? this.year,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      interests: interests ?? this.interests,
      mutualFriends: mutualFriends ?? this.mutualFriends,
    );
  }
}
