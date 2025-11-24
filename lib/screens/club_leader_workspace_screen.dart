import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/event.dart';
import '../providers/app_provider.dart';
import '../services/club_leader_service.dart';
import '../services/supabase_service.dart';
import '../widgets/common_widgets.dart';
import 'club_leader_members_screen.dart';
import 'club_leader_posts_screen.dart';
import 'club_leader_activities_screen.dart';
import 'club_leader_events_screen.dart';

class ClubLeaderWorkspaceScreen extends StatefulWidget {
  const ClubLeaderWorkspaceScreen({super.key});

  @override
  State<ClubLeaderWorkspaceScreen> createState() =>
      _ClubLeaderWorkspaceScreenState();
}

class _ClubLeaderWorkspaceStateData {
  Club? club;
  List<ClubMember> members = [];
  List<ClubMember> pendingMembers = [];
  List<ClubPost> posts = [];
  List<ClubActivity> activities = [];
  List<Event> events = [];
}

class _ClubLeaderWorkspaceScreenState
    extends State<ClubLeaderWorkspaceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _clubNameController = TextEditingController();
  final TextEditingController _clubDescController = TextEditingController();
  String? _selectedClubCategory;

  bool _isLoading = true;
  _ClubLeaderWorkspaceStateData _state = _ClubLeaderWorkspaceStateData();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  final List<String> _clubCategories = [
    'Học thuật',
    'Văn hóa',
    'Thể thao',
    'Nghề nghiệp',
  ];

  @override
  void dispose() {
    _tabController.dispose();
    _clubNameController.dispose();
    _clubDescController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final user = context.read<AppProvider>().currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    final club = await ClubLeaderService.fetchOwnClub(userId: user.id);
    if (club == null) {
      setState(() {
        _state = _ClubLeaderWorkspaceStateData();
        _isLoading = false;
      });
      return;
    }

    final members = await ClubLeaderService.fetchMembers(club.id);
    final posts = await ClubLeaderService.fetchPosts(club.id);
    final activities = await ClubLeaderService.fetchActivities(club.id);
    final events = await ClubLeaderService.fetchClubEvents(club.id);

    setState(() {
      _state = _ClubLeaderWorkspaceStateData()
        ..club = club
        ..members = members.where((m) => m.status == 'active').toList()
        ..pendingMembers = members.where((m) => m.status == 'pending').toList()
        ..posts = posts
        ..activities = activities
        ..events = events;
      _isLoading = false;
    });
  }

  Future<void> _createClub() async {
    final user = context.read<AppProvider>().currentUser;
    if (user == null) return;

    if (_clubNameController.text.isEmpty || _selectedClubCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await ClubLeaderService.createClub(
      name: _clubNameController.text,
      description: _clubDescController.text,
      category: _selectedClubCategory!,
      leaderId: user.id,
    );

    if (success) {
      _clubNameController.clear();
      _clubDescController.clear();
      setState(() {
        _selectedClubCategory = null;
      });
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã gửi yêu cầu tạo CLB. Đang chờ admin duyệt.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Có lỗi xảy ra khi tạo CLB'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Không gian chủ nhiệm CLB'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _state.club == null
              ? _buildCreateClubPrompt()
              : Column(
                  children: [
                    // Tab bar
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      tabs: const [
                        Tab(icon: Icon(LucideIcons.layoutDashboard), text: 'Tổng quan'),
                        Tab(icon: Icon(LucideIcons.activity), text: 'Hoạt động'),
                        Tab(icon: Icon(LucideIcons.calendar), text: 'Sự kiện'),
                        Tab(icon: Icon(LucideIcons.fileText), text: 'Bài viết'),
                        Tab(icon: Icon(LucideIcons.users), text: 'Thành viên'),
                      ],
                    ),
                    // Tab content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOverviewTab(),
                          _state.club != null
                              ? ClubLeaderActivitiesScreen(clubId: _state.club!.id)
                              : const Center(child: Text('Chưa có CLB')),
                          _state.club != null
                              ? ClubLeaderEventsScreen(clubId: _state.club!.id)
                              : const Center(child: Text('Chưa có CLB')),
                          _state.club != null
                              ? ClubLeaderPostsScreen(clubId: _state.club!.id)
                              : const Center(child: Text('Chưa có CLB')),
                          _state.club != null
                              ? ClubLeaderMembersScreen(clubId: _state.club!.id)
                              : const Center(child: Text('Chưa có CLB')),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildCreateClubPrompt() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.users,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Bạn chưa có câu lạc bộ',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tạo câu lạc bộ mới để bắt đầu quản lý và kết nối với sinh viên',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            CustomInput(
              controller: _clubNameController,
              hintText: 'Tên câu lạc bộ',
              labelText: 'Tên câu lạc bộ',
              prefixIcon: LucideIcons.users,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên câu lạc bộ';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedClubCategory,
              decoration: InputDecoration(
                labelText: 'Lĩnh vực',
                prefixIcon: const Icon(LucideIcons.tag),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _clubCategories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedClubCategory = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Vui lòng chọn lĩnh vực';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomInput(
              controller: _clubDescController,
              hintText: 'Mô tả về câu lạc bộ',
              labelText: 'Mô tả',
              prefixIcon: LucideIcons.fileText,
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Gửi yêu cầu tạo CLB',
                icon: LucideIcons.send,
                onPressed: _createClub,
                size: ButtonSize.large,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactHeader() {
    final club = _state.club!;
    return CustomCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Club name and status in one row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  club.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              CustomBadge(
                text: club.status == ApprovalStatus.approved
                    ? 'Đã duyệt'
                    : club.status == ApprovalStatus.pending
                        ? 'Chờ duyệt'
                        : 'Từ chối',
                type: club.status == ApprovalStatus.approved
                    ? BadgeType.success
                    : club.status == ApprovalStatus.pending
                        ? BadgeType.warning
                        : BadgeType.error,
                size: BadgeSize.small,
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Description (truncated)
          Text(
            club.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          // Stats and badges in one row
          Row(
            children: [
              // Quick stats
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCompactStatItem(
                      LucideIcons.users,
                      '${_state.members.length}',
                      'Thành viên',
                    ),
                    _buildCompactStatItem(
                      LucideIcons.fileText,
                      '${_state.posts.length}',
                      'Bài viết',
                    ),
                    _buildCompactStatItem(
                      LucideIcons.calendar,
                      '${_state.events.length}',
                      'Sự kiện',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Category badge
              CustomBadge(
                text: club.category,
                type: BadgeType.primary,
                size: BadgeSize.small,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatItem(IconData icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 10,
              ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab() {
    final club = _state.club!;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats
          _buildQuickStatsCards(),
          const SizedBox(height: 24),
          // Club Information
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.info,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Thông tin CLB',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow('Tên CLB', club.name),
                const SizedBox(height: 12),
                _buildInfoRow('Mô tả', club.description),
                const SizedBox(height: 12),
                _buildInfoRow('Lĩnh vực', club.category),
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Trạng thái',
                  club.status == ApprovalStatus.approved
                      ? 'Đã duyệt'
                      : club.status == ApprovalStatus.pending
                          ? 'Chờ duyệt'
                          : 'Từ chối',
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Số thành viên', '${club.members}'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Recent Activity Summary
          _buildRecentActivitySummary(),
        ],
      ),
    );
  }

  Widget _buildQuickStatsCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: CustomCard(
            child: Column(
              children: [
                Icon(
                  LucideIcons.users,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  '${_state.members.length}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Thành viên',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomCard(
            child: Column(
              children: [
                Icon(
                  LucideIcons.fileText,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  '${_state.posts.length}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Bài viết',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomCard(
            child: Column(
              children: [
                Icon(
                  LucideIcons.calendar,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  '${_state.events.length}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Sự kiện',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomCard(
            child: Column(
              children: [
                Icon(
                  LucideIcons.activity,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  '${_state.activities.length}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Hoạt động',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivitySummary() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _showRecentActivitiesDetail(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.clock,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Hoạt động gần đây',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Icon(
                  LucideIcons.chevronRight,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_state.posts.isEmpty && _state.events.isEmpty && _state.activities.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Chưa có hoạt động nào',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            Column(
              children: [
                if (_state.posts.isNotEmpty) ...[
                  _buildSummaryItem(
                    LucideIcons.fileText,
                    'Bài viết mới nhất',
                    _state.posts.first.title ?? _state.posts.first.content,
                  ),
                  const SizedBox(height: 12),
                ],
                if (_state.events.isNotEmpty) ...[
                  _buildSummaryItem(
                    LucideIcons.calendar,
                    'Sự kiện sắp tới',
                    _state.events.first.title,
                  ),
                  const SizedBox(height: 12),
                ],
                if (_state.activities.isNotEmpty) ...[
                  _buildSummaryItem(
                    LucideIcons.activity,
                    'Hoạt động gần đây',
                    _state.activities.first.title,
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  void _showRecentActivitiesDetail() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hoạt động gần đây',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                if (_state.posts.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        LucideIcons.fileText,
                        color: Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Bài viết (${_state.posts.length})',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._state.posts.map((post) => InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _handleRecentPostTap(post),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  LucideIcons.fileText,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (post.title != null) ...[
                                      Text(
                                        post.title!,
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blue[900],
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    Text(
                                      post.content,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            height: 1.5,
                                          ),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 32),
                ],
                    if (_state.events.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            LucideIcons.calendar,
                            color: Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Sự kiện (${_state.events.length})',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                  ..._state.events.map((event) => InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _handleRecentEventTap(event),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  LucideIcons.calendar,
                                  color: Colors.orange,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event.title,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.orange[900],
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          LucideIcons.calendar,
                                          size: 14,
                                          color: Colors.orange[700],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          event.date,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Colors.orange[700],
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                        const SizedBox(width: 12),
                                        Icon(
                                          LucideIcons.clock,
                                          size: 14,
                                          color: Colors.orange[700],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          event.time,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Colors.orange[700],
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ],
                                    ),
                                    if (event.location.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            LucideIcons.mapPin,
                                            size: 14,
                                            color: Colors.orange[700],
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              event.location,
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: Colors.orange[700],
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                      const SizedBox(height: 32),
                    ],
                    if (_state.activities.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            LucideIcons.activity,
                            color: Colors.purple,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Hoạt động (${_state.activities.length})',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ..._state.activities.map((activity) => InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _handleRecentActivityTap(activity),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.purple.withOpacity(0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      LucideIcons.activity,
                                      color: Colors.purple,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          activity.title,
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.purple[900],
                                              ),
                                        ),
                                        if (activity.description != null &&
                                            activity.description!.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            activity.description!,
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  height: 1.5,
                                                ),
                                            maxLines: 4,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              LucideIcons.calendar,
                                              size: 14,
                                              color: Colors.purple[700],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${activity.date.day}/${activity.date.month}/${activity.date.year}',
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: Colors.purple[700],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                            if (activity.location != null &&
                                                activity.location!.isNotEmpty) ...[
                                              const SizedBox(width: 12),
                                              Icon(
                                                LucideIcons.mapPin,
                                                size: 14,
                                                color: Colors.purple[700],
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  activity.location!,
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                        color: Colors.purple[700],
                                                      ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                      const SizedBox(height: 32),
                    ],
                    if (_state.posts.isEmpty && _state.events.isEmpty && _state.activities.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(48),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.clock,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Chưa có hoạt động nào',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Các hoạt động sẽ hiển thị ở đây',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[500],
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleRecentPostTap(ClubPost post) {
    Navigator.of(context).pop();
    Future.microtask(() => _showRecentPostDetail(post));
  }

  void _handleRecentEventTap(Event event) {
    Navigator.of(context).pop();
    Future.microtask(() => _showRecentEventDetail(event));
  }

  void _handleRecentActivityTap(ClubActivity activity) {
    Navigator.of(context).pop();
    Future.microtask(() => _showRecentActivityDetail(activity));
  }

  Future<void> _showRecentPostDetail(ClubPost post) async {
    final comments = await ClubLeaderService.getClubPostComments(post.id);
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(
                    'Chi tiết bài viết',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (post.title != null && post.title!.isNotEmpty) ...[
                            Text(
                              post.title!,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          Text(
                            post.content,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.messageCircle,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Bình luận (${comments.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (comments.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Column(
                            children: [
                              Icon(
                                LucideIcons.messageCircle,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Chưa có bình luận nào',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[200]!,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                      child: Text(
                                        (comment['author_name'] ?? 'N')[0].toUpperCase(),
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
                                            comment['author_name'] ?? 'Người dùng',
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          if (comment['student_id'] != null &&
                                              comment['student_id'].toString().isNotEmpty)
                                            Text(
                                              'MSSV: ${comment['student_id']}',
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: Colors.grey[600],
                                                  ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  comment['content'] ?? '',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRecentEventDetail(Event event) async {
    final attendees = await ClubLeaderService.fetchEventAttendees(event.id);
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
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(
                    'Chi tiết sự kiện',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow('Ngày', event.date, LucideIcons.calendar),
                          const SizedBox(height: 8),
                          _buildDetailRow('Giờ', event.time, LucideIcons.clock),
                          const SizedBox(height: 8),
                          if (event.location.isNotEmpty)
                            _buildDetailRow('Địa điểm', event.location, LucideIcons.mapPin),
                          if (event.description != null && event.description!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Mô tả',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              event.description!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.users,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Người tham gia (${attendees.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (attendees.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Column(
                            children: [
                              Icon(
                                LucideIcons.users,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Chưa có người tham gia',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: attendees.length,
                        itemBuilder: (context, index) {
                          final attendee = attendees[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  child: Text(
                                    (attendee['user_name']?.toString()[0] ?? 'U').toUpperCase(),
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
                                        attendee['user_name'] ?? 'Người dùng',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      if (attendee['student_id'] != null &&
                                          attendee['student_id'].toString().isNotEmpty)
                                        Text(
                                          'MSSV: ${attendee['student_id']}',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Colors.grey[600],
                                              ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRecentActivityDetail(ClubActivity activity) async {
    final participants = await ClubLeaderService.fetchActivityParticipants(activity.id);
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
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(
                    'Chi tiết hoạt động',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.title,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          if (activity.description != null && activity.description!.isNotEmpty) ...[
                            Text(
                              activity.description!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                            ),
                            const SizedBox(height: 12),
                          ],
                          _buildDetailRow(
                            'Ngày',
                            '${activity.date.day}/${activity.date.month}/${activity.date.year}',
                            LucideIcons.calendar,
                          ),
                          const SizedBox(height: 8),
                          if (activity.location != null && activity.location!.isNotEmpty)
                            _buildDetailRow('Địa điểm', activity.location!, LucideIcons.mapPin),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.users,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Người tham gia (${participants.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (participants.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Column(
                            children: [
                              Icon(
                                LucideIcons.users,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Chưa có người tham gia',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: participants.length,
                        itemBuilder: (context, index) {
                          final participant = participants[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.purple.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  child: Text(
                                    (participant['user_name']?.toString()[0] ?? 'U').toUpperCase(),
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
                                        participant['user_name'] ?? 'Người dùng',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      if (participant['student_id'] != null &&
                                          participant['student_id'].toString().isNotEmpty)
                                        Text(
                                          'MSSV: ${participant['student_id']}',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Colors.grey[600],
                                              ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

}
