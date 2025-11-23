enum ApprovalStatus { pending, approved, rejected }

ApprovalStatus parseApprovalStatus(String? raw) {
  switch ((raw ?? 'pending').toLowerCase()) {
    case 'approved':
      return ApprovalStatus.approved;
    case 'rejected':
      return ApprovalStatus.rejected;
    default:
      return ApprovalStatus.pending;
  }
}

extension ApprovalStatusX on ApprovalStatus {
  String get value {
    switch (this) {
      case ApprovalStatus.pending:
        return 'pending';
      case ApprovalStatus.approved:
        return 'approved';
      case ApprovalStatus.rejected:
        return 'rejected';
    }
  }
}

enum VisibilityScope { campus, clubOnly }

VisibilityScope parseVisibilityScope(String? raw) {
  switch ((raw ?? 'campus').toLowerCase()) {
    case 'public':
      // Backward compatibility: map old 'public' to 'campus'
      return VisibilityScope.campus;
    case 'campus':
      return VisibilityScope.campus;
    case 'club_only':
      return VisibilityScope.clubOnly;
    default:
      return VisibilityScope.campus;
  }
}

extension VisibilityScopeX on VisibilityScope {
  String get value {
    switch (this) {
      case VisibilityScope.campus:
        return 'campus';
      case VisibilityScope.clubOnly:
        return 'club_only';
    }
  }
}

class Event {
  final String id;
  final String title;
  final String? description;
  final String date;
  final String time;
  final String location;
  final String organizer;
  final int attendees;
  final int? maxAttendees;
  final String category;
  final String image;
  final bool isJoined;
  final String? clubId;
  final String? clubName; // Tên CLB nếu event do CLB tạo
  final ApprovalStatus status;
  final VisibilityScope visibility;

  const Event({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.organizer,
    required this.attendees,
    this.maxAttendees,
    required this.category,
    required this.image,
    this.isJoined = false,
    this.clubId,
    this.clubName,
    this.status = ApprovalStatus.pending,
    this.visibility = VisibilityScope.campus,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description']?.toString(),
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      location: json['location'] ?? '',
      organizer: json['organizer'] ?? '',
      attendees: json['attendees'] ?? 0,
      maxAttendees: json['max_attendees'] != null ? int.tryParse(json['max_attendees'].toString()) : null,
      category: json['category'] ?? '',
      image: json['image'] ?? '',
      isJoined: json['isJoined'] ?? false,
      clubId: json['club_id']?.toString(),
      clubName: json['clubName']?.toString() ?? (json['clubs'] != null && json['clubs'] is Map ? json['clubs']['name']?.toString() : null),
      status: parseApprovalStatus(json['status']?.toString()),
      visibility: parseVisibilityScope(json['visibility']?.toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'time': time,
      'location': location,
      'organizer': organizer,
      'attendees': attendees,
      'max_attendees': maxAttendees,
      'category': category,
      'image': image,
      'isJoined': isJoined,
      'club_id': clubId,
      'clubName': clubName,
      'status': status.value,
      'visibility': visibility.value,
    };
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? date,
    String? time,
    String? location,
    String? organizer,
    int? attendees,
    int? maxAttendees,
    String? category,
    String? image,
    bool? isJoined,
    String? clubId,
    String? clubName,
    ApprovalStatus? status,
    VisibilityScope? visibility,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      organizer: organizer ?? this.organizer,
      attendees: attendees ?? this.attendees,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      category: category ?? this.category,
      image: image ?? this.image,
      isJoined: isJoined ?? this.isJoined,
      clubId: clubId ?? this.clubId,
      clubName: clubName ?? this.clubName,
      status: status ?? this.status,
      visibility: visibility ?? this.visibility,
    );
  }
}

class Location {
  final String id;
  final String name;
  final String type;
  final String building;
  final String floor;
  final bool popular;

  const Location({
    required this.id,
    required this.name,
    required this.type,
    required this.building,
    required this.floor,
    required this.popular,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      building: json['building'] ?? '',
      floor: json['floor'] ?? '',
      popular: json['popular'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'building': building,
      'floor': floor,
      'popular': popular,
    };
  }
}

class Club {
  final String id;
  final String name;
  final int members;
  final String category;
  final String description;
  final bool active;
  final bool isJoined;
  final ApprovalStatus status;
  final VisibilityScope visibility;
  final String? leaderId;
  final Map<String, dynamic> metadata;

  const Club({
    required this.id,
    required this.name,
    required this.members,
    required this.category,
    required this.description,
    required this.active,
    this.isJoined = false,
    this.status = ApprovalStatus.pending,
    this.visibility = VisibilityScope.clubOnly,
    this.leaderId,
    this.metadata = const {},
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      members: json['members_count'] ?? json['members'] ?? 0,
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      active: json['active'] ?? false,
      isJoined: json['isJoined'] ?? false,
      status: parseApprovalStatus(json['status']?.toString()),
      visibility: parseVisibilityScope(json['visibility']?.toString()),
      leaderId: json['leader_id']?.toString(),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? const {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'members_count': members,
      'category': category,
      'description': description,
      'active': active,
      'isJoined': isJoined,
      'status': status.value,
      'visibility': visibility.value,
      'leader_id': leaderId,
      'metadata': metadata,
    };
  }

  Club copyWith({
    String? id,
    String? name,
    int? members,
    String? category,
    String? description,
    bool? active,
    bool? isJoined,
    ApprovalStatus? status,
    VisibilityScope? visibility,
    String? leaderId,
    Map<String, dynamic>? metadata,
  }) {
    return Club(
      id: id ?? this.id,
      name: name ?? this.name,
      members: members ?? this.members,
      category: category ?? this.category,
      description: description ?? this.description,
      active: active ?? this.active,
      isJoined: isJoined ?? this.isJoined,
      status: status ?? this.status,
      visibility: visibility ?? this.visibility,
      leaderId: leaderId ?? this.leaderId,
      metadata: metadata ?? this.metadata,
    );
  }
}

class ClubMember {
  final String id;
  final String clubId;
  final String userId;
  final String role;
  final String status;
  final DateTime joinedAt;
  final Map<String, dynamic>? userInfo; // Thông tin user từ join

  ClubMember({
    required this.id,
    required this.clubId,
    required this.userId,
    required this.role,
    required this.status,
    required this.joinedAt,
    this.userInfo,
  });

  factory ClubMember.fromJson(Map<String, dynamic> json) {
    return ClubMember(
      id: json['id'] ?? '',
      clubId: json['club_id'] ?? '',
      userId: json['user_id'] ?? '',
      role: json['role'] ?? 'member',
      status: json['status'] ?? 'pending',
      joinedAt: DateTime.tryParse(json['joined_at'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      userInfo: json['users'] != null 
          ? Map<String, dynamic>.from(json['users'] is Map ? json['users'] : {})
          : null,
    );
  }

  String get userName => userInfo?['name'] ?? userId;
  String get studentId => userInfo?['student_id'] ?? '';
  String get major => userInfo?['major'] ?? '';
  String get year => userInfo?['year'] ?? '';
  String? get avatar => userInfo?['avatar_url'];
}

class ClubPost {
  final String id;
  final String clubId;
  final String? authorId;
  final String? title;
  final String content;
  final VisibilityScope visibility;
  final bool pinned;
  final DateTime createdAt;
  final List<dynamic> attachments;

  ClubPost({
    required this.id,
    required this.clubId,
    required this.content,
    this.authorId,
    this.title,
    this.visibility = VisibilityScope.clubOnly,
    this.pinned = false,
    DateTime? createdAt,
    this.attachments = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  factory ClubPost.fromJson(Map<String, dynamic> json) {
    return ClubPost(
      id: json['id'] ?? '',
      clubId: json['club_id'] ?? '',
      authorId: json['author_id']?.toString(),
      title: json['title']?.toString(),
      content: json['content'] ?? '',
      visibility: parseVisibilityScope(json['visibility']?.toString()),
      pinned: json['pinned'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
      attachments: List<dynamic>.from(json['attachments'] ?? const []),
    );
  }
}

class ClubActivity {
  final String id;
  final String clubId;
  final String? creatorId;
  final String title;
  final String? description;
  final DateTime date;
  final String? location;
  final ApprovalStatus status;
  final VisibilityScope visibility;

  ClubActivity({
    required this.id,
    required this.clubId,
    required this.title,
    required this.date,
    this.creatorId,
    this.description,
    this.location,
    this.status = ApprovalStatus.pending,
    this.visibility = VisibilityScope.clubOnly,
  });

  factory ClubActivity.fromJson(Map<String, dynamic> json) {
    return ClubActivity(
      id: json['id'] ?? '',
      clubId: json['club_id'] ?? '',
      creatorId: json['creator_id']?.toString(),
      title: json['title'] ?? '',
      description: json['description']?.toString(),
      date: DateTime.tryParse(json['activity_date'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      location: json['location']?.toString(),
      status: parseApprovalStatus(json['status']?.toString()),
      visibility: parseVisibilityScope(json['visibility']?.toString()),
    );
  }
}
