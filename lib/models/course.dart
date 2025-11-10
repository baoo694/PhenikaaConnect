class Course {
  final String id;
  final String name;
  final String code;
  final String instructor;
  final int questions;
  final int members;
  final int progress;
  final String color;

  const Course({
    required this.id,
    required this.name,
    required this.code,
    required this.instructor,
    required this.questions,
    required this.members,
    required this.progress,
    required this.color,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      instructor: json['instructor'] ?? '',
      questions: json['questions'] ?? 0,
      members: json['members'] ?? 0,
      progress: json['progress'] ?? 0,
      color: json['color'] ?? 'from-blue-500 to-blue-600',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'instructor': instructor,
      'questions': questions,
      'members': members,
      'progress': progress,
      'color': color,
    };
  }
}

class ClassSchedule {
  final String id;
  final String day;
  final String time;
  final String subject;
  final String room;
  final String instructor;
  final String color;

  const ClassSchedule({
    required this.id,
    required this.day,
    required this.time,
    required this.subject,
    required this.room,
    required this.instructor,
    required this.color,
  });

  factory ClassSchedule.fromJson(Map<String, dynamic> json) {
    return ClassSchedule(
      id: json['id'] ?? '',
      day: json['day'] ?? '',
      time: json['time'] ?? '',
      subject: json['subject'] ?? '',
      room: json['room'] ?? '',
      instructor: json['instructor'] ?? '',
      color: json['color'] ?? 'from-blue-500 to-blue-600',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day,
      'time': time,
      'subject': subject,
      'room': room,
      'instructor': instructor,
      'color': color,
    };
  }
}
