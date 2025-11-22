import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/event.dart';
import '../models/user.dart' as app_models;

class AdminService {
  static final SupabaseClient _client = SupabaseConfig.client;

  static Future<Map<String, dynamic>> fetchDashboardStats() async {
    try {
      // Get counts by selecting all IDs and counting
      // Note: For large datasets, consider using a more efficient method
      final results = await Future.wait([
        _client.from('users').select('id'),
        _client.from('clubs').select('id'),
        _client.from('events').select('id'),
        _client.from('club_members').select('id'),
      ]);

      return {
        'users': (results[0] as List).length,
        'clubs': (results[1] as List).length,
        'events': (results[2] as List).length,
        'memberships': (results[3] as List).length,
      };
    } catch (e) {
      print('Error fetching dashboard stats: $e');
      return {
        'users': 0,
        'clubs': 0,
        'events': 0,
        'memberships': 0,
      };
    }
  }

  static Future<List<Club>> fetchPendingClubs() async {
    final response = await _client
        .from('clubs')
        .select('*')
        .eq('status', 'pending')
        .order('created_at', ascending: true);
    return response.map<Club>((json) => Club.fromJson(json)).toList();
  }

  static Future<bool> reviewClub({
    required String clubId,
    required bool approved,
    String? reason,
  }) async {
    try {
      await _client.from('clubs').update({
        'status': approved ? 'approved' : 'rejected',
        'metadata': {
          'reviewed_at': DateTime.now().toIso8601String(),
          'review_reason': reason,
        }
      }).eq('id', clubId);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<List<Event>> fetchPendingEvents() async {
    try {
      final response = await _client
          .from('events')
          .select('*')
          .eq('status', 'pending')
          .order('event_date', ascending: true);
      return response.map<Event>((json) => Event.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching pending events: $e');
      return [];
    }
  }

  static Future<bool> reviewEvent({
    required String eventId,
    required bool approved,
    String? reason,
  }) async {
    try {
      await _client.from('events').update({
        'status': approved ? 'approved' : 'rejected',
        'metadata': {
          'reviewed_at': DateTime.now().toIso8601String(),
          'review_reason': reason,
        }
      }).eq('id', eventId);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<List<app_models.User>> fetchUsers({String? status}) async {
    var query = _client.from('users').select('*');
    if (status != null) {
      query = query.eq('account_status', status);
    }
    final response = await query.order('created_at', ascending: false);
    return response.map<app_models.User>((json) => app_models.User.fromJson(json)).toList();
  }

  static Future<bool> toggleUserLock({
    required String userId,
    required bool isLocked,
  }) async {
    try {
      await _client.from('users').update({
        'is_locked': isLocked,
        'account_status': isLocked ? 'disabled' : 'active',
      }).eq('id', userId);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> sendBroadcastAnnouncement({
    required String title,
    required String content,
    String priority = 'normal',
    String? targetAudience,
    String? category,
  }) async {
    try {
      final user = _client.auth.currentUser;
      await _client.from('announcements').insert({
        'title': title,
        'content': content,
        'priority': priority,
        'target_audience': targetAudience ?? 'all',
        'category': category,
        'created_by': user?.id,
      });
      return true;
    } catch (e) {
      print('Error sending announcement: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchAnnouncements() async {
    try {
      final response = await _client
          .from('announcements')
          .select('''
            *,
            users!announcements_created_by_fkey(name, student_id)
          ''')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching announcements: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> fetchAnnouncementById(String announcementId) async {
    try {
      final response = await _client
          .from('announcements')
          .select('''
            *,
            users!announcements_created_by_fkey(name, student_id, email)
          ''')
          .eq('id', announcementId)
          .single();
      return response;
    } catch (e) {
      print('Error fetching announcement: $e');
      return null;
    }
  }

  static Future<bool> updateAnnouncement({
    required String announcementId,
    required String title,
    required String content,
    String priority = 'normal',
    String? targetAudience,
    String? category,
  }) async {
    try {
      await _client.from('announcements').update({
        'title': title,
        'content': content,
        'priority': priority,
        'target_audience': targetAudience ?? 'all',
        'category': category,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', announcementId);
      return true;
    } catch (e) {
      print('Error updating announcement: $e');
      return false;
    }
  }

  static Future<bool> deleteAnnouncement(String announcementId) async {
    try {
      await _client.from('announcements').delete().eq('id', announcementId);
      return true;
    } catch (e) {
      print('Error deleting announcement: $e');
      return false;
    }
  }

  // Event management
  static Future<List<Event>> fetchAllEvents() async {
    try {
      final response = await _client
          .from('events')
          .select('''
            *,
            users!events_organizer_id_fkey(name)
          ''')
          .order('event_date', ascending: false);
      
      return response.map<Event>((json) {
        final organizer = json['users'];
        return Event(
          id: json['id'] ?? '',
          title: json['title'] ?? '',
          description: json['description']?.toString(),
          date: json['event_date']?.toString().split('T')[0] ?? '',
          time: json['event_time']?.toString() ?? '',
          location: json['location'] ?? '',
          organizer: organizer?['name'] ?? '',
          attendees: json['attendees_count'] ?? 0,
          maxAttendees: json['max_attendees'] != null ? int.tryParse(json['max_attendees'].toString()) : null,
          category: json['category'] ?? '',
          image: json['image_url'] ?? '',
          clubId: json['club_id']?.toString(),
          status: parseApprovalStatus(json['status']?.toString()),
          visibility: parseVisibilityScope(json['visibility']?.toString()),
        );
      }).toList();
    } catch (e) {
      print('Error fetching events: $e');
      return [];
    }
  }

  static Future<bool> createEvent(Map<String, dynamic> eventData) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;
      
      await _client.from('events').insert({
        ...eventData,
        'organizer_id': user.id,
        'status': 'approved', // Admin-created events are auto-approved
      });
      return true;
    } catch (e) {
      print('Error creating event: $e');
      return false;
    }
  }

  static Future<bool> updateEvent(String eventId, Map<String, dynamic> eventData) async {
    try {
      await _client.from('events')
          .update(eventData)
          .eq('id', eventId);
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

  // User management
  static Future<List<app_models.User>> searchUsers(String query) async {
    try {
      final response = await _client
          .from('users')
          .select('*')
          .or('name.ilike.%$query%,email.ilike.%$query%,student_id.ilike.%$query%')
          .order('created_at', ascending: false);
      return response.map<app_models.User>((json) => app_models.User.fromJson(json)).toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  static Future<bool> createUser(Map<String, dynamic> userData) async {
    try {
      await _client.from('users').insert(userData);
      return true;
    } catch (e) {
      print('Error creating user: $e');
      return false;
    }
  }

  static Future<bool> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      await _client.from('users')
          .update(userData)
          .eq('id', userId);
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  static Future<bool> deleteUser(String userId) async {
    try {
      await _client.from('users').delete().eq('id', userId);
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  // Club management
  static Future<List<Club>> fetchAllClubs() async {
    try {
      final response = await _client
          .from('clubs')
          .select('''
            *,
            users!clubs_leader_id_fkey(name, email),
            club_members(user_id)
          ''')
          .order('created_at', ascending: false);
      
      return response.map<Club>((json) {
        final members = json['club_members'] as List? ?? [];
        return Club(
          id: json['id'] ?? '',
          name: json['name'] ?? '',
          members: members.length,
          category: json['category'] ?? '',
          description: json['description'] ?? '',
          active: json['active'] ?? false,
          status: parseApprovalStatus(json['status']?.toString()),
          visibility: parseVisibilityScope(json['visibility']?.toString()),
          leaderId: json['leader_id']?.toString(),
          metadata: Map<String, dynamic>.from(json['metadata'] ?? const {}),
        );
      }).toList();
    } catch (e) {
      print('Error fetching clubs: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> fetchClubDetails(String clubId) async {
    try {
      final response = await _client
          .from('clubs')
          .select('''
            *,
            users!clubs_leader_id_fkey(id, name, email, student_id, avatar_url),
            club_members(
              user_id,
              users!club_members_user_id_fkey(id, name, email, student_id, avatar_url)
            )
          ''')
          .eq('id', clubId)
          .single();
      
      return response;
    } catch (e) {
      print('Error fetching club details: $e');
      return null;
    }
  }

  static Future<bool> createClub(Map<String, dynamic> clubData) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;
      
      // If admin creates club, automatically approve it
      final isAdmin = user.userMetadata?['role'] == 'admin' || 
                      await _checkIfAdmin(user.id);
      
      final dataToInsert = {
        ...clubData,
        'leader_id': clubData['leader_id'] ?? user.id,
        if (isAdmin) 'status': 'approved',
      };
      
      await _client.from('clubs').insert(dataToInsert);
      return true;
    } catch (e) {
      print('Error creating club: $e');
      return false;
    }
  }

  static Future<bool> _checkIfAdmin(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select('role')
          .eq('id', userId)
          .single();
      return response['role'] == 'admin';
    } catch (_) {
      return false;
    }
  }

  static Future<bool> updateClub(String clubId, Map<String, dynamic> clubData) async {
    try {
      await _client.from('clubs')
          .update(clubData)
          .eq('id', clubId);
      return true;
    } catch (e) {
      print('Error updating club: $e');
      return false;
    }
  }

  static Future<bool> deleteClub(String clubId) async {
    try {
      await _client.from('clubs').delete().eq('id', clubId);
      return true;
    } catch (e) {
      print('Error deleting club: $e');
      return false;
    }
  }
}

