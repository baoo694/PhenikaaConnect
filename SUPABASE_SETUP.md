# Phenikaa Connect App - Backend Setup với Supabase

## Tổng quan

Ứng dụng Phenikaa Connect đã được tích hợp với Supabase để cung cấp backend services bao gồm:
- Database PostgreSQL
- Authentication
- Real-time subscriptions
- Storage
- Edge Functions

## Cài đặt Supabase

### 1. Tạo Supabase Project

1. Truy cập [supabase.com](https://supabase.com)
2. Đăng ký/đăng nhập tài khoản
3. Tạo project mới
4. Lưu lại URL và API Key

### 2. Cấu hình ứng dụng

Cập nhật file `lib/config/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  // ...
}
```

### 3. Chạy SQL Scripts

#### Bước 1: Tạo Database Schema
Chạy file `supabase_schema.sql` trong Supabase SQL Editor để tạo:
- Các bảng cơ sở dữ liệu
- Indexes cho performance
- Triggers và functions
- Row Level Security (RLS) policies

#### Bước 2: Tạo Functions và Procedures
Chạy file `supabase_functions.sql` để tạo:
- Functions cho increment/decrement counters
- Triggers tự động cập nhật counters
- Stored procedures

#### Bước 3: Thêm Mock Data
Chạy file `supabase_mock_data.sql` để thêm dữ liệu mẫu:
- Users
- Posts
- Questions
- Study Groups
- Events
- Locations
- Clubs
- Announcements
- Chat rooms và messages

### 4. Cài đặt Dependencies

```bash
flutter pub get
```

## Cấu trúc Database

### Bảng chính:

1. **users** - Thông tin người dùng
2. **posts** - Bài đăng trong cộng đồng
3. **post_likes** - Like bài đăng
4. **comments** - Bình luận bài đăng
5. **questions** - Câu hỏi Q&A
6. **question_replies** - Trả lời câu hỏi
7. **study_groups** - Nhóm học tập
8. **study_group_members** - Thành viên nhóm học
9. **events** - Sự kiện
10. **event_attendees** - Người tham gia sự kiện
11. **locations** - Địa điểm trong trường
12. **clubs** - Câu lạc bộ
13. **club_members** - Thành viên câu lạc bộ
14. **announcements** - Thông báo
15. **chat_rooms** - Phòng chat
16. **chat_room_members** - Thành viên phòng chat
17. **messages** - Tin nhắn

## API Services

### SupabaseService Class

Cung cấp các methods:

#### User Operations:
- `getCurrentUser()` - Lấy thông tin user hiện tại
- `getUsers()` - Lấy danh sách users
- `createUser()` - Tạo user mới
- `updateUser()` - Cập nhật thông tin user

#### Post Operations:
- `getPosts()` - Lấy danh sách bài đăng
- `createPost()` - Tạo bài đăng mới
- `togglePostLike()` - Like/unlike bài đăng

#### Event Operations:
- `getEvents()` - Lấy danh sách sự kiện
- `createEvent()` - Tạo sự kiện mới
- `joinEvent()` - Tham gia sự kiện
- `leaveEvent()` - Rời sự kiện

#### Question Operations:
- `getQuestions()` - Lấy danh sách câu hỏi
- `createQuestion()` - Tạo câu hỏi mới

#### Study Group Operations:
- `getStudyGroups()` - Lấy danh sách nhóm học
- `createStudyGroup()` - Tạo nhóm học mới

#### Authentication:
- `signUp()` - Đăng ký
- `signIn()` - Đăng nhập
- `signOut()` - Đăng xuất

## AppProvider Integration

AppProvider đã được cập nhật để:
- Sử dụng Supabase thay vì mock data
- Quản lý loading states
- Tự động sync dữ liệu với Supabase
- Xử lý authentication

## Tính năng đã implement:

### ✅ CRUD Operations:
- **Posts**: Tạo, đọc, like/unlike
- **Questions**: Tạo, đọc câu hỏi Q&A
- **Study Groups**: Tạo, đọc nhóm học tập
- **Events**: Tạo, đọc, tham gia/rời sự kiện
- **Users**: Đọc, cập nhật thông tin user

### ✅ Authentication:
- Đăng ký tài khoản
- Đăng nhập
- Đăng xuất
- Quản lý session

### ✅ Real-time Features:
- Auto-update counters (likes, comments, attendees)
- Triggers cho database operations

### ✅ Security:
- Row Level Security (RLS)
- Authentication required cho các operations
- Data validation

## Cách sử dụng:

### 1. Khởi tạo ứng dụng:
```dart
// AppProvider sẽ tự động load dữ liệu từ Supabase
final appProvider = Provider.of<AppProvider>(context);
```

### 2. Tạo bài đăng:
```dart
await appProvider.createPost("Nội dung bài đăng");
```

### 3. Like bài đăng:
```dart
await appProvider.togglePostLike(postId);
```

### 4. Tạo câu hỏi:
```dart
await appProvider.createQuestion({
  'course': 'Machine Learning',
  'title': 'Câu hỏi về ML',
  'content': 'Nội dung câu hỏi...',
});
```

### 5. Tham gia sự kiện:
```dart
await appProvider.joinEvent(eventId);
```

## Lưu ý:

1. **Environment Variables**: Cần cập nhật Supabase URL và API Key
2. **Database Schema**: Chạy đúng thứ tự các SQL scripts
3. **RLS Policies**: Có thể cần điều chỉnh policies theo yêu cầu bảo mật
4. **Error Handling**: Tất cả operations đều có error handling
5. **Performance**: Đã thêm indexes và optimizations

## Troubleshooting:

### Lỗi kết nối:
- Kiểm tra Supabase URL và API Key
- Đảm bảo project đang active
- Kiểm tra network connection

### Lỗi authentication:
- Kiểm tra RLS policies
- Đảm bảo user đã đăng nhập
- Kiểm tra permissions

### Lỗi database:
- Kiểm tra schema đã được tạo đúng
- Kiểm tra foreign key constraints
- Kiểm tra data types

## Phát triển tiếp:

1. **Real-time subscriptions** cho live updates
2. **File upload** cho images và documents
3. **Push notifications** cho events và messages
4. **Advanced search** với full-text search
5. **Analytics** và reporting
6. **Admin dashboard** cho quản lý
