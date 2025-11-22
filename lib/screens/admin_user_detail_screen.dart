import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/user.dart' as app_models;
import '../services/admin_service.dart';
import '../services/supabase_service.dart';
import '../config/supabase_config.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';
import 'admin_user_form_sheet.dart';

class AdminUserDetailScreen extends StatefulWidget {
  final app_models.User user;

  const AdminUserDetailScreen({super.key, required this.user});

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  
  List<Map<String, dynamic>> _posts = [];
  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> _clubs = [];
  Map<String, dynamic>? _userStats;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load user posts
      final postsResponse = await SupabaseConfig.client
          .from('posts')
          .select('*')
          .eq('user_id', widget.user.id)
          .order('created_at', ascending: false)
          .limit(10);
      _posts = List<Map<String, dynamic>>.from(postsResponse);

      // Load user events (attended)
      final eventsResponse = await SupabaseConfig.client
          .from('event_attendees')
          .select('''
            event_id,
            events!inner(*)
          ''')
          .eq('user_id', widget.user.id)
          .limit(10);
      _events = (eventsResponse as List)
          .map((e) => e['events'] as Map<String, dynamic>)
          .toList();

      // Load user clubs
      final clubsResponse = await SupabaseConfig.client
          .from('club_members')
          .select('''
            club_id,
            clubs!inner(*)
          ''')
          .eq('user_id', widget.user.id)
          .eq('status', 'active');
      _clubs = (clubsResponse as List)
          .map((e) => e['clubs'] as Map<String, dynamic>)
          .toList();

      // Calculate stats
      _userStats = {
        'posts_count': _posts.length,
        'events_count': _events.length,
        'clubs_count': _clubs.length,
      };
    } catch (e) {
      print('Error loading user data: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _editUser() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminUserFormSheet(user: widget.user),
      ),
    );

    if (result == true && mounted) {
      // Reload user data
      await _loadUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết: ${widget.user.name}'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.edit),
            onPressed: _editUser,
            tooltip: 'Sửa',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(LucideIcons.user), text: 'Thông tin'),
            Tab(icon: Icon(LucideIcons.fileText), text: 'Bài đăng'),
            Tab(icon: Icon(LucideIcons.calendar), text: 'Sự kiện'),
            Tab(icon: Icon(LucideIcons.users), text: 'CLB'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildUserInfoTab(),
                _buildPostsTab(),
                _buildEventsTab(),
                _buildClubsTab(),
              ],
            ),
    );
  }

  Widget _buildUserInfoTab() {
    return RefreshIndicator(
      onRefresh: _loadUserData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User profile card
            CustomCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: widget.user.avatar != null && widget.user.avatar!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(widget.user.avatar!, fit: BoxFit.cover),
                          )
                        : Text(
                            widget.user.name.isNotEmpty ? widget.user.name[0].toUpperCase() : 'U',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.user.email,
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.user.studentId,
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Stats
            if (_userStats != null) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard('Bài đăng', _userStats!['posts_count'] ?? 0, Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard('Sự kiện', _userStats!['events_count'] ?? 0, Colors.orange),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard('CLB', _userStats!['clubs_count'] ?? 0, Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            // User details
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thông tin chi tiết',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(LucideIcons.graduationCap, 'Ngành học', widget.user.major),
                  const SizedBox(height: 12),
                  _buildInfoRow(LucideIcons.calendar, 'Năm học', widget.user.year),
                  const SizedBox(height: 12),
                  _buildInfoRow(LucideIcons.phone, 'Số điện thoại', widget.user.phone ?? 'Chưa cập nhật'),
                  const SizedBox(height: 12),
                  _buildInfoRow(LucideIcons.shield, 'Vai trò', widget.user.role.value),
                  const SizedBox(height: 12),
                  _buildInfoRow(LucideIcons.checkCircle2, 'Trạng thái', widget.user.accountStatus),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildPostsTab() {
    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.fileText, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chưa có bài đăng nào',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUserData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return CustomCard(
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post['content'] ?? '',
                  style: const TextStyle(fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(LucideIcons.heart, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${post['likes_count'] ?? 0}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    Icon(LucideIcons.messageSquare, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${post['comments_count'] ?? 0}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const Spacer(),
                    if (post['created_at'] != null)
                      Text(
                        _formatTimeAgo(post['created_at'].toString()),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventsTab() {
    if (_events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.calendar, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chưa tham gia sự kiện nào',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUserData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return CustomCard(
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(LucideIcons.calendar, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${event['event_date'] ?? ''} ${event['event_time'] ?? ''}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                    Icon(LucideIcons.mapPin, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event['location'] ?? '',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildClubsTab() {
    if (_clubs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.users, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chưa tham gia CLB nào',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUserData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _clubs.length,
        itemBuilder: (context, index) {
          final club = _clubs[index];
          return CustomCard(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    LucideIcons.users,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        club['name'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        club['description'] ?? '',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatTimeAgo(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} ngày trước';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} giờ trước';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} phút trước';
      } else {
        return 'Vừa xong';
      }
    } catch (e) {
      return dateTimeString;
    }
  }
}

