import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/event.dart';
import '../services/admin_service.dart';
import '../services/club_leader_service.dart';
import '../widgets/common_widgets.dart';
import 'admin_club_form_sheet.dart';

class AdminClubDetailScreen extends StatefulWidget {
  final String clubId;

  const AdminClubDetailScreen({super.key, required this.clubId});

  @override
  State<AdminClubDetailScreen> createState() => _AdminClubDetailScreenState();
}

class _AdminClubDetailScreenState extends State<AdminClubDetailScreen> {
  bool _isLoading = true;
  bool _isContentLoading = true;
  Map<String, dynamic>? _clubDetails;
  String _memberSearchQuery = '';
  List<Event> _clubEvents = [];
  List<_ActivityInfo> _clubActivities = [];
  List<_PostInfo> _clubPosts = [];

  @override
  void initState() {
    super.initState();
    _loadClubDetails();
  }

  Future<void> _loadClubDetails() async {
    setState(() => _isLoading = true);
    final details = await AdminService.fetchClubDetails(widget.clubId);
    setState(() {
      _clubDetails = details;
      _isLoading = false;
    });
    await _loadClubContent();
  }

  Future<void> _loadClubContent() async {
    setState(() => _isContentLoading = true);
    final events = await ClubLeaderService.fetchClubEvents(widget.clubId);
    final activities = await ClubLeaderService.fetchActivities(widget.clubId);
    final posts = await ClubLeaderService.fetchPosts(widget.clubId);

    final activityInfos = await Future.wait(activities.map((activity) async {
      final participants = await ClubLeaderService.fetchActivityParticipants(activity.id);
      return _ActivityInfo(activity: activity, participantCount: participants.length);
    }));

    final postInfos = await Future.wait(posts.map((post) async {
      final commentCount = await ClubLeaderService.getClubPostCommentsCount(post.id);
      return _PostInfo(post: post, commentCount: commentCount);
    }));

    if (!mounted) return;
    setState(() {
      _clubEvents = events;
      _clubActivities = activityInfos;
      _clubPosts = postInfos;
      _isContentLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredMembers {
    if (_clubDetails == null) return [];
    final members = (_clubDetails!['club_members'] as List?) ?? [];
    if (_memberSearchQuery.isEmpty) {
      return members.map((m) => m as Map<String, dynamic>).toList();
    }
    return members.where((member) {
      final user = member['users'] as Map<String, dynamic>?;
      if (user == null) return false;
      final name = (user['name'] ?? '').toString().toLowerCase();
      final email = (user['email'] ?? '').toString().toLowerCase();
      final studentId = (user['student_id'] ?? '').toString().toLowerCase();
      final query = _memberSearchQuery.toLowerCase();
      return name.contains(query) || email.contains(query) || studentId.contains(query);
    }).map((m) => m as Map<String, dynamic>).toList();
  }

  Future<void> _editClub() async {
    if (_clubDetails == null) return;
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminClubFormSheet(club: _clubDetails),
      ),
    );

    if (result == true && mounted) {
      await _loadClubDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết câu lạc bộ'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.edit),
            onPressed: _clubDetails == null ? null : _editClub,
            tooltip: 'Sửa',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _clubDetails == null
              ? const Center(child: Text('Không tìm thấy thông tin'))
              : RefreshIndicator(
                  onRefresh: _loadClubDetails,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Club info card
                        CustomCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      LucideIcons.users,
                                      color: Theme.of(context).colorScheme.primary,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _clubDetails!['name'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _clubDetails!['category'] ?? '',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _clubDetails!['description'] ?? '',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _buildInfoItem(
                                    LucideIcons.users,
                                    'Thành viên',
                                    '${(_clubDetails!['club_members'] as List?)?.length ?? 0}',
                                  ),
                                  const SizedBox(width: 24),
                                  _buildInfoItem(
                                    LucideIcons.calendar,
                                    'Trạng thái',
                                    _clubDetails!['status'] == 'approved'
                                        ? 'Đã duyệt'
                                        : _clubDetails!['status'] == 'pending'
                                            ? 'Chờ duyệt'
                                            : 'Từ chối',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Leader info
                        if (_clubDetails!['users'] != null) ...[
                          CustomCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Trưởng CLB',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                      child: Text(
                                        (_clubDetails!['users']['name'] ?? 'U')[0].toUpperCase(),
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _clubDetails!['users']['name'] ?? '',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            _clubDetails!['users']['email'] ?? '',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        // Members list
                        CustomCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Thành viên (${(_clubDetails!['club_members'] as List?)?.length ?? 0})',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Search bar for members
                              TextField(
                                decoration: InputDecoration(
                                  hintText: 'Tìm kiếm thành viên...',
                                  prefixIcon: const Icon(LucideIcons.search),
                                  suffixIcon: _memberSearchQuery.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            setState(() {
                                              _memberSearchQuery = '';
                                            });
                                          },
                                        )
                                      : null,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _memberSearchQuery = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                              if (_filteredMembers.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Text(
                                      _memberSearchQuery.isEmpty
                                          ? 'Chưa có thành viên'
                                          : 'Không tìm thấy thành viên',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ),
                                )
                              else
                                ..._filteredMembers.map((member) {
                                  final user = member['users'] as Map<String, dynamic>?;
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                      child: Text(
                                        (user?['name'] ?? 'U')[0].toUpperCase(),
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    title: Text(user?['name'] ?? ''),
                                    subtitle: Text(
                                      user?['student_id'] ?? user?['email'] ?? '',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  );
                                }).toList(),
                            ],
                          ),
                        ),
                const SizedBox(height: 16),
                _buildClubContentSection(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClubContentSection() {
    if (_isContentLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hoạt động của CLB',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildEventsCard(),
        const SizedBox(height: 12),
        _buildActivitiesCard(),
        const SizedBox(height: 12),
        _buildPostsCard(),
      ],
    );
  }

  Widget _buildEventsCard() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Sự kiện', _clubEvents.length),
          if (_clubEvents.isEmpty)
            _buildEmptyState('Chưa có sự kiện nào')
          else
            ..._clubEvents.map((event) {
              final isLast = event == _clubEvents.last;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(LucideIcons.calendar, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${event.date} ${event.time}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(LucideIcons.mapPin, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            event.location,
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(LucideIcons.users, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          '${event.attendees} người tham gia',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => _showEventParticipants(event),
                          child: const Text('Xem chi tiết'),
                        ),
                      ],
                    ),
                    if (!isLast) Divider(color: Colors.grey[200]),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildActivitiesCard() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Hoạt động', _clubActivities.length),
          if (_clubActivities.isEmpty)
            _buildEmptyState('Chưa có hoạt động nội bộ')
          else
            ..._clubActivities.map((activityInfo) {
              final isLast = activityInfo == _clubActivities.last;
              final activity = activityInfo.activity;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(LucideIcons.calendarClock, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          activity.date.toIso8601String().split('T').first,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(LucideIcons.mapPin, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            activity.location ?? 'Chưa cập nhật địa điểm',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(LucideIcons.users, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          '${activityInfo.participantCount} người tham gia',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => _showActivityParticipants(activity),
                          child: const Text('Xem chi tiết'),
                        ),
                      ],
                    ),
                    if (!isLast) Divider(color: Colors.grey[200]),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildPostsCard() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Bài viết', _clubPosts.length),
          if (_clubPosts.isEmpty)
            _buildEmptyState('Chưa có bài viết nào')
          else
            ..._clubPosts.map((postInfo) {
              final isLast = postInfo == _clubPosts.last;
              final post = postInfo.post;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((post.title ?? '').isNotEmpty)
                      Text(
                        post.title!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    if ((post.title ?? '').isNotEmpty) const SizedBox(height: 6),
                    Text(
                      post.content,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(LucideIcons.messageCircle, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          '${postInfo.commentCount} bình luận',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => _showPostComments(post),
                          child: const Text('Xem bình luận'),
                        ),
                      ],
                    ),
                    if (!isLast) Divider(color: Colors.grey[200]),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Text(
      '$title ($count)',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }

  Future<void> _showEventParticipants(Event event) async {
    final participants = await ClubLeaderService.fetchEventAttendees(event.id);
    if (!mounted) return;
    _showParticipantsSheet(
      title: 'Người tham gia sự kiện',
      countLabel: '${participants.length} người',
      participants: participants,
    );
  }

  Future<void> _showActivityParticipants(ClubActivity activity) async {
    final participants = await ClubLeaderService.fetchActivityParticipants(activity.id);
    if (!mounted) return;
    _showParticipantsSheet(
      title: 'Người tham gia hoạt động',
      countLabel: '${participants.length} người',
      participants: participants,
    );
  }

  Future<void> _showPostComments(ClubPost post) async {
    final comments = await ClubLeaderService.getClubPostComments(post.id);
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, controller) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Bình luận bài viết',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: comments.isEmpty
                  ? Center(
                      child: Text(
                        'Chưa có bình luận',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      controller: controller,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            child: Text(
                              (comment['author_name'] ?? 'U')[0].toUpperCase(),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(comment['author_name'] ?? 'Người dùng'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if ((comment['student_id'] ?? '').toString().isNotEmpty)
                                Text(
                                  'MSSV: ${comment['student_id']}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              const SizedBox(height: 4),
                              Text(comment['content'] ?? ''),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showParticipantsSheet({
    required String title,
    required String countLabel,
    required List<Map<String, dynamic>> participants,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    countLabel,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: participants.isEmpty
                  ? Center(
                      child: Text(
                        'Chưa có người tham gia',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: participants.length,
                      itemBuilder: (context, index) {
                        final participant = participants[index];
                        final user = participant['users'] as Map<String, dynamic>?;
                        final name = participant['user_name'] ??
                            user?['name'] ??
                            participant['name'] ??
                            'Người dùng';
                        final studentId = participant['student_id'] ?? user?['student_id'] ?? '';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.15)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                child: Text(
                                  name.toString().isNotEmpty ? name[0].toUpperCase() : 'U',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    if (studentId.toString().isNotEmpty)
                                      Text(
                                        'MSSV: $studentId',
                                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityInfo {
  final ClubActivity activity;
  final int participantCount;

  _ActivityInfo({required this.activity, required this.participantCount});
}

class _PostInfo {
  final ClubPost post;
  final int commentCount;

  _PostInfo({required this.post, required this.commentCount});
}

