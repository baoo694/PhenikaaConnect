import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../config/supabase_config.dart';
import '../models/event.dart';

class ClubLeaderService {
  static final SupabaseClient _client = SupabaseConfig.client;

  static Future<Club?> fetchOwnClub({required String userId}) async {
    final response = await _client
        .from('clubs')
        .select('*')
        .eq('leader_id', userId)
        .maybeSingle();
    if (response == null) return null;
    return Club.fromJson(response);
  }

  static Future<List<ClubMember>> fetchMembers(String clubId, {String? status}) async {
    var query = _client
        .from('club_members')
        .select('''
          *,
          users!club_members_user_id_fkey(id, name, student_id, major, year, email, avatar_url)
        ''')
        .eq('club_id', clubId);
    if (status != null) {
      query = query.eq('status', status);
    }
    final response = await query.order('joined_at', ascending: true);
    return response.map<ClubMember>((json) => ClubMember.fromJson(json)).toList();
  }

  static Future<List<ClubPost>> fetchPosts(String clubId) async {
    final response = await _client
        .from('club_posts')
        .select('''
          *,
          users!club_posts_author_id_fkey(id, name, avatar_url)
        ''')
        .eq('club_id', clubId)
        .order('pinned', ascending: false)
        .order('created_at', ascending: false);
    return response.map<ClubPost>((json) => ClubPost.fromJson(json)).toList();
  }

  // Fetch club posts for regular users (public view)
  static Future<List<Map<String, dynamic>>> fetchClubPostsForUser(String clubId) async {
    try {
      final response = await _client
          .from('club_posts')
          .select('''
            *,
            users!club_posts_author_id_fkey(id, name, avatar_url)
          ''')
          .eq('club_id', clubId)
          .order('pinned', ascending: false)
          .order('created_at', ascending: false);
      return response;
    } catch (e) {
      print('Error fetching club posts: $e');
      return [];
    }
  }

  static Future<List<ClubActivity>> fetchActivities(String clubId) async {
    final response = await _client
        .from('club_activities')
        .select('*')
        .eq('club_id', clubId)
        .order('activity_date', ascending: true);
    return response.map<ClubActivity>((json) => ClubActivity.fromJson(json)).toList();
  }

  // Fetch activity participants with user details
  static Future<List<Map<String, dynamic>>> fetchActivityParticipants(String activityId) async {
    try {
      final response = await _client
          .from('club_activity_participants')
          .select('''
            *,
            users!club_activity_participants_user_id_fkey(id, name, student_id, major, year, avatar_url)
          ''')
          .eq('activity_id', activityId)
          .order('joined_at', ascending: true);
      
      return response.map<Map<String, dynamic>>((participant) {
        final user = participant['users'] as Map<String, dynamic>?;
        return {
          'id': participant['id'],
          'user_id': participant['user_id'],
          'joined_at': participant['joined_at'],
          'user_name': user?['name'] ?? '',
          'student_id': user?['student_id'] ?? '',
          'major': user?['major'] ?? '',
          'year': user?['year'] ?? '',
          'avatar_url': user?['avatar_url'],
        };
      }).toList();
    } catch (e) {
      print('Error fetching activity participants: $e');
      return [];
    }
  }

  // Fetch club activities for regular users
  static Future<List<Map<String, dynamic>>> fetchClubActivitiesForUser(String clubId) async {
    try {
      final user = _client.auth.currentUser;
      final userId = user?.id;
      
      print('Fetching club activities for club: $clubId');
      
      // Fetch activities - chỉ lọc bỏ rejected, hiển thị approved và pending
      // Vì activities của CLB là nội bộ, không cần strict filter như events
      var response = await _client
          .from('club_activities')
          .select('*')
          .eq('club_id', clubId)
          .neq('status', 'rejected') // Chỉ loại bỏ rejected
          .order('activity_date', ascending: true);
      
      print('Activities (approved + pending): ${response.length}');
      
      // Nếu không có, lấy tất cả (fallback cho activities cũ không có status)
      if (response.isEmpty) {
        print('No activities found with status filter, fetching all as fallback');
        response = await _client
            .from('club_activities')
            .select('*')
            .eq('club_id', clubId)
            .order('activity_date', ascending: true);
        print('Fallback: Found ${response.length} activities');
      }
      
      // Fetch participants separately if table exists
      final result = <Map<String, dynamic>>[];
      for (var activity in response) {
        bool isParticipating = false;
        
        // Try to fetch participants if table exists
        try {
          if (userId != null) {
            final participants = await _client
                .from('club_activity_participants')
                .select('user_id')
                .eq('activity_id', activity['id'])
                .eq('user_id', userId)
                .maybeSingle();
            
            isParticipating = participants != null;
          }
        } catch (e) {
          // Table might not exist, ignore
          print('Could not fetch participants (table might not exist): $e');
        }
        
        result.add({
          ...activity,
          'isParticipating': isParticipating,
        });
      }
      
      print('Returning ${result.length} activities');
      return result;
    } catch (e) {
      print('Error fetching club activities: $e');
      return [];
    }
  }

  // Join/leave activity
  static Future<bool> toggleActivityParticipation(String activityId, bool join) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      if (join) {
        await _client
            .from('club_activity_participants')
            .insert({
              'activity_id': activityId,
              'user_id': user.id,
            });
      } else {
        await _client
            .from('club_activity_participants')
            .delete()
            .eq('activity_id', activityId)
            .eq('user_id', user.id);
      }
      return true;
    } catch (e) {
      print('Error toggling activity participation: $e');
      return false;
    }
  }

  // Club post comments
  // Note: Cần chạy migration SQL để tạo bảng club_post_comments
  // Xem file: migrations/create_club_post_comments.sql
  static Future<bool> createClubPostComment(String postId, String content, {String? parentId}) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      await _client
          .from('club_post_comments')
          .insert({
            'post_id': postId,
            'user_id': user.id,
            'content': content,
            if (parentId != null) 'parent_id': parentId,
          });
      return true;
    } catch (e) {
      print('Error creating club post comment: $e');
      print('Note: Bạn cần chạy migration SQL để tạo bảng club_post_comments');
      print('Xem file: migrations/create_club_post_comments.sql');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getClubPostComments(String postId) async {
    try {
      final user = _client.auth.currentUser;
      final userId = user?.id;
      
      final response = await _client
          .from('club_post_comments')
          .select('''
            id, content, created_at, parent_id, user_id,
            users:users!club_post_comments_user_id_fkey(name, student_id, avatar_url)
          ''')
          .eq('post_id', postId)
          .order('created_at', ascending: true);
      
      return _processComments(response, userId);
    } catch (e) {
      print('Error getting club post comments: $e');
      print('Note: Bạn cần chạy migration SQL để tạo bảng club_post_comments');
      return [];
    }
  }

  static List<Map<String, dynamic>> _processComments(List<dynamic> response, String? userId) {
    final topLevelComments = <Map<String, dynamic>>[];
    final repliesMap = <String, List<Map<String, dynamic>>>{};
    
    for (var comment in response) {
      // Extract user data
      final user = comment['users'] as Map<String, dynamic>?;
      comment['author_name'] = user?['name'] ?? 'Người dùng';
      comment['student_id'] = user?['student_id'];
      comment['avatar_url'] = user?['avatar_url'];
      
      comment['isOwner'] = userId != null && comment['user_id'] == userId;
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
    
    // Process replies as well
    for (var replies in repliesMap.values) {
      for (var reply in replies) {
        final user = reply['users'] as Map<String, dynamic>?;
        reply['author_name'] = user?['name'] ?? 'Người dùng';
        reply['student_id'] = user?['student_id'];
        reply['avatar_url'] = user?['avatar_url'];
      }
    }
    
    for (var comment in topLevelComments) {
      final commentId = comment['id'].toString();
      comment['replies'] = repliesMap[commentId] ?? [];
    }
    
    return topLevelComments;
  }

  static Future<bool> updateClubPostComment(String commentId, String content) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      await _client
          .from('club_post_comments')
          .update({'content': content})
          .eq('id', commentId)
          .eq('user_id', user.id);
      return true;
    } catch (e) {
      print('Error updating club post comment: $e');
      return false;
    }
  }

  static Future<bool> deleteClubPostComment(String commentId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      await _client
          .from('club_post_comments')
          .delete()
          .eq('id', commentId)
          .eq('user_id', user.id);
      return true;
    } catch (e) {
      print('Error deleting club post comment: $e');
      return false;
    }
  }

  static Future<int> getClubPostCommentsCount(String postId) async {
    try {
      final allComments = await _client
          .from('club_post_comments')
          .select('id')
          .eq('post_id', postId);
      
      return allComments.length;
    } catch (e) {
      print('Error getting club post comments count: $e');
      return 0;
    }
  }

  // Fetch event attendees with user details
  static Future<List<Map<String, dynamic>>> fetchEventAttendees(String eventId) async {
    try {
      final response = await _client
          .from('event_attendees')
          .select('''
            *,
            users!event_attendees_user_id_fkey(id, name, student_id, major, year, avatar_url)
          ''')
          .eq('event_id', eventId);
      
      return response.map<Map<String, dynamic>>((attendee) {
        final user = attendee['users'] as Map<String, dynamic>?;
        return {
          'id': attendee['id'],
          'user_id': attendee['user_id'],
          'user_name': user?['name'] ?? '',
          'student_id': user?['student_id'] ?? '',
          'major': user?['major'] ?? '',
          'year': user?['year'] ?? '',
          'avatar_url': user?['avatar_url'],
        };
      }).toList();
    } catch (e) {
      print('Error fetching event attendees: $e');
      return [];
    }
  }

  static Future<bool> createClub({
    required String name,
    required String description,
    required String category,
    required String leaderId,
  }) async {
    try {
      await _client.from('clubs').insert({
        'name': name,
        'description': description,
        'category': category,
        'leader_id': leaderId,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> createClubPost({
    required String clubId,
    required String authorId,
    required String content,
    String? title,
    String? imageBase64,
  }) async {
    try {
      String? imageUrl;

      // Upload image to Supabase Storage if provided
      if (imageBase64 != null && imageBase64.isNotEmpty) {
        try {
          // Strip common data URL prefixes if present
          final cleaned = imageBase64.contains(',')
              ? imageBase64.split(',').last
              : imageBase64;
          final bytes = base64Decode(cleaned);
          final uuid = const Uuid().v4();
          final filePath = 'club_posts/$clubId/$uuid.png';
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

      final insertData = <String, dynamic>{
        'club_id': clubId,
        'author_id': authorId,
        'content': content,
        if (title != null) 'title': title,
        if (imageUrl != null && imageUrl.isNotEmpty) 'attachments': [imageUrl],
      };

      await _client.from('club_posts').insert(insertData);
      return true;
    } catch (e) {
      print('Error creating club post: $e');
      return false;
    }
  }

  static Future<bool> createClubActivity({
    required String clubId,
    required String creatorId,
    required String title,
    required DateTime date,
    String? description,
    String? location,
  }) async {
    try {
      final dateString = DateFormat('yyyy-MM-dd').format(date);
      final timeString = DateFormat('HH:mm').format(date);
      await _client.from('club_activities').insert({
        'club_id': clubId,
        'creator_id': creatorId,
        'title': title,
        'description': description,
        'activity_date': dateString,
        'activity_time': timeString,
        if (location != null) 'location': location,
        'status': 'approved', // Club leader tạo hoạt động tự động được duyệt
      });
      return true;
    } catch (e) {
      print('Error creating club activity: $e');
      return false;
    }
  }

  static Future<bool> updateMemberStatus({
    required String membershipId,
    required String status,
  }) async {
    try {
      await _client
          .from('club_members')
          .update({'status': status})
          .eq('id', membershipId);
      return true;
    } catch (_) {
      return false;
    }
  }

  // Event management for club leader
  static Future<List<Event>> fetchClubEvents(String clubId) async {
    try {
      final response = await _client
          .from('events')
          .select('''
            *,
            users!events_organizer_id_fkey(name),
            event_attendees(user_id)
          ''')
          .eq('club_id', clubId)
          .order('event_date', ascending: true);
      
      return response.map<Event>((json) {
        final organizer = json['users'];
        final attendees = json['event_attendees'] as List? ?? [];
        return Event(
          id: json['id'] ?? '',
          title: json['title'] ?? '',
          description: json['description']?.toString(),
          date: json['event_date']?.toString().split('T')[0] ?? '',
          time: json['event_time']?.toString() ?? '',
          location: json['location'] ?? '',
          organizer: organizer?['name'] ?? '',
          attendees: attendees.length,
          maxAttendees: json['max_attendees'] != null ? int.tryParse(json['max_attendees'].toString()) : null,
          category: json['category'] ?? '',
          image: json['image_url'] ?? '',
          clubId: json['club_id']?.toString(),
          status: parseApprovalStatus(json['status']?.toString()),
        );
      }).toList();
    } catch (e) {
      print('Error fetching club events: $e');
      return [];
    }
  }

  static Future<bool> createEvent({
    required String clubId,
    required String organizerId,
    required String title,
    required String description,
    required DateTime eventDate,
    required String eventTime,
    required String location,
    required String category,
    String? imageUrl,
    int? maxAttendees,
  }) async {
    try {
      await _client.from('events').insert({
        'club_id': clubId,
        'organizer_id': organizerId,
        'title': title,
        'description': description,
        'event_date': eventDate.toIso8601String().split('T')[0],
        'event_time': eventTime,
        'location': location,
        'category': category,
        'image_url': imageUrl,
        'max_attendees': maxAttendees,
        'status': 'pending', // Club leader events need admin approval
      });
      return true;
    } catch (e) {
      print('Error creating event: $e');
      return false;
    }
  }

  // Update and delete methods
  static Future<bool> updateClubActivity({
    required String activityId,
    required String title,
    required DateTime date,
    String? description,
    String? location,
  }) async {
    try {
      final dateString = DateFormat('yyyy-MM-dd').format(date);
      final timeString = DateFormat('HH:mm').format(date);
      await _client.from('club_activities').update({
        'title': title,
        'description': description,
        'activity_date': dateString,
        'activity_time': timeString,
        if (location != null) 'location': location,
      }).eq('id', activityId);
      return true;
    } catch (e) {
      print('Error updating activity: $e');
      return false;
    }
  }

  static Future<bool> deleteClubActivity(String activityId) async {
    try {
      await _client.from('club_activities').delete().eq('id', activityId);
      return true;
    } catch (e) {
      print('Error deleting activity: $e');
      return false;
    }
  }

  static Future<bool> updateClubPost({
    required String postId,
    required String content,
    String? title,
    String? imageBase64,
    bool removeImage = false,
  }) async {
    try {
      // Get current post to check for existing image
      final currentPost = await _client
          .from('club_posts')
          .select('attachments, club_id')
          .eq('id', postId)
          .single();

      String? imageUrl;
      List<dynamic>? attachments;

      // Handle image upload/removal
      if (removeImage) {
        // Delete old image from storage if exists
        if (currentPost['attachments'] != null && 
            (currentPost['attachments'] as List).isNotEmpty) {
          try {
            final oldImageUrl = (currentPost['attachments'] as List).first.toString();
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
        attachments = [];
      } else if (imageBase64 != null && imageBase64.isNotEmpty) {
        // Upload new image
        try {
          // Delete old image if exists
          if (currentPost['attachments'] != null && 
              (currentPost['attachments'] as List).isNotEmpty) {
            try {
              final oldImageUrl = (currentPost['attachments'] as List).first.toString();
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

          // Upload new image
          final cleaned = imageBase64.contains(',')
              ? imageBase64.split(',').last
              : imageBase64;
          final bytes = base64Decode(cleaned);
          final uuid = const Uuid().v4();
          final clubId = currentPost['club_id'].toString();
          final filePath = 'club_posts/$clubId/$uuid.png';
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
          attachments = [imageUrl];
        } catch (e) {
          print('Image upload failed: $e');
        }
      } else {
        // Keep existing attachments
        attachments = currentPost['attachments'];
      }

      final updateData = <String, dynamic>{
        'content': content,
      };
      if (title != null) {
        updateData['title'] = title;
      }
      if (attachments != null) {
        updateData['attachments'] = attachments;
      }
      
      await _client.from('club_posts').update(updateData).eq('id', postId);
      return true;
    } catch (e) {
      print('Error updating post: $e');
      return false;
    }
  }

  static Future<bool> deleteClubPost(String postId) async {
    try {
      // Get post to delete associated image
      final post = await _client
          .from('club_posts')
          .select('attachments')
          .eq('id', postId)
          .maybeSingle();

      // Delete image from storage if exists
      if (post != null && post['attachments'] != null && 
          (post['attachments'] as List).isNotEmpty) {
        try {
          final imageUrl = (post['attachments'] as List).first.toString();
          final uri = Uri.parse(imageUrl);
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

      await _client.from('club_posts').delete().eq('id', postId);
      return true;
    } catch (e) {
      print('Error deleting post: $e');
      return false;
    }
  }

  static Future<bool> togglePinPost(String postId, bool pinned) async {
    try {
      await _client
          .from('club_posts')
          .update({'pinned': pinned})
          .eq('id', postId);
      return true;
    } catch (e) {
      print('Error toggling pin post: $e');
      return false;
    }
  }

  static Future<bool> updateEvent({
    required String eventId,
    required String title,
    required String description,
    required DateTime eventDate,
    required String eventTime,
    required String location,
    required String category,
    String? imageUrl,
    int? maxAttendees,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'title': title,
        'description': description,
        'event_date': eventDate.toIso8601String().split('T')[0],
        'event_time': eventTime,
        'location': location,
        'category': category,
        'status': 'pending', // Updated events need admin approval again
      };
      if (imageUrl != null) {
        updateData['image_url'] = imageUrl;
      }
      if (maxAttendees != null) {
        updateData['max_attendees'] = maxAttendees;
      }
      await _client.from('events').update(updateData).eq('id', eventId);
      return true;
    } catch (e) {
      print('Error updating event: $e');
      return false;
    }
  }

  static Future<bool> deleteEvent(String eventId) async {
    try {
      await _client.from('events').delete().eq('id', eventId);
      return true;
    } catch (e) {
      print('Error deleting event: $e');
      return false;
    }
  }
}

