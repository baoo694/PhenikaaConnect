class Event {
  final String id;
  final String title;
  final String date;
  final String time;
  final String location;
  final String organizer;
  final int attendees;
  final String category;
  final String image;
  final bool isJoined;

  const Event({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.organizer,
    required this.attendees,
    required this.category,
    required this.image,
    this.isJoined = false,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      location: json['location'] ?? '',
      organizer: json['organizer'] ?? '',
      attendees: json['attendees'] ?? 0,
      category: json['category'] ?? '',
      image: json['image'] ?? '',
      isJoined: json['isJoined'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'time': time,
      'location': location,
      'organizer': organizer,
      'attendees': attendees,
      'category': category,
      'image': image,
      'isJoined': isJoined,
    };
  }

  Event copyWith({
    String? id,
    String? title,
    String? date,
    String? time,
    String? location,
    String? organizer,
    int? attendees,
    String? category,
    String? image,
    bool? isJoined,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      organizer: organizer ?? this.organizer,
      attendees: attendees ?? this.attendees,
      category: category ?? this.category,
      image: image ?? this.image,
      isJoined: isJoined ?? this.isJoined,
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

  const Club({
    required this.id,
    required this.name,
    required this.members,
    required this.category,
    required this.description,
    required this.active,
    this.isJoined = false,
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      members: json['members'] ?? 0,
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      active: json['active'] ?? false,
      isJoined: json['isJoined'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'members': members,
      'category': category,
      'description': description,
      'active': active,
      'isJoined': isJoined,
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
  }) {
    return Club(
      id: id ?? this.id,
      name: name ?? this.name,
      members: members ?? this.members,
      category: category ?? this.category,
      description: description ?? this.description,
      active: active ?? this.active,
      isJoined: isJoined ?? this.isJoined,
    );
  }
}
