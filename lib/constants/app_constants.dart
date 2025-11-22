class AppConstants {
  // App Info
  static const String appName = 'Phenikaa Connect';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Hệ sinh thái số cho sinh viên';

  // API Endpoints
  static const String baseUrl = 'https://api.phenikaa.edu.vn';
  static const String apiVersion = '/v1';

  // Storage Keys
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String notificationsKey = 'notifications_settings';

  // Colors
  static const String primaryGradient = 'from-blue-600 via-purple-600 to-pink-600';
  static const String secondaryGradient = 'from-blue-500 to-purple-500';

  // Default User Data
  static const Map<String, dynamic> defaultUser = {
    'id': '1',
    'name': 'Nguyễn Văn An',
    'studentId': '20210123',
    'major': 'Khoa học máy tính',
    'year': 'Năm 3',
    'email': 'nguyenvanan@phenikaa.edu.vn',
    'phone': '0123456789',
    'mutualFriends': 12,
  };

  // Days of Week
  static const List<String> daysOfWeek = [
    'Monday',
    'Tuesday', 
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> daysOfWeekVN = [
    'Thứ 2',
    'Thứ 3',
    'Thứ 4', 
    'Thứ 5',
    'Thứ 6',
    'Thứ 7',
    'Chủ nhật',
  ];

  // Event Categories
  static const List<String> eventCategories = [
    'Tất cả',
    'Học thuật',
    'Văn hóa',
    'Thể thao',
    'Nghề nghiệp',
  ];

  // Club Categories
  static const List<String> clubCategories = [
    'Tất cả',
    'Học thuật',
    'Nghệ thuật',
    'Thể thao',
    'Tình nguyện',
  ];

  // Notification Settings
  static const List<Map<String, dynamic>> defaultNotificationSettings = [
    {'id': 1, 'label': 'Thông báo từ trường', 'enabled': true},
    {'id': 2, 'label': 'Tin nhắn mới', 'enabled': true},
    {'id': 3, 'label': 'Cập nhật sự kiện', 'enabled': true},
    {'id': 4, 'label': 'Q&A trả lời', 'enabled': false},
    {'id': 5, 'label': 'Nhắc nhở lịch học', 'enabled': true},
  ];
}
