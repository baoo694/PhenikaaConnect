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
  final DateTime? startTime;
  final DateTime? endTime;

  const ClassSchedule({
    required this.id,
    required this.day,
    required this.time,
    required this.subject,
    required this.room,
    required this.instructor,
    required this.color,
    this.startTime,
    this.endTime,
  });

  factory ClassSchedule.fromJson(Map<String, dynamic> json) {
    DateTime? parseTime(dynamic value) {
      if (value == null) return null;
      final timeString = value.toString();
      if (timeString.isEmpty) return null;
      final parts = timeString.split(':');
      if (parts.length < 2) return null;
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour == null || minute == null) return null;
      return DateTime(1970, 1, 1, hour, minute);
    }

    final start = parseTime(json['start_time']);
    final end = parseTime(json['end_time']);
    final timeRange = json['time'] ??
        (start != null && end != null
            ? '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} - ${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}'
            : '');

    return ClassSchedule(
      id: json['id'] ?? '',
      day: json['day'] ?? json['day_of_week'] ?? '',
      time: timeRange,
      subject: json['subject'] ?? '',
      room: json['room'] ?? '',
      instructor: json['instructor'] ?? '',
      color: json['color'] ?? 'from-blue-500 to-blue-600',
      startTime: start,
      endTime: end,
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
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
    };
  }
}
