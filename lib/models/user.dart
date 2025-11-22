enum UserRole { user, clubLeader, admin }

extension UserRoleX on UserRole {
  String get value {
    switch (this) {
      case UserRole.user:
        return 'user';
      case UserRole.clubLeader:
        return 'club_leader';
      case UserRole.admin:
        return 'admin';
    }
  }

  bool get isAdmin => this == UserRole.admin;
  bool get isClubLeader => this == UserRole.clubLeader;
}

UserRole parseUserRole(String? raw) {
  switch ((raw ?? 'user').toLowerCase()) {
    case 'admin':
      return UserRole.admin;
    case 'club_leader':
      return UserRole.clubLeader;
    default:
      return UserRole.user;
  }
}

class User {
  final String id;
  final String name;
  final String studentId;
  final String major;
  final String year;
  final String email;
  final String phone;
  final String? avatar;
  final int mutualFriends;
  final UserRole role;
  final String accountStatus;
  final bool isLocked;
  final Map<String, dynamic> metadata;

  const User({
    required this.id,
    required this.name,
    required this.studentId,
    required this.major,
    required this.year,
    required this.email,
    required this.phone,
    this.avatar,
    this.mutualFriends = 0,
    this.role = UserRole.user,
    this.accountStatus = 'active',
    this.isLocked = false,
    this.metadata = const {},
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
      mutualFriends: json['mutualFriends'] ?? 0,
      role: parseUserRole(json['role']?.toString()),
      accountStatus: json['account_status'] ?? 'active',
      isLocked: json['is_locked'] ?? false,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? const {}),
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
      'role': role.value,
      'account_status': accountStatus,
      'is_locked': isLocked,
      'metadata': metadata,
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
    int? mutualFriends,
    UserRole? role,
    String? accountStatus,
    bool? isLocked,
    Map<String, dynamic>? metadata,
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
      mutualFriends: mutualFriends ?? this.mutualFriends,
      role: role ?? this.role,
      accountStatus: accountStatus ?? this.accountStatus,
      isLocked: isLocked ?? this.isLocked,
      metadata: metadata ?? this.metadata,
    );
  }
}
