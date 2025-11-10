# Tài liệu đặc tả ứng dụng Phenikaa Connect

## 1. Tổng quan

**Phenikaa Connect** là một ứng dụng di động được phát triển bằng Flutter, được thiết kế để tạo ra một hệ sinh thái số toàn diện cho sinh viên Đại học Phenikaa. Ứng dụng cung cấp các tính năng quản lý học tập, kết nối cộng đồng, và các tiện ích sinh viên trong một giao diện thống nhất và hiện đại.

### 1.1 Thông tin cơ bản
- **Tên ứng dụng**: Phenikaa Connect
- **Mô tả**: "Hệ sinh thái số cho sinh viên"
- **Phiên bản**: 1.0.0+1
- **Nền tảng**: Flutter (Android/iOS)
- **Ngôn ngữ lập trình**: Dart
- **Kiến trúc**: MVVM với Provider pattern
- **Minimum SDK**: Android API 21 (Android 5.0)
- **Target SDK**: Android API 34 (Android 14)
- **Flutter SDK**: ^3.9.2

### 1.2 Mục tiêu
- Tạo ra một nền tảng số thống nhất cho sinh viên Phenikaa
- Cải thiện trải nghiệm học tập và kết nối cộng đồng
- Cung cấp các công cụ quản lý thông tin cá nhân và học tập
- Hỗ trợ tương tác xã hội giữa sinh viên
- Tích hợp các dịch vụ trường học trong một ứng dụng duy nhất

### 1.3 Đối tượng sử dụng
- **Sinh viên đại học**: Người dùng chính của ứng dụng
- **Giảng viên**: Có thể sử dụng một số tính năng như Q&A
- **Quản trị viên**: Quản lý nội dung và cài đặt hệ thống

## 2. Kiến trúc ứng dụng

### 2.1 Cấu trúc thư mục
```
lib/
├── constants/          # Các hằng số và theme
│   ├── app_constants.dart    # Hằng số ứng dụng
│   └── app_theme.dart        # Theme và styling
├── models/            # Các model dữ liệu
│   ├── user.dart             # Model người dùng
│   ├── course.dart           # Model khóa học
│   ├── post.dart             # Model bài đăng
│   ├── event.dart            # Model sự kiện
│   ├── chat.dart             # Model tin nhắn
│   ├── announcement.dart     # Model thông báo
│   ├── carpool.dart          # Model đi chung xe
│   ├── lost_found.dart       # Model đồ thất lạc
│   ├── study_group.dart      # Model nhóm học tập
│   ├── location.dart         # Model địa điểm
│   └── club.dart             # Model câu lạc bộ
├── providers/         # State management
│   └── app_provider.dart     # Provider chính
├── screens/          # Các màn hình chính
│   ├── main_screen.dart      # Màn hình chính với navigation
│   ├── home_screen.dart      # Trang chủ
│   ├── academic_screen.dart  # Học tập
│   ├── social_screen.dart    # Cộng đồng
│   ├── campus_screen.dart    # Đời sống
│   └── profile_screen.dart   # Cá nhân
├── services/         # Các service và API
│   └── mock_data_service.dart # Service dữ liệu mock
├── widgets/          # Các widget tái sử dụng
│   └── common_widgets.dart   # Widget chung
└── main.dart         # Entry point
```

## 5. Dữ liệu và Models

### 5.1 User Model
**Mục đích**: Quản lý thông tin người dùng

```dart
class User {
  final String id;              // Unique identifier
  final String name;            // Họ tên đầy đủ
  final String studentId;       // Mã số sinh viên
  final String major;           // Khoa/ngành học
  final String year;            // Năm học (Năm 1, 2, 3, 4)
  final String email;           // Email sinh viên
  final String phone;           // Số điện thoại
  final String? avatar;         // URL ảnh đại diện
  final List<String> interests; // Sở thích cá nhân
  final int mutualFriends;      // Số bạn chung

  // Constructors
  const User({...});
  factory User.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  User copyWith({...});
}
```

**Data Fields**:
- **id**: UUID string, primary key
- **name**: "Nguyễn Văn An"
- **studentId**: "20210123"
- **major**: "Khoa học máy tính"
- **year**: "Năm 3"
- **email**: "nguyenvanan@phenikaa.edu.vn"
- **phone**: "0123456789"
- **interests**: ["Lập trình", "AI", "Gaming"]
- **mutualFriends**: 12

### 5.2 Course Model
**Mục đích**: Quản lý thông tin khóa học

```dart
class Course {
  final String id;              // Course ID
  final String name;            // Tên môn học
  final String code;            // Mã môn học (CS201)
  final String instructor;      // Giảng viên
  final int progress;           // Tiến độ học tập (0-100)
  final int questions;          // Số câu hỏi Q&A
  final int members;            // Số thành viên
  final String color;           // Màu gradient
  final String description;     // Mô tả môn học

  // Methods
  const Course({...});
  factory Course.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  Course copyWith({...});
}
```

**Data Fields**:
- **id**: "1", "2", "3", "4"
- **name**: "Data Structures", "Calculus II", "Physics"
- **code**: "CS201", "MATH202", "PHY101"
- **instructor**: "Dr. Nguyen", "Prof. Tran", "Dr. Le"
- **progress**: 65, 52, 78 (percentage)
- **questions**: 24, 18, 31
- **members**: 156, 142, 189
- **color**: "from-blue-500 to-blue-600"

### 5.3 Post Model
**Mục đích**: Quản lý bài đăng trong bảng tin

```dart
class Post {
  final String id;              // Post ID
  final String authorId;        // ID tác giả
  final String authorName;      // Tên tác giả
  final String? authorAvatar;   // Avatar tác giả
  final String content;         // Nội dung bài đăng
  final List<String> images;    // Danh sách hình ảnh
  final DateTime createdAt;     // Thời gian tạo
  final int likes;              // Số lượt thích
  final int comments;           // Số bình luận
  final bool liked;             // Đã thích chưa
  final List<String> tags;      // Hashtags

  // Methods
  const Post({...});
  factory Post.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  Post copyWith({...});
}
```

**Data Fields**:
- **id**: UUID string
- **authorId**: "1", "2", "3"
- **authorName**: "Nguyễn Văn An", "Trần Thị B"
- **content**: "Hôm nay học Data Structures rất thú vị..."
- **images**: ["image1.jpg", "image2.jpg"]
- **createdAt**: DateTime.now().subtract(Duration(hours: 2))
- **likes**: 15, 8, 23
- **comments**: 3, 1, 7
- **liked**: false, true, false

### 5.4 Event Model
**Mục đích**: Quản lý sự kiện trường học

```dart
class Event {
  final String id;              // Event ID
  final String title;           // Tên sự kiện
  final String description;     // Mô tả chi tiết
  final DateTime date;          // Ngày giờ diễn ra
  final String location;        // Địa điểm
  final String category;        // Danh mục
  final int attendees;          // Số người tham gia
  final String? image;          // Hình ảnh sự kiện
  final bool isRegistered;      // Đã đăng ký chưa
  final int maxAttendees;       // Số người tối đa

  // Methods
  const Event({...});
  factory Event.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  Event copyWith({...});
}
```

**Data Fields**:
- **id**: "1", "2", "3"
- **title**: "Hội thảo AI", "Cuộc thi lập trình", "Triển lãm nghệ thuật"
- **description**: "Hội thảo về trí tuệ nhân tạo..."
- **date**: DateTime(2024, 10, 25, 14, 0)
- **location**: "Hội trường A", "Phòng Lab 3", "Sảnh chính"
- **category**: "Học thuật", "Thể thao", "Văn hóa"
- **attendees**: 45, 23, 67
- **maxAttendees**: 100, 50, 80

### 5.5 Chat Model
**Mục đích**: Quản lý tin nhắn và cuộc trò chuyện

```dart
class Chat {
  final String id;              // Chat ID
  final String name;            // Tên cuộc trò chuyện
  final ChatType type;          // Loại chat (personal/group)
  final String? lastMessage;    // Tin nhắn cuối
  final DateTime? lastMessageTime; // Thời gian tin nhắn cuối
  final int unreadCount;        // Số tin nhắn chưa đọc
  final String? avatar;         // Avatar cuộc trò chuyện
  final List<String> participants; // Danh sách thành viên
  final bool isOnline;          // Trạng thái online

  // Methods
  const Chat({...});
  factory Chat.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  Chat copyWith({...});
}

enum ChatType { personal, group }
```

### 5.6 StudyGroup Model
**Mục đích**: Quản lý nhóm học tập

```dart
class StudyGroup {
  final String id;              // Group ID
  final String name;            // Tên nhóm
  final String course;          // Môn học liên quan
  final int members;            // Số thành viên
  final String meetTime;        // Thời gian họp
  final String location;        // Địa điểm họp
  final String description;     // Mô tả nhóm
  final List<String> memberIds; // Danh sách ID thành viên
  final bool isJoined;          // Đã tham gia chưa

  // Methods
  const StudyGroup({...});
  factory StudyGroup.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  StudyGroup copyWith({...});
}
```

### 5.7 Club Model
**Mục đích**: Quản lý câu lạc bộ và tổ chức sinh viên

```dart
class Club {
  final String id;              // Club ID
  final String name;            // Tên CLB
  final String category;        // Danh mục (Học thuật, Nghệ thuật, Thể thao)
  final String description;     // Mô tả CLB
  final int members;            // Số thành viên
  final String? image;          // Hình ảnh CLB
  final String status;          // Trạng thái (Hoạt động, Tạm dừng)
  final List<String> activities; // Các hoạt động
  final bool isJoined;          // Đã tham gia chưa

  // Methods
  const Club({...});
  factory Club.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  Club copyWith({...});
}
```

### 5.8 Announcement Model
**Mục đích**: Quản lý thông báo từ trường

```dart
class Announcement {
  final String id;              // Announcement ID
  final String title;           // Tiêu đề thông báo
  final String content;         // Nội dung thông báo
  final AnnouncementPriority priority; // Mức độ ưu tiên
  final DateTime createdAt;     // Thời gian đăng
  final String author;          // Người đăng
  final List<String> tags;      // Tags liên quan
  final bool isRead;            // Đã đọc chưa

  // Methods
  const Announcement({...});
  factory Announcement.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  Announcement copyWith({...});
}

enum AnnouncementPriority { high, medium, low }
```

### 5.9 Carpool Model
**Mục đích**: Quản lý chuyến đi chung xe

```dart
class Carpool {
  final String id;              // Carpool ID
  final String from;            // Điểm đi
  final String to;              // Điểm đến
  final DateTime departureTime; // Thời gian khởi hành
  final int availableSeats;     // Số chỗ trống
  final double price;           // Giá vé
  final String driverName;      // Tên tài xế
  final double driverRating;    // Đánh giá tài xế
  final String? notes;          // Ghi chú
  final List<String> days;      // Các ngày trong tuần

  // Methods
  const Carpool({...});
  factory Carpool.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  Carpool copyWith({...});
}
```

### 5.10 LostFound Model
**Mục đích**: Quản lý đồ thất lạc/tìm thấy

```dart
class LostFound {
  final String id;              // Item ID
  final String title;           // Tên đồ vật
  final String description;     // Mô tả chi tiết
  final LostFoundType type;     // Loại (Lost/Found)
  final String location;        // Địa điểm
  final DateTime date;          // Ngày thất lạc/tìm thấy
  final String contact;         // Thông tin liên hệ
  final String? image;          // Hình ảnh đồ vật
  final bool isResolved;        // Đã giải quyết chưa

  // Methods
  const LostFound({...});
  factory LostFound.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  LostFound copyWith({...});
}

enum LostFoundType { lost, found }
```

## 6. State Management

### 6.1 AppProvider Architecture
**Mục đích**: Quản lý state toàn cục của ứng dụng

```dart
class AppProvider extends ChangeNotifier {
  // State Variables
  User _currentUser = MockDataService.currentUser;
  List<Post> _posts = List.from(MockDataService.posts);
  int _selectedTabIndex = 0;
  ThemeMode _themeMode = ThemeMode.light;
  List<Map<String, dynamic>> _notificationSettings = 
      List.from(AppConstants.defaultNotificationSettings);

  // Getters
  User get currentUser => _currentUser;
  List<Post> get posts => _posts;
  int get selectedTabIndex => _selectedTabIndex;
  ThemeMode get themeMode => _themeMode;
  List<Map<String, dynamic>> get notificationSettings => _notificationSettings;

  // Methods
  void setSelectedTab(int index) { ... }
  void toggleTheme() { ... }
  void togglePostLike(String postId) { ... }
  void toggleNotification(int settingId) { ... }
  void updateUser(User user) { ... }
  void addPost(Post post) { ... }
}
```

