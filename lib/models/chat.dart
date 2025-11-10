class Chat {
  final String id;
  final String name;
  final String lastMessage;
  final String time;
  final int unread;
  final ChatType type;

  const Chat({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unread,
    required this.type,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      lastMessage: json['lastMessage'] ?? '',
      time: json['time'] ?? '',
      unread: json['unread'] ?? 0,
      type: ChatType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ChatType.direct,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastMessage': lastMessage,
      'time': time,
      'unread': unread,
      'type': type.name,
    };
  }
}

enum ChatType {
  direct,
  group,
}

class Announcement {
  final String id;
  final String title;
  final String department;
  final String date;
  final AnnouncementPriority priority;

  const Announcement({
    required this.id,
    required this.title,
    required this.department,
    required this.date,
    required this.priority,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      department: json['department'] ?? '',
      date: json['date'] ?? '',
      priority: AnnouncementPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => AnnouncementPriority.medium,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'department': department,
      'date': date,
      'priority': priority.name,
    };
  }
}

enum AnnouncementPriority {
  high,
  medium,
  low,
}

class Carpool {
  final String id;
  final String driver;
  final String from;
  final String to;
  final String time;
  final int seats;
  final List<String> days;

  const Carpool({
    required this.id,
    required this.driver,
    required this.from,
    required this.to,
    required this.time,
    required this.seats,
    required this.days,
  });

  factory Carpool.fromJson(Map<String, dynamic> json) {
    return Carpool(
      id: json['id'] ?? '',
      driver: json['driver'] ?? '',
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      time: json['time'] ?? '',
      seats: json['seats'] ?? 0,
      days: List<String>.from(json['days'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver': driver,
      'from': from,
      'to': to,
      'time': time,
      'seats': seats,
      'days': days,
    };
  }
}

class LostFound {
  final String id;
  final LostFoundType type;
  final String item;
  final String description;
  final String location;
  final String date;

  const LostFound({
    required this.id,
    required this.type,
    required this.item,
    required this.description,
    required this.location,
    required this.date,
  });

  factory LostFound.fromJson(Map<String, dynamic> json) {
    return LostFound(
      id: json['id'] ?? '',
      type: LostFoundType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => LostFoundType.lost,
      ),
      item: json['item'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'item': item,
      'description': description,
      'location': location,
      'date': date,
    };
  }
}

enum LostFoundType {
  lost,
  found,
}
