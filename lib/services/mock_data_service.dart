import '../models/user.dart';
import '../models/course.dart';
import '../models/post.dart';
import '../models/event.dart';
import '../models/chat.dart';

class MockDataService {
  // User Data
  static const User currentUser = User(
    id: '1',
    name: 'Nguyễn Văn An',
    studentId: '20210123',
    major: 'Khoa học máy tính',
    year: 'Năm 3',
    email: 'nguyenvanan@phenikaa.edu.vn',
    phone: '0123456789',
    interests: ['Lập trình', 'AI', 'Gaming'],
    mutualFriends: 12,
  );

  // Today's Classes
  static const List<ClassSchedule> todayClasses = [
    ClassSchedule(
      id: '1',
      day: 'Monday',
      time: '8:00 - 10:00',
      subject: 'Data Structures',
      room: 'A101',
      instructor: 'Dr. Nguyen',
      color: 'from-blue-500 to-blue-600',
    ),
    ClassSchedule(
      id: '2',
      day: 'Monday',
      time: '14:00 - 16:00',
      subject: 'Calculus II',
      room: 'B205',
      instructor: 'Prof. Tran',
      color: 'from-green-500 to-green-600',
    ),
  ];

  // Full Schedule
  static const List<ClassSchedule> fullSchedule = [
    ClassSchedule(
      id: '1',
      day: 'Monday',
      time: '8:00 - 10:00',
      subject: 'Data Structures',
      room: 'A101',
      instructor: 'Dr. Nguyen',
      color: 'from-blue-500 to-blue-600',
    ),
    ClassSchedule(
      id: '2',
      day: 'Monday',
      time: '14:00 - 16:00',
      subject: 'Calculus II',
      room: 'B205',
      instructor: 'Prof. Tran',
      color: 'from-green-500 to-green-600',
    ),
    ClassSchedule(
      id: '3',
      day: 'Tuesday',
      time: '10:00 - 12:00',
      subject: 'Physics',
      room: 'C301',
      instructor: 'Dr. Le',
      color: 'from-purple-500 to-purple-600',
    ),
    ClassSchedule(
      id: '4',
      day: 'Wednesday',
      time: '8:00 - 10:00',
      subject: 'Data Structures',
      room: 'A101',
      instructor: 'Dr. Nguyen',
      color: 'from-blue-500 to-blue-600',
    ),
    ClassSchedule(
      id: '5',
      day: 'Thursday',
      time: '14:00 - 17:00',
      subject: 'Programming Lab',
      room: 'Lab 3',
      instructor: 'Mr. Pham',
      color: 'from-orange-500 to-orange-600',
    ),
    ClassSchedule(
      id: '6',
      day: 'Friday',
      time: '10:00 - 12:00',
      subject: 'English',
      room: 'D102',
      instructor: 'Ms. Hoang',
      color: 'from-pink-500 to-pink-600',
    ),
  ];

  // Courses
  static const List<Course> courses = [
    Course(
      id: '1',
      name: 'Data Structures',
      code: 'CS201',
      instructor: 'Dr. Nguyen',
      questions: 24,
      members: 156,
      progress: 65,
      color: 'from-blue-500 to-blue-600',
    ),
    Course(
      id: '2',
      name: 'Calculus II',
      code: 'MATH202',
      instructor: 'Prof. Tran',
      questions: 18,
      members: 142,
      progress: 52,
      color: 'from-green-500 to-green-600',
    ),
    Course(
      id: '3',
      name: 'Physics',
      code: 'PHY101',
      instructor: 'Dr. Le',
      questions: 31,
      members: 189,
      progress: 78,
      color: 'from-purple-500 to-purple-600',
    ),
    Course(
      id: '4',
      name: 'Programming Lab',
      code: 'CS203',
      instructor: 'Mr. Pham',
      questions: 12,
      members: 156,
      progress: 45,
      color: 'from-orange-500 to-orange-600',
    ),
  ];

  // Questions
  static const List<Question> questions = [
    Question(
      id: '1',
      course: 'Data Structures',
      title: 'Làm thế nào để implement binary search tree?',
      author: 'Nguyen Van A',
      replies: 5,
      time: '2 giờ trước',
      solved: false,
    ),
    Question(
      id: '2',
      course: 'Calculus II',
      title: 'Ai có thể giải thích về đạo hàm riêng?',
      author: 'Tran Thi B',
      replies: 12,
      time: '5 giờ trước',
      solved: true,
    ),
    Question(
      id: '3',
      course: 'Physics',
      title: 'Câu hỏi về định luật Newton thứ 3',
      author: 'Le Van C',
      replies: 8,
      time: '1 ngày trước',
      solved: false,
    ),
    Question(
      id: '4',
      course: 'Data Structures',
      title: 'Độ phức tạp của thuật toán quicksort?',
      author: 'Pham Thi D',
      replies: 15,
      time: '2 ngày trước',
      solved: true,
    ),
  ];

  // Study Groups
  static const List<StudyGroup> studyGroups = [
    StudyGroup(
      id: '1',
      course: 'Data Structures',
      name: 'Weekend Warriors',
      members: 6,
      meetTime: 'Thứ 7, 2PM',
      location: 'Thư viện',
    ),
    StudyGroup(
      id: '2',
      course: 'Calculus II',
      name: 'Math Masters',
      members: 8,
      meetTime: 'Thứ 5, 5PM',
      location: 'Cafeteria',
    ),
    StudyGroup(
      id: '3',
      course: 'Physics',
      name: 'Physics Pals',
      members: 5,
      meetTime: 'Thứ 4, 6PM',
      location: 'Lab 2',
    ),
    StudyGroup(
      id: '4',
      course: 'Programming',
      name: 'Code Club',
      members: 10,
      meetTime: 'Thứ 3, 4PM',
      location: 'Lab 3',
    ),
  ];

  // Posts
  static const List<Post> posts = [
    Post(
      id: '1',
      author: 'Nguyen Van A',
      major: 'Khoa học máy tính',
      avatar: 'NVA',
      time: '2 giờ trước',
      content: 'Vừa hoàn thành dự án cuối kỳ môn Cấu trúc dữ liệu! Ai hào hứng với buổi thuyết trình ngày mai không? 🎉',
      likes: 24,
      comments: 5,
      shares: 2,
      liked: false,
    ),
    Post(
      id: '2',
      author: 'Tran Thi B',
      major: 'Quản trị kinh doanh',
      avatar: 'TTB',
      time: '4 giờ trước',
      content: 'Đang tìm bạn học cùng để ôn tập môn Kinh tế học. Có ai muốn tham gia nhóm học tập không?',
      likes: 18,
      comments: 12,
      shares: 1,
      liked: true,
    ),
    Post(
      id: '3',
      author: 'Le Van C',
      major: 'Kỹ thuật',
      avatar: 'LVC',
      time: '6 giờ trước',
      content: 'Buổi thuyết trình về năng lượng bền vững hôm nay thật tuyệt! Giáo sư Minh thực sự biết cách làm cho chủ đề phức tạp trở nên thú vị.',
      likes: 31,
      comments: 7,
      shares: 4,
      liked: false,
    ),
    Post(
      id: '4',
      author: 'Pham Thi D',
      major: 'Y khoa',
      avatar: 'PTD',
      time: '1 ngày trước',
      content: 'Phòng tự học mới ở thư viện thật tuyệt vời! Cuối cùng cũng tìm được không gian hoàn hảo cho những buổi học dài 📚',
      likes: 45,
      comments: 15,
      shares: 3,
      liked: true,
    ),
  ];

  // Chats
  static const List<Chat> chats = [
    Chat(
      id: '1',
      name: 'Nhóm CS Study',
      lastMessage: 'Hẹn gặp ở thư viện!',
      time: '10p',
      unread: 3,
      type: ChatType.group,
    ),
    Chat(
      id: '2',
      name: 'Nguyen Van A',
      lastMessage: 'Cảm ơn vì tài liệu!',
      time: '1h',
      unread: 0,
      type: ChatType.direct,
    ),
    Chat(
      id: '3',
      name: 'Team Alpha',
      lastMessage: 'Meeting lúc 3PM ngày mai',
      time: '2h',
      unread: 5,
      type: ChatType.group,
    ),
    Chat(
      id: '4',
      name: 'Tran Thi B',
      lastMessage: 'Bạn làm xong bài tập chưa?',
      time: '3h',
      unread: 1,
      type: ChatType.direct,
    ),
    Chat(
      id: '5',
      name: 'Physics Club',
      lastMessage: 'Ai tham gia workshop không?',
      time: '5h',
      unread: 2,
      type: ChatType.group,
    ),
    Chat(
      id: '6',
      name: 'Le Van C',
      lastMessage: 'Thanks for helping!',
      time: '1d',
      unread: 0,
      type: ChatType.direct,
    ),
  ];

  // Events
  static const List<Event> events = [
    Event(
      id: '1',
      title: 'Workshop AI: Giới thiệu về Machine Learning',
      date: 'Oct 25, 2025',
      time: '14:00 - 16:00',
      location: 'Lab 3',
      organizer: 'CLB Khoa học máy tính',
      attendees: 45,
      category: 'Học thuật',
      image: 'https://images.unsplash.com/photo-1606761568499-6d2451b23c66?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb2xsZWdlJTIwY2xhc3Nyb29tfGVufDF8fHx8MTc2MTAyODI1OXww&ixlib=rb-4.1.0&q=80&w=1080',
    ),
    Event(
      id: '2',
      title: 'Lễ hội mùa thu 2025',
      date: 'Oct 28, 2025',
      time: '10:00 - 18:00',
      location: 'Sân trường chính',
      organizer: 'Đoàn sinh viên',
      attendees: 230,
      category: 'Văn hóa',
      image: 'https://images.unsplash.com/photo-1706885452328-1ddaf64fe0be?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx1bml2ZXJzaXR5JTIwY2FtcHVzJTIwYnVpbGRpbmd8ZW58MXx8fHwxNzYxMDEyMTgwfDA&ixlib=rb-4.1.0&q=80&w=1080',
    ),
    Event(
      id: '3',
      title: 'Ngày hội việc làm 2025',
      date: 'Nov 2, 2025',
      time: '9:00 - 17:00',
      location: 'Trung tâm sinh viên',
      organizer: 'Trung tâm tư vấn nghề nghiệp',
      attendees: 156,
      category: 'Nghề nghiệp',
      image: 'https://images.unsplash.com/photo-1760351065294-b069f6bcadc4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzdHVkZW50cyUyMHN0dWR5aW5nJTIwdG9nZXRoZXJ8ZW58MXx8fHwxNzYwOTMxODU2fDA&ixlib=rb-4.1.0&q=80&w=1080',
    ),
    Event(
      id: '4',
      title: 'Giải bóng rổ Phenikaa Cup',
      date: 'Nov 5, 2025',
      time: '16:00 - 19:00',
      location: 'Sân thể thao',
      organizer: 'Khoa thể thao',
      attendees: 89,
      category: 'Thể thao',
      image: 'https://images.unsplash.com/photo-1706885452328-1ddaf64fe0be?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx1bml2ZXJzaXR5JTIwY2FtcHVzJTIwYnVpbGRpbmd8ZW58MXx8fHwxNzYxMDEyMTgwfDA&ixlib=rb-4.1.0&q=80&w=1080',
    ),
  ];

  // Locations
  static const List<Location> locations = [
    Location(
      id: '1',
      name: 'Thư viện chính',
      type: 'Thư viện',
      building: 'Tòa A',
      floor: 'Tầng 2',
      popular: true,
    ),
    Location(
      id: '2',
      name: 'Cafeteria 1',
      type: 'Ăn uống',
      building: 'Tòa B',
      floor: 'Tầng 1',
      popular: true,
    ),
    Location(
      id: '3',
      name: 'Giảng đường A101',
      type: 'Lớp học',
      building: 'Tòa A',
      floor: 'Tầng 1',
      popular: false,
    ),
    Location(
      id: '4',
      name: 'Phòng Lab 3',
      type: 'Phòng thí nghiệm',
      building: 'Tòa C',
      floor: 'Tầng 3',
      popular: false,
    ),
    Location(
      id: '5',
      name: 'Trung tâm sinh viên',
      type: 'Giải trí',
      building: 'Tòa D',
      floor: 'Tầng trệt',
      popular: true,
    ),
    Location(
      id: '6',
      name: 'Văn phòng hành chính',
      type: 'Hành chính',
      building: 'Tòa A',
      floor: 'Tầng 1',
      popular: false,
    ),
    Location(
      id: '7',
      name: 'Sân thể thao',
      type: 'Thể thao',
      building: 'Khu vực ngoài trời',
      floor: '-',
      popular: true,
    ),
    Location(
      id: '8',
      name: 'Nhà ăn 2',
      type: 'Ăn uống',
      building: 'Tòa C',
      floor: 'Tầng 1',
      popular: false,
    ),
  ];

  // Clubs
  static const List<Club> clubs = [
    Club(
      id: '1',
      name: 'CLB Khoa học máy tính',
      members: 89,
      category: 'Học thuật',
      description: 'Học hỏi và chia sẻ kiến thức về lập trình và công nghệ',
      active: true,
    ),
    Club(
      id: '2',
      name: 'CLB Nhiếp ảnh',
      members: 56,
      category: 'Nghệ thuật',
      description: 'Lưu giữ khoảnh khắc và nâng cao kỹ năng nhiếp ảnh',
      active: true,
    ),
    Club(
      id: '3',
      name: 'Đội tranh biện',
      members: 34,
      category: 'Học thuật',
      description: 'Phát triển tư duy phản biện và kỹ năng diễn thuyết',
      active: false,
    ),
    Club(
      id: '4',
      name: 'CLB Môi trường xanh',
      members: 67,
      category: 'Tình nguyện',
      description: 'Thúc đẩy phát triển bền vững và bảo vệ môi trường',
      active: true,
    ),
    Club(
      id: '5',
      name: 'Câu lạc bộ Âm nhạc',
      members: 45,
      category: 'Nghệ thuật',
      description: 'Chia sẻ đam mê âm nhạc với những người bạn đồng điệu',
      active: true,
    ),
    Club(
      id: '6',
      name: 'CLB Bóng đá',
      members: 78,
      category: 'Thể thao',
      description: 'Tập luyện và thi đấu bóng đá mỗi tuần',
      active: true,
    ),
  ];

  // Announcements
  static const List<Announcement> announcements = [
    Announcement(
      id: '1',
      title: 'Lịch thi giữa kỳ đã được công bố',
      department: 'Phòng Đào tạo',
      date: 'Oct 22, 2025',
      priority: AnnouncementPriority.high,
    ),
    Announcement(
      id: '2',
      title: 'Thư viện mở cửa 24/7 trong kỳ thi',
      department: 'Thư viện',
      date: 'Oct 21, 2025',
      priority: AnnouncementPriority.medium,
    ),
    Announcement(
      id: '3',
      title: 'Bảo trì WiFi - Oct 24',
      department: 'Phòng IT',
      date: 'Oct 20, 2025',
      priority: AnnouncementPriority.medium,
    ),
  ];

  // Carpools
  static const List<Carpool> carpools = [
    Carpool(
      id: '1',
      driver: 'Nguyen Van A',
      from: 'Quận 1',
      to: 'Trường Phenikaa',
      time: '7:30 AM',
      seats: 2,
      days: ['T2', 'T4', 'T6'],
    ),
    Carpool(
      id: '2',
      driver: 'Tran Thi B',
      from: 'Quận 7',
      to: 'Trường Phenikaa',
      time: '8:00 AM',
      seats: 3,
      days: ['Hàng ngày'],
    ),
  ];

  // Lost & Found
  static const List<LostFound> lostFound = [
    LostFound(
      id: '1',
      type: LostFoundType.lost,
      item: 'Ba lô xanh',
      description: 'Thất lạc gần thư viện ngày 20/10',
      location: 'Thư viện chính',
      date: 'Oct 20, 2025',
    ),
    LostFound(
      id: '2',
      type: LostFoundType.found,
      item: 'Thẻ sinh viên',
      description: 'Tìm thấy ở Cafeteria 1',
      location: 'Cafeteria 1',
      date: 'Oct 21, 2025',
    ),
  ];
}
