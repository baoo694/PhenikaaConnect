class Post {
  final String id;
  final String author;
  final String major;
  final String avatar;
  final String time;
  final String content;
  final String? imageBase64;
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
    this.imageBase64,
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
      imageBase64: json['image_base64'],
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
      'image_base64': imageBase64,
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
    String? imageBase64,
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
      imageBase64: imageBase64 ?? this.imageBase64,
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

  const Question({
    required this.id,
    required this.course,
    required this.title,
    required this.author,
    required this.replies,
    required this.time,
    required this.solved,
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
    };
  }
}

class StudyGroup {
  final String id;
  final String course;
  final String name;
  final int members;
  final String meetTime;
  final String location;

  const StudyGroup({
    required this.id,
    required this.course,
    required this.name,
    required this.members,
    required this.meetTime,
    required this.location,
  });

  factory StudyGroup.fromJson(Map<String, dynamic> json) {
    return StudyGroup(
      id: json['id'] ?? '',
      course: json['course'] ?? '',
      name: json['name'] ?? '',
      members: json['members'] ?? 0,
      meetTime: json['meetTime'] ?? '',
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course': course,
      'name': name,
      'members': members,
      'meetTime': meetTime,
      'location': location,
    };
  }
}
