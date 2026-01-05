# Phenikaa Connect

Ứng dụng mạng xã hội dành riêng cho sinh viên Đại học Phenikaa - Hệ sinh thái số kết nối cộng đồng sinh viên.

🌐 **Website:** [phenikaa-connect.vercel.app](https://phenikaa-connect.vercel.app)

## 📱 Giới thiệu

Phenikaa Connect là một ứng dụng mạng xã hội được xây dựng đặc biệt cho sinh viên Đại học Phenikaa, cung cấp một nền tảng tích hợp để:

- Kết nối và giao tiếp giữa sinh viên
- Quản lý thông tin học tập và lịch học
- Tham gia các câu lạc bộ và sự kiện
- Nhận thông báo và cập nhật từ trường
- Tương tác xã hội và chia sẻ nội dung

## ✨ Tính năng chính

### 🎓 Học tập
- Xem lịch học và quản lý thời khóa biểu
- Theo dõi các khóa học và môn học
- Nhắc nhở lịch học tự động
- Quản lý thông tin học tập

### 👥 Xã hội
- Tạo và chia sẻ bài viết
- Tương tác với bạn bè (like, comment)
- Xem thông báo và cập nhật
- Quản lý hồ sơ cá nhân

### 🎪 Câu lạc bộ & Sự kiện
- Khám phá các câu lạc bộ trong trường
- Xem chi tiết câu lạc bộ và hoạt động
- Đăng ký và tham gia sự kiện
- Quản lý sự kiện (dành cho admin và club leader)

### 📢 Thông báo
- Nhận thông báo từ trường
- Cập nhật sự kiện
- Tin nhắn mới
- Q&A trả lời
- Tùy chỉnh cài đặt thông báo

### 👨‍💼 Quản trị
- Quản lý sự kiện (Admin)
- Tạo thông báo (Admin)
- Quản lý hoạt động câu lạc bộ (Club Leader)
- Quản lý bài viết câu lạc bộ (Club Leader)

## 🛠️ Công nghệ sử dụng

### Framework & Ngôn ngữ
- **Flutter** - Framework đa nền tảng
- **Dart** - Ngôn ngữ lập trình (SDK ^3.9.2)

### State Management
- **Provider** (^6.1.2) - Quản lý state

### Navigation
- **go_router** (^14.2.7) - Điều hướng và routing

### Backend & Database
- **Supabase** (^2.5.6) - Backend as a Service (BaaS)
  - Authentication
  - Real-time database
  - Storage

### UI Components
- **flutter_svg** (^2.0.10+1) - Hiển thị SVG
- **cached_network_image** (^3.3.1) - Cache hình ảnh
- **shimmer** (^3.0.0) - Loading animation
- **lucide_icons** (^0.257.0) - Icon library

### Networking
- **http** (^1.2.2) - HTTP client
- **dio** (^5.7.0) - Advanced HTTP client

### Local Storage
- **shared_preferences** (^2.3.2) - Lưu trữ dữ liệu local

### Utilities
- **intl** (^0.19.0) - Format date/time
- **uuid** (^4.5.1) - Generate unique IDs
- **file_picker** (^8.0.0) - Chọn file từ thiết bị

### Development Tools
- **flutter_lints** (^5.0.0) - Linting rules

## 📋 Yêu cầu hệ thống

- Flutter SDK >= 3.9.2
- Dart SDK >= 3.9.2
- Android Studio / VS Code với Flutter extension
- iOS: Xcode (cho macOS)
- Git

## 🚀 Cài đặt

### 1. Clone repository

```bash
git clone https://github.com/baoo694/PhenikaaConnect.git
cd PhenikaaConnect
```

### 2. Cài đặt dependencies

```bash
flutter pub get
```

### 3. Cấu hình Supabase

Tạo file `lib/config/supabase_config.dart` và thêm thông tin Supabase của bạn:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}
```

### 4. Chạy ứng dụng

```bash
# Chạy trên thiết bị/emulator mặc định
flutter run

# Chạy trên web
flutter run -d chrome

# Chạy trên Android
flutter run -d android

# Chạy trên iOS (macOS only)
flutter run -d ios
```

## 📁 Cấu trúc dự án

```
PhenikaaConnect/
├── lib/
│   ├── config/              # Cấu hình (Supabase, API)
│   │   └── supabase_config.dart
│   ├── constants/           # Hằng số ứng dụng
│   │   ├── app_constants.dart
│   │   └── app_theme.dart
│   ├── models/              # Data models
│   │   ├── post.dart
│   │   ├── user.dart
│   │   ├── course.dart
│   │   └── event.dart
│   ├── providers/           # State management
│   │   └── app_provider.dart
│   ├── screens/             # UI Screens (40+ screens)
│   │   ├── auth_wrapper.dart
│   │   ├── signup_screen.dart
│   │   ├── social_screen.dart
│   │   ├── academic_screen.dart
│   │   ├── announcements_screen.dart
│   │   ├── admin_event_management_screen.dart
│   │   └── ... (nhiều screens khác)
│   ├── services/            # Business logic
│   │   ├── supabase_service.dart
│   │   ├── admin_service.dart
│   │   ├── club_leader_service.dart
│   │   └── group_reminder_service.dart
│   ├── widgets/             # Reusable widgets
│   │   ├── common_widgets.dart
│   │   └── question_form_sheet.dart
│   └── main.dart            # Entry point
├── android/                  # Android platform code
├── ios/                      # iOS platform code
├── web/                      # Web platform code
├── windows/                  # Windows platform code
├── linux/                    # Linux platform code
├── macos/                    # macOS platform code
├── test/                     # Unit tests
├── pubspec.yaml             # Dependencies & metadata
└── README.md                # Documentation
```

## 🎨 Tính năng UI/UX

- **Dark Mode Support** - Hỗ trợ chế độ tối
- **Responsive Design** - Tối ưu cho nhiều kích thước màn hình
- **Smooth Animations** - Animation mượt mà
- **Loading States** - Shimmer effects khi tải dữ liệu
- **Error Handling** - Xử lý lỗi thân thiện với người dùng

## 🔐 Bảo mật

- Xác thực người dùng qua Supabase Auth
- Bảo mật API keys và credentials
- Quản lý quyền truy cập (Admin, Club Leader, Student)

## 📱 Nền tảng hỗ trợ

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ Linux
- ✅ macOS

## 🤝 Đóng góp

Chúng tôi hoan nghênh mọi đóng góp! Vui lòng:

1. Fork dự án
2. Tạo feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit các thay đổi (`git commit -m 'Add some AmazingFeature'`)
4. Push lên branch (`git push origin feature/AmazingFeature`)
5. Mở Pull Request

## 📄 License

Dự án này là dự án học tập của nhóm N01 - CSE703014, Đại học Phenikaa.

## 👥 Nhóm phát triển

Nhóm N01 - CSE703014

## 📞 Liên hệ

- **Website:** [phenikaa-connect.vercel.app](https://phenikaa-connect.vercel.app)
- **Repository:** [github.com/baoo694/PhenikaaConnect](https://github.com/baoo694/PhenikaaConnect)

## 📚 Tài liệu tham khảo

- [Flutter Documentation](https://flutter.dev/docs)
- [Supabase Documentation](https://supabase.com/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [go_router Package](https://pub.dev/packages/go_router)

---

**Lưu ý:** Đây là dự án học tập. Một số tính năng có thể đang trong quá trình phát triển.

