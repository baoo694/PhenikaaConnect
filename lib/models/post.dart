class Post {
  final String id;
  final String author;
  final String major;
  final String avatar;
  final String time;
  final String content;
  final String? imageUrl;
  final int likes;
  final int comments;
  final int shares;
  final bool liked;

  const Post({
    required this.id,
    required this.author,
    required this.major,
    required this.avatar,
    required this.time,
    required this.content,
    this.imageUrl,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.liked,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? '',
      author: json['author'] ?? '',
      major: json['major'] ?? '',
      avatar: json['avatar'] ?? '',
      time: json['time'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['image_url'],
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
      liked: json['liked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'major': major,
      'avatar': avatar,
      'time': time,
      'content': content,
      'image_url': imageUrl,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'liked': liked,
    };
  }

  Post copyWith({
    String? id,
    String? author,
    String? major,
    String? avatar,
    String? time,
    String? content,
    String? imageUrl,
    int? likes,
    int? comments,
    int? shares,
    bool? liked,
  }) {
    return Post(
      id: id ?? this.id,
      author: author ?? this.author,
      major: major ?? this.major,
      avatar: avatar ?? this.avatar,
      time: time ?? this.time,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      liked: liked ?? this.liked,
    );
  }
}

class Question {
  final String id;
  final String course;
  final String title;
  final String author;
  final int replies;
  final String time;
  final bool solved;
  final String content;
  final String? userId;

  const Question({
    required this.id,
    required this.course,
    required this.title,
    required this.author,
    required this.replies,
    required this.time,
    required this.solved,
    required this.content,
    this.userId,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? '',
      course: json['course'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      replies: json['replies'] ?? 0,
      time: json['time'] ?? '',
      solved: json['solved'] ?? false,
      content: json['content'] ?? '',
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course': course,
      'title': title,
      'author': author,
      'replies': replies,
      'time': time,
      'solved': solved,
      'content': content,
      'user_id': userId,
    };
  }
}

class StudyGroup {
  final String id;
  final String name;
  final String course;
  final int members;
  final String meetTime;
  final String location;
  final String description;
  final List<String> memberIds;
  final bool isJoined;
  final bool isOwner;
  final String creatorId;

  const StudyGroup({
    required this.id,
    required this.name,
    required this.course,
    required this.members,
    required this.meetTime,
    required this.location,
    this.description = '',
    this.memberIds = const [],
    this.isJoined = false,
    this.isOwner = false,
    this.creatorId = '',
  });

  StudyGroup copyWith({
    String? id,
    String? name,
    String? course,
    int? members,
    String? meetTime,
    String? location,
    String? description,
    List<String>? memberIds,
    bool? isJoined,
    bool? isOwner,
    String? creatorId,
  }) {
    return StudyGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      course: course ?? this.course,
      members: members ?? this.members,
      meetTime: meetTime ?? this.meetTime,
      location: location ?? this.location,
      description: description ?? this.description,
      memberIds: memberIds ?? this.memberIds,
      isJoined: isJoined ?? this.isJoined,
      isOwner: isOwner ?? this.isOwner,
      creatorId: creatorId ?? this.creatorId,
    );
  }

  factory StudyGroup.fromJson(Map<String, dynamic> json) {
    final memberIds = (json['memberIds'] as List?)
            ?.map((member) => member.toString())
            .where((id) => id.isNotEmpty)
            .toList() ??
        const [];
    return StudyGroup(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      course: json['course'] ?? '',
      members: json['members'] ?? memberIds.length,
      meetTime: json['meetTime'] ?? json['meet_time'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      memberIds: memberIds,
      isJoined: json['isJoined'] ?? json['is_joined'] ?? false,
      isOwner: json['isOwner'] ?? json['is_owner'] ?? false,
      creatorId: json['creatorId'] ?? json['creator_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'course': course,
      'members': members,
      'meetTime': meetTime,
      'location': location,
      'description': description,
      'memberIds': memberIds,
      'isJoined': isJoined,
      'isOwner': isOwner,
      'creatorId': creatorId,
    };
  }
}
