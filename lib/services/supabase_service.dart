import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/user.dart' as app_models;
import '../models/post.dart';
import '../models/event.dart';
import '../models/course.dart';
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

      print('Testing class schedules table...');
      final classSchedulesResponse = await _client
          .from('class_schedules')
          .select('*')
          .limit(5);
      print('Class schedules response: $classSchedulesResponse');
      print('Class schedules count: ${classSchedulesResponse.length}');

      print('Testing courses table...');
      final coursesResponse = await _client
          .from('courses')
          .select('*')
          .limit(5);
      print('Courses response: $coursesResponse');
      print('Courses count: ${coursesResponse.length}');
      
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
          imageUrl: json['image_url'],
          likes: json['likes_count'] ?? 0,
          comments: json['comments_count'] ?? 0,
          shares: json['shares_count'] ?? 0,
          liked: isLiked,
          userId: json['user_id'],
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
      String? imageUrl;

      // Upload image to Supabase Storage if provided (expects Base64 without data URL prefix)
      if (imageBase64 != null && imageBase64.isNotEmpty) {
        try {
          // Strip common data URL prefixes if present
          final cleaned = imageBase64.contains(',')
              ? imageBase64.split(',').last
              : imageBase64;
          final bytes = base64Decode(cleaned);
          final uuid = const Uuid().v4();
          final filePath = '${user.id}/$uuid.png';
          const bucket = 'post_images';
          
          await _client.storage
              .from(bucket)
              .uploadBinary(
                filePath,
                bytes,
                fileOptions: const FileOptions(
                  contentType: 'image/png',
                  upsert: false,
                ),
              );
          final publicUrl = _client.storage.from(bucket).getPublicUrl(filePath);
          imageUrl = publicUrl;
        } catch (e) {
          print('Image upload failed, proceeding without image: $e');
          imageUrl = null;
        }
      }

      final response = await _client
          .from('posts')
          .insert({
            'user_id': user.id,
            'content': content,
            if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
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
        imageUrl: imageUrl,
        likes: 0,
        comments: 0,
        shares: 0,
        liked: false,
        userId: response['user_id'],
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

  static Future<Map<String, dynamic>?> updatePost(String postId, String content, {String? imageBase64, bool removeImage = false}) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      // Check if user owns the post
      final post = await _client
          .from('posts')
          .select('user_id, image_url')
          .eq('id', postId)
          .single();

      if (post['user_id'] != user.id) {
        return null; // Not the owner
      }

      String? imageUrl;
      // Upload new image if provided
      if (imageBase64 != null && imageBase64.isNotEmpty) {
        try {
          // Delete old image if exists
          if (post['image_url'] != null && post['image_url'].toString().isNotEmpty) {
            try {
              final oldImageUrl = post['image_url'].toString();
              final uri = Uri.parse(oldImageUrl);
              final pathParts = uri.pathSegments;
              if (pathParts.length >= 3) {
                final bucket = pathParts[pathParts.length - 3];
                final filePath = pathParts.sublist(pathParts.length - 2).join('/');
                await _client.storage.from(bucket).remove([filePath]);
              }
            } catch (e) {
              print('Error deleting old image: $e');
            }
          }

          final cleaned = imageBase64.contains(',')
              ? imageBase64.split(',').last
              : imageBase64;
          final bytes = base64Decode(cleaned);
          final uuid = const Uuid().v4();
          final filePath = '${user.id}/$uuid.png';
          const bucket = 'post_images';
          
          await _client.storage
              .from(bucket)
              .uploadBinary(
                filePath,
                bytes,
                fileOptions: const FileOptions(
                  contentType: 'image/png',
                  upsert: false,
                ),
              );
          final publicUrl = _client.storage.from(bucket).getPublicUrl(filePath);
          imageUrl = publicUrl;
        } catch (e) {
          print('Image upload failed: $e');
        }
      }

      // Update post
      final updateData = <String, dynamic>{
        'content': content,
      };
      String? finalImageUrl;
      if (removeImage) {
        // Delete image from storage if exists
        if (post['image_url'] != null && post['image_url'].toString().isNotEmpty) {
          try {
            final oldImageUrl = post['image_url'].toString();
            final uri = Uri.parse(oldImageUrl);
            final pathParts = uri.pathSegments;
            if (pathParts.length >= 3) {
              final bucket = pathParts[pathParts.length - 3];
              final filePath = pathParts.sublist(pathParts.length - 2).join('/');
              await _client.storage.from(bucket).remove([filePath]);
            }
          } catch (e) {
            print('Error deleting image: $e');
          }
        }
        updateData['image_url'] = null;
        finalImageUrl = null;
      } else if (imageUrl != null && imageUrl.isNotEmpty) {
        updateData['image_url'] = imageUrl;
        finalImageUrl = imageUrl;
      } else {
        // Image unchanged, keep existing URL
        finalImageUrl = post['image_url'];
      }

      await _client
          .from('posts')
          .update(updateData)
          .eq('id', postId)
          .eq('user_id', user.id);

      return {
        'success': true,
        'content': content,
        'imageUrl': finalImageUrl,
      };
    } catch (e) {
      print('Error updating post: $e');
      return null;
    }
  }

  static Future<bool> deletePost(String postId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      // Check if user owns the post
      final post = await _client
          .from('posts')
          .select('user_id, image_url')
          .eq('id', postId)
          .single();

      if (post['user_id'] != user.id) {
        return false; // Not the owner
      }

      // Delete image from storage if exists
      if (post['image_url'] != null && post['image_url'].toString().isNotEmpty) {
        try {
          final imageUrl = post['image_url'].toString();
          // Extract file path from URL
          final uri = Uri.parse(imageUrl);
          final pathParts = uri.pathSegments;
          if (pathParts.length >= 3) {
            final bucket = pathParts[pathParts.length - 3];
            final filePath = pathParts.sublist(pathParts.length - 2).join('/');
            await _client.storage.from(bucket).remove([filePath]);
          }
        } catch (e) {
          print('Error deleting image: $e');
          // Continue with post deletion even if image deletion fails
        }
      }

      // Delete post (cascade will delete likes and comments)
      await _client
          .from('posts')
          .delete()
          .eq('id', postId)
          .eq('user_id', user.id);

      return true;
    } catch (e) {
      print('Error deleting post: $e');
      return false;
    }
  }

  // Comment operations
  static Future<bool> createComment(String postId, String content, {String? parentId}) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      await _client
          .from('comments')
          .insert({
            'post_id': postId,
            'user_id': user.id,
            'content': content,
            if (parentId != null) 'parent_id': parentId,
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
            id, content, created_at, parent_id,
            users:users!comments_user_id_fkey(name, avatar_url)
          ''')
          .eq('post_id', postId)
          .order('created_at', ascending: true);
      
      // Separate top-level comments and replies
      final topLevelComments = <Map<String, dynamic>>[];
      final repliesMap = <String, List<Map<String, dynamic>>>{};
      
      for (var comment in response) {
        final parentId = comment['parent_id'];
        if (parentId == null) {
          topLevelComments.add(comment);
        } else {
          final parentIdStr = parentId.toString();
          if (!repliesMap.containsKey(parentIdStr)) {
            repliesMap[parentIdStr] = [];
          }
          repliesMap[parentIdStr]!.add(comment);
        }
      }
      
      // Attach replies to their parent comments
      for (var comment in topLevelComments) {
        final commentId = comment['id'].toString();
        comment['replies'] = repliesMap[commentId] ?? [];
      }
      
      return topLevelComments;
    } catch (e) {
      print('Error getting comments: $e');
      return [];
    }
  }

  // Club operations
  static Future<List<Map<String, dynamic>>> getClubs() async {
    try {
      print('Fetching clubs from Supabase...');
      final user = _client.auth.currentUser;
      final userId = user?.id;
      
      final response = await _client
          .from('clubs')
          .select('''
            *,
            club_members(user_id)
          ''')
          .order('created_at', ascending: false);
      
      print('Raw clubs response from Supabase: $response');
      
      // Add isJoined field to each club
      return response.map<Map<String, dynamic>>((club) {
        final members = club['club_members'] as List? ?? [];
        final isJoined = userId != null && members.any((m) => m['user_id'] == userId);
        final membersCount = members.length;
        
        return {
          ...club,
          'isJoined': isJoined,
          'members_count': membersCount,
        };
      }).toList();
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

  static Future<List<Course>> getCourses({String? userId}) async {
    try {
      final effectiveUserId = userId ?? _client.auth.currentUser?.id;
      if (effectiveUserId == null) {
        print('Cannot load courses without user id');
        return [];
      }

      print('Fetching courses from Supabase...');
      final response = await _client
          .from('courses')
          .select('*')
          .eq('user_id', effectiveUserId)
          .order('name', ascending: true);

      return response.map<Course>((json) => Course.fromJson(json)).toList();
    } catch (e) {
      print('Error getting courses: $e');
      return [];
    }
  }

  static Future<List<ClassSchedule>> getClassSchedules({String? userId}) async {
    try {
      final effectiveUserId = userId ?? _client.auth.currentUser?.id;
      if (effectiveUserId == null) {
        print('Cannot load class schedules without a user id');
        return [];
      }

      final response = await _client
          .from('class_schedules')
          .select('*')
          .eq('user_id', effectiveUserId)
          .order('day_of_week', ascending: true)
          .order('start_time', ascending: true);

      return response.map<ClassSchedule>((json) {
        final startTime = _parseTimeOfDay(json['start_time']);
        final endTime = _parseTimeOfDay(json['end_time']);
        return ClassSchedule(
          id: json['id']?.toString() ?? '',
          day: (json['day_of_week'] ?? '').toString(),
          time: _formatScheduleRange(startTime, endTime),
          subject: (json['subject'] ?? '').toString(),
          room: (json['room'] ?? '').toString(),
          instructor: (json['instructor'] ?? '').toString(),
          color: (json['color'] ?? 'from-blue-500 to-blue-600').toString(),
          startTime: startTime,
          endTime: endTime,
        );
      }).toList();
    } catch (e) {
      print('Error getting class schedules: $e');
      return [];
    }
  }

  // Event operations
  static Future<List<Event>> getEvents() async {
    try {
      print('Fetching events from Supabase...');
      final user = _client.auth.currentUser;
      final userId = user?.id;
      
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
        final isJoined = userId != null && attendees.any((a) => a['user_id'] == userId);
        
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
          isJoined: isJoined,
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
          content: json['content'] ?? '',
          userId: json['user_id'],
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
        content: response['content'] ?? '',
        userId: response['user_id'],
      );
    } catch (e) {
      print('Error creating question: $e');
      return null;
    }
  }

  static Future<bool> updateQuestion(
      String questionId, Map<String, dynamic> updates) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      final response = await _client
          .from('questions')
          .update({
            ...updates,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', questionId)
          .eq('user_id', user.id)
          .select()
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error updating question: $e');
      return false;
    }
  }

  static Future<bool> deleteQuestion(String questionId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      final response = await _client
          .from('questions')
          .delete()
          .eq('id', questionId)
          .eq('user_id', user.id)
          .select()
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error deleting question: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getQuestionReplies(String questionId) async {
    try {
      final response = await _client
          .from('question_replies')
          .select('''
            id, content, created_at, is_solution, user_id,
            users!question_replies_user_id_fkey(name, avatar_url)
          ''')
          .eq('question_id', questionId)
          .order('created_at', ascending: true);
      return response;
    } catch (e) {
      print('Error getting question replies: $e');
      return [];
    }
  }

  static Future<bool> createQuestionReply(String questionId, String content) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      await _client.from('question_replies').insert({
        'question_id': questionId,
        'user_id': user.id,
        'content': content,
      });

      return true;
    } catch (e) {
      print('Error creating question reply: $e');
      return false;
    }
  }

  static Future<bool> markQuestionSolution(String questionId, String replyId) async {
    try {
      // Reset previous solutions
      await _client
          .from('question_replies')
          .update({'is_solution': false})
          .eq('question_id', questionId);

      // Mark selected reply
      await _client
          .from('question_replies')
          .update({'is_solution': true})
          .eq('id', replyId);

      // Update question solved status
      await _client
          .from('questions')
          .update({'solved': true})
          .eq('id', questionId);

      return true;
    } catch (e) {
      print('Error marking question solution: $e');
      return false;
    }
  }

  // Study group operations
  static Future<List<StudyGroup>> getStudyGroups() async {
    try {
      final currentUser = _client.auth.currentUser;
      final response = await _client
          .from('study_groups')
          .select('''
            *,
            study_group_members (user_id)
          ''')
          .order('created_at', ascending: false);

      return response.map<StudyGroup>((json) {
        final members = (json['study_group_members'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .toList() ??
            [];
        final memberIds = members
            .map((member) => (member['user_id'] ?? '').toString())
            .where((id) => id.isNotEmpty)
            .toList();
        final isJoined =
            currentUser != null && memberIds.contains(currentUser.id);
        final isOwner =
            currentUser != null && json['creator_id'] == currentUser.id;

        return StudyGroup(
          id: json['id'] ?? '',
          name: json['name'] ?? '',
          course: json['course'] ?? '',
          members: memberIds.length,
          maxMembers: json['max_members'] ?? 10,
          meetTime: (json['meet_time'] ?? '').toString(),
          location: json['location'] ?? '',
          description: json['description'] ?? '',
          memberIds: memberIds,
          isJoined: isJoined,
          isOwner: isOwner,
          creatorId: (json['creator_id'] ?? '').toString(),
        );
      }).toList();
    } catch (e) {
      print('Error getting study groups: $e');
      return [];
    }
  }

  static Future<StudyGroup?> createStudyGroup(
      Map<String, dynamic> groupData) async {
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

      await _client.from('study_group_members').insert({
        'group_id': response['id'],
        'user_id': user.id,
      });

      return StudyGroup(
        id: response['id'],
        name: response['name'] ?? '',
        course: response['course'] ?? '',
        members: 1,
        maxMembers: response['max_members'] ?? 10,
        meetTime: (response['meet_time'] ?? '').toString(),
        location: response['location'] ?? '',
        description: response['description'] ?? '',
        memberIds: [user.id],
        isJoined: true,
        isOwner: true,
        creatorId: user.id,
      );
    } catch (e) {
      print('Error creating study group: $e');
      return null;
    }
  }

  static Future<bool> joinStudyGroup(String groupId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      await _client.from('study_group_members').insert({
        'group_id': groupId,
        'user_id': user.id,
      });
      return true;
    } on PostgrestException catch (e) {
      if (e.message.toLowerCase().contains('duplicate')) {
        return true;
      }
      print('Error joining study group: $e');
      return false;
    } catch (e) {
      print('Error joining study group: $e');
      return false;
    }
  }

  static Future<bool> leaveStudyGroup(String groupId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      await _client
          .from('study_group_members')
          .delete()
          .eq('group_id', groupId)
          .eq('user_id', user.id);
      return true;
    } catch (e) {
      print('Error leaving study group: $e');
      return false;
    }
  }

  static Future<bool> updateStudyGroup(
      String groupId, Map<String, dynamic> updates) async {
    try {
      await _client.from('study_groups').update(updates).eq('id', groupId);
      return true;
    } catch (e) {
      print('Error updating study group: $e');
      return false;
    }
  }

  static Future<bool> deleteStudyGroup(String groupId) async {
    try {
      await _client.from('study_groups').delete().eq('id', groupId);
      return true;
    } catch (e) {
      print('Error deleting study group: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
    try {
      final response = await _client
          .from('study_group_members')
          .select('''
            user_id,
            joined_at,
            users!study_group_members_user_id_fkey(
              name,
              major,
              year,
              student_id
            )
          ''')
          .eq('group_id', groupId)
          .order('joined_at', ascending: true);

      return response.map<Map<String, dynamic>>((member) {
        final user = member['users'];
        return {
          'user_id': member['user_id'],
          'joined_at': member['joined_at'],
          'name': user?['name'] ?? 'Unknown',
          'major': user?['major'] ?? '',
          'year': user?['year'] ?? '',
          'student_id': user?['student_id'] ?? '',
        };
      }).toList();
    } catch (e) {
      print('Error getting group members: $e');
      return [];
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

  static DateTime? _parseTimeOfDay(dynamic raw) {
    if (raw == null) return null;
    final timeString = raw.toString();
    if (timeString.isEmpty) return null;
    final parts = timeString.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return DateTime(1970, 1, 1, hour, minute);
  }

  static String? _formatHourMinute(DateTime? time) {
    if (time == null) return null;
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  static String _formatScheduleRange(DateTime? start, DateTime? end) {
    final startText = _formatHourMinute(start);
    final endText = _formatHourMinute(end);
    if (startText != null && endText != null) {
      return '$startText - $endText';
    }
    return startText ?? endText ?? '';
  }
}
