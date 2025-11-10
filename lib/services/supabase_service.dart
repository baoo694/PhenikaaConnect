import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_models;
import '../models/post.dart';
import '../models/event.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  static final SupabaseClient _client = SupabaseConfig.client;

  // User operations
  static Future<app_models.User?> getCurrentUser() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;
      
      final response = await _client
          .from('users')
          .select()
          .eq('id', user.id)
          .single();
      
      return app_models.User.fromJson(response);
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  static Future<List<app_models.User>> getUsers() async {
    try {
      final response = await _client
          .from('users')
          .select()
          .order('created_at', ascending: false);
      
      return response.map<app_models.User>((json) => app_models.User.fromJson(json)).toList();
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  static Future<app_models.User?> createUser(app_models.User user) async {
    try {
      final response = await _client
          .from('users')
          .insert(user.toJson())
          .select()
          .single();
      
      return app_models.User.fromJson(response);
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  static Future<app_models.User?> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      final response = await _client
          .from('users')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();
      
      return app_models.User.fromJson(response);
    } catch (e) {
      print('Error updating user: $e');
      return null;
    }
  }

  // Test connection
  static Future<bool> testConnection() async {
    try {
      print('Testing Supabase connection...');
      final response = await _client
          .from('users')
          .select('count')
          .limit(1);
      print('Connection test successful: $response');
      return true;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  // Test individual tables
  static Future<void> testTables() async {
    try {
      print('Testing posts table...');
      final postsResponse = await _client
          .from('posts')
          .select('*')
          .limit(5);
      print('Posts table response: $postsResponse');
      print('Posts count: ${postsResponse.length}');
      
      print('Testing events table...');
      final eventsResponse = await _client
          .from('events')
          .select('*')
          .limit(5);
      print('Events table response: $eventsResponse');
      print('Events count: ${eventsResponse.length}');
      
      print('Testing clubs table...');
      final clubsResponse = await _client
          .from('clubs')
          .select('*')
          .limit(5);
      print('Clubs table response: $clubsResponse');
      print('Clubs count: ${clubsResponse.length}');
      
      print('Testing announcements table...');
      final announcementsResponse = await _client
          .from('announcements')
          .select('*')
          .limit(5);
      print('Announcements table response: $announcementsResponse');
      print('Announcements count: ${announcementsResponse.length}');
      
      print('Testing locations table...');
      final locationsResponse = await _client
          .from('locations')
          .select('*')
          .limit(5);
      print('Locations table response: $locationsResponse');
      print('Locations count: ${locationsResponse.length}');
      
      print('Testing users table...');
      final usersResponse = await _client
          .from('users')
          .select('*')
          .limit(5);
      print('Users table response: $usersResponse');
      print('Users count: ${usersResponse.length}');
      
    } catch (e) {
      print('Error testing tables: $e');
    }
  }

  // Post operations
  static Future<List<Post>> getPosts() async {
    try {
      print('Fetching posts from Supabase...');
      final currentUser = _client.auth.currentUser;

      final response = await _client
          .from('posts')
          .select('''
            *,
            users!posts_user_id_fkey(name, student_id, major, avatar_url),
            post_likes!left(user_id)
          ''')
          .order('created_at', ascending: false);

      print('Raw response from Supabase: $response');

      return response.map<Post>((json) {
        final user = json['users'];
        final likesList = (json['post_likes'] as List?) ?? [];
        final isLiked = currentUser == null
            ? false
            : likesList.any((entry) => entry != null && entry['user_id'] == currentUser.id);
        return Post(
          id: json['id'] ?? '',
          author: user?['name'] ?? 'Unknown',
          major: user?['major'] ?? '',
          avatar: user?['avatar_url'] ?? '',
          time: _formatTimeAgo(json['created_at']),
          content: json['content'] ?? '',
          imageBase64: json['image_base64'],
          likes: json['likes_count'] ?? 0,
          comments: json['comments_count'] ?? 0,
          shares: json['shares_count'] ?? 0,
          liked: isLiked,
        );
      }).toList();
    } catch (e) {
      print('Error getting posts: $e');
      return [];
    }
  }

  static Future<Post?> createPost(String content, {String? imageBase64}) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;
      
      final response = await _client
          .from('posts')
          .insert({
            'user_id': user.id,
            'content': content,
            if (imageBase64 != null && imageBase64.isNotEmpty) 'image_base64': imageBase64,
          })
          .select('''
            *,
            users!posts_user_id_fkey(name, student_id, major, avatar_url)
          ''')
          .single();
      
      final userData = response['users'];
      return Post(
        id: response['id'],
        author: userData['name'] ?? '',
        major: userData['major'] ?? '',
        avatar: userData['avatar_url'] ?? '',
        time: _formatTimeAgo(response['created_at']),
        content: response['content'],
        imageBase64: response['image_base64'],
        likes: 0,
        comments: 0,
        shares: 0,
        liked: false,
      );
    } catch (e) {
      print('Error creating post: $e');
      return null;
    }
  }

  static Future<bool> togglePostLike(String postId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;
      
      // Check if already liked
      final existingLike = await _client
          .from('post_likes')
          .select()
          .eq('post_id', postId)
          .eq('user_id', user.id)
          .maybeSingle();
      
      if (existingLike != null) {
        // Unlike
        await _client
            .from('post_likes')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', user.id);
        
        // Decrease likes count
        await _client.rpc('decrement_likes', params: {'post_id': postId});
      } else {
        // Like
        await _client
            .from('post_likes')
            .insert({
              'post_id': postId,
              'user_id': user.id,
            });
        
        // Increase likes count
        await _client.rpc('increment_likes', params: {'post_id': postId});
      }
      
      return true;
    } catch (e) {
      print('Error toggling post like: $e');
      return false;
    }
  }

  // Comment operations
  static Future<bool> createComment(String postId, String content) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      await _client
          .from('comments')
          .insert({
            'post_id': postId,
            'user_id': user.id,
            'content': content,
          });
      return true;
    } catch (e) {
      print('Error creating comment: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getComments(String postId) async {
    try {
      final response = await _client
          .from('comments')
          .select('''
            id, content, created_at,
            users:users!comments_user_id_fkey(name, avatar_url)
          ''')
          .eq('post_id', postId)
          .order('created_at', ascending: true);
      return response;
    } catch (e) {
      print('Error getting comments: $e');
      return [];
    }
  }

  // Club operations
  static Future<List<Map<String, dynamic>>> getClubs() async {
    try {
      print('Fetching clubs from Supabase...');
      final response = await _client
          .from('clubs')
          .select('*')
          .order('created_at', ascending: false);
      
      print('Raw clubs response from Supabase: $response');
      return response;
    } catch (e) {
      print('Error getting clubs: $e');
      return [];
    }
  }

  // Get announcements
  static Future<List<Map<String, dynamic>>> getAnnouncements() async {
    try {
      print('Fetching announcements from Supabase...');
      final response = await _client
          .from('announcements')
          .select('''
            *,
            users!announcements_created_by_fkey(name, student_id)
          ''')
          .order('created_at', ascending: false);
      
      print('Raw announcements response from Supabase: $response');
      return response;
    } catch (e) {
      print('Error getting announcements: $e');
      return [];
    }
  }

  // Get locations
  static Future<List<Map<String, dynamic>>> getLocations() async {
    try {
      print('Fetching locations from Supabase...');
      final response = await _client
          .from('locations')
          .select('*')
          .order('popular', ascending: false)
          .order('name', ascending: true);
      
      print('Raw locations response from Supabase: $response');
      return response;
    } catch (e) {
      print('Error getting locations: $e');
      return [];
    }
  }

  // Event operations
  static Future<List<Event>> getEvents() async {
    try {
      print('Fetching events from Supabase...');
      final response = await _client
          .from('events')
          .select('''
            *,
            users!events_organizer_id_fkey(name),
            event_attendees(user_id)
          ''')
          .order('event_date', ascending: true);
      
      print('Raw events response from Supabase: $response');
      
      return response.map<Event>((json) {
        final organizer = json['users'];
        final attendees = json['event_attendees'] as List;
        
        return Event(
          id: json['id'],
          title: json['title'],
          date: _formatDate(json['event_date']),
          time: _formatTime(json['event_time']),
          location: json['location'],
          organizer: organizer?['name'] ?? '',
          attendees: attendees.length,
          category: json['category'],
          image: json['image_url'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error getting events: $e');
      return [];
    }
  }

  static Future<Event?> createEvent(Map<String, dynamic> eventData) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;
      
      final response = await _client
          .from('events')
          .insert({
            ...eventData,
            'organizer_id': user.id,
          })
          .select('''
            *,
            users!events_organizer_id_fkey(name)
          ''')
          .single();
      
      final organizer = response['users'];
      return Event(
        id: response['id'],
        title: response['title'],
        date: _formatDate(response['event_date']),
        time: _formatTime(response['event_time']),
        location: response['location'],
        organizer: organizer['name'] ?? '',
        attendees: 0,
        category: response['category'],
        image: response['image_url'] ?? '',
      );
    } catch (e) {
      print('Error creating event: $e');
      return null;
    }
  }

  static Future<bool> joinEvent(String eventId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;
      
      await _client
          .from('event_attendees')
          .insert({
            'event_id': eventId,
            'user_id': user.id,
          });
      
      return true;
    } catch (e) {
      print('Error joining event: $e');
      return false;
    }
  }

  static Future<bool> leaveEvent(String eventId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;
      
      await _client
          .from('event_attendees')
          .delete()
          .eq('event_id', eventId)
          .eq('user_id', user.id);
      
      return true;
    } catch (e) {
      print('Error leaving event: $e');
      return false;
    }
  }

  // Club member operations
  static Future<bool> joinClub(String clubId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;
      
      // Check if already a member
      final existingMember = await _client
          .from('club_members')
          .select()
          .eq('club_id', clubId)
          .eq('user_id', user.id)
          .maybeSingle();
      
      if (existingMember != null) {
        return false; // Already a member
      }
      
      await _client
          .from('club_members')
          .insert({
            'club_id': clubId,
            'user_id': user.id,
            'role': 'member',
          });
      
      return true;
    } catch (e) {
      print('Error joining club: $e');
      return false;
    }
  }

  static Future<bool> leaveClub(String clubId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;
      
      await _client
          .from('club_members')
          .delete()
          .eq('club_id', clubId)
          .eq('user_id', user.id);
      
      return true;
    } catch (e) {
      print('Error leaving club: $e');
      return false;
    }
  }

  // Question operations
  static Future<List<Question>> getQuestions() async {
    try {
      final response = await _client
          .from('questions')
          .select('''
            *,
            users!questions_user_id_fkey(name),
            question_replies(id)
          ''')
          .order('created_at', ascending: false);
      
      return response.map<Question>((json) {
        final user = json['users'];
        final replies = json['question_replies'] as List;
        
        return Question(
          id: json['id'],
          course: json['course'],
          title: json['title'],
          author: user['name'] ?? '',
          replies: replies.length,
          time: _formatTimeAgo(json['created_at']),
          solved: json['solved'],
        );
      }).toList();
    } catch (e) {
      print('Error getting questions: $e');
      return [];
    }
  }

  static Future<Question?> createQuestion(Map<String, dynamic> questionData) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;
      
      final response = await _client
          .from('questions')
          .insert({
            ...questionData,
            'user_id': user.id,
          })
          .select('''
            *,
            users!questions_user_id_fkey(name)
          ''')
          .single();
      
      final userData = response['users'];
      return Question(
        id: response['id'],
        course: response['course'],
        title: response['title'],
        author: userData['name'] ?? '',
        replies: 0,
        time: _formatTimeAgo(response['created_at']),
        solved: false,
      );
    } catch (e) {
      print('Error creating question: $e');
      return null;
    }
  }

  // Study group operations
  static Future<List<StudyGroup>> getStudyGroups() async {
    try {
      final response = await _client
          .from('study_groups')
          .select('''
            *,
            users!study_groups_creator_id_fkey(name),
            study_group_members(user_id)
          ''')
          .order('created_at', ascending: false);
      
      return response.map<StudyGroup>((json) {
        final members = json['study_group_members'] as List;
        
        return StudyGroup(
          id: json['id'],
          course: json['course'],
          name: json['name'],
          members: members.length,
          meetTime: json['meet_time'] ?? '',
          location: json['location'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error getting study groups: $e');
      return [];
    }
  }

  static Future<StudyGroup?> createStudyGroup(Map<String, dynamic> groupData) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;
      
      final response = await _client
          .from('study_groups')
          .insert({
            ...groupData,
            'creator_id': user.id,
          })
          .select()
          .single();
      
      return StudyGroup(
        id: response['id'],
        course: response['course'],
        name: response['name'],
        members: 1,
        meetTime: response['meet_time'] ?? '',
        location: response['location'] ?? '',
      );
    } catch (e) {
      print('Error creating study group: $e');
      return null;
    }
  }

  // Authentication
  // Trả về null nếu thành công; trả về thông điệp lỗi tiếng Việt nếu thất bại
  static Future<String?> signUp(String email, String password, Map<String, dynamic> userData) async {
    try {
      // 1) Pre-check duplicates in application table to give friendly error earlier
      final existingEmail = await _client
          .from('users')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      if (existingEmail != null) {
        print('Sign up blocked: email already exists in users table');
        return 'Email này đã được sử dụng. Vui lòng dùng email khác hoặc đăng nhập.';
      }

      if (userData['student_id'] != null && (userData['student_id'] as String).isNotEmpty) {
        final existingStudent = await _client
            .from('users')
            .select('id')
            .eq('student_id', userData['student_id'])
            .maybeSingle();
        if (existingStudent != null) {
          print('Sign up blocked: student_id already exists in users table');
          return 'Mã số sinh viên đã tồn tại. Vui lòng kiểm tra lại.';
        }
      }

      // 2) Create Auth user
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        print('Auth signUp returned null user');
        return 'Không thể tạo tài khoản. Vui lòng thử lại sau.';
      }

      // 3) Insert profile row
      final userId = response.user!.id;
      await _client.from('users').insert({
        'id': userId,
        'email': email,
        'student_id': userData['student_id'] ?? '',
        'name': userData['name'] ?? '',
        'major': userData['major'] ?? '',
        'year': userData['year'] ?? '',
        'phone': userData['phone'] ?? '',
      });
      return null;
    } on AuthException catch (e) {
      // Typical case: User already registered in Auth
      print('AuthException on sign up: ${e.message}');
      if ((e.message).toLowerCase().contains('already registered') ||
          (e.message).toLowerCase().contains('exists')) {
        return 'Email này đã được đăng ký trên hệ thống. Vui lòng đăng nhập hoặc dùng email khác.';
      }
      return 'Không thể đăng ký: ${e.message}';
    } on PostgrestException catch (e) {
      // Handle UNIQUE violations gracefully
      print('PostgrestException on sign up: ${e.message}');
      if ((e.message).toLowerCase().contains('duplicate') ||
          (e.message).toLowerCase().contains('unique')) {
        return 'Thông tin đã tồn tại (email hoặc MSSV). Vui lòng kiểm tra lại.';
      }
      return 'Lỗi dữ liệu: ${e.message}';
    } catch (e) {
      print('Unexpected error signing up: $e');
      return 'Có lỗi xảy ra khi đăng ký. Vui lòng thử lại.';
    }
  }

  static Future<bool> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      return response.user != null;
    } catch (e) {
      print('Error signing in: $e');
      return false;
    }
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Helper methods
  // Password reset: gửi email đặt lại mật khẩu
  static Future<String?> requestPasswordReset(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return null;
    } on AuthException catch (e) {
      return 'Không thể gửi email đặt lại mật khẩu: ${e.message}';
    } catch (e) {
      return 'Có lỗi khi gửi email đặt lại mật khẩu. Vui lòng thử lại.';
    }
  }

  // Đổi mật khẩu (khi đang đăng nhập hoặc sau khi mở link recovery)
  static Future<String?> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
      return null;
    } on AuthException catch (e) {
      return 'Không thể đổi mật khẩu: ${e.message}';
    } catch (e) {
      return 'Có lỗi khi đổi mật khẩu. Vui lòng thử lại.';
    }
  }

  static String _formatTimeAgo(String dateTime) {
    final now = DateTime.now();
    final date = DateTime.parse(dateTime);
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  static String _formatDate(String date) {
    final dateTime = DateTime.parse(date);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  static String _formatTime(String time) {
    return time.substring(0, 5); // HH:MM format
  }
}
