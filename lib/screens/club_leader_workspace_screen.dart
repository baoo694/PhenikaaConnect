import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/event.dart';
import '../providers/app_provider.dart';
import '../services/club_leader_service.dart';
import '../services/supabase_service.dart';
import '../widgets/common_widgets.dart';

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
  final TextEditingController _postTitleController = TextEditingController();
  final TextEditingController _postContentController = TextEditingController();
  final TextEditingController _activityTitleController = TextEditingController();
  final TextEditingController _activityDescController = TextEditingController();
  final TextEditingController _eventTitleController = TextEditingController();
  final TextEditingController _eventDescController = TextEditingController();
  final TextEditingController _eventTimeController = TextEditingController();
  DateTime? _selectedEventDate;
  String? _selectedEventCategory;
  String? _selectedEventLocation;
  List<Map<String, dynamic>> _locations = [];
  bool _isLoadingLocations = true;

  // Search queries
  String _searchActivities = '';
  String _searchEvents = '';
  String _searchPosts = '';
  String _searchMembers = '';

  bool _isLoading = true;
  _ClubLeaderWorkspaceStateData _state = _ClubLeaderWorkspaceStateData();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    setState(() => _isLoadingLocations = true);
    final locations = await SupabaseService.getLocations();
    setState(() {
      _locations = locations;
      _isLoadingLocations = false;
    });
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
    _postTitleController.dispose();
    _postContentController.dispose();
    _activityTitleController.dispose();
    _activityDescController.dispose();
    _eventTitleController.dispose();
    _eventDescController.dispose();
    _eventTimeController.dispose();
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
        ..pendingMembers = members.where((m) => m.status != 'active').toList()
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

  Future<void> _createPost() async {
    final club = _state.club;
    final user = context.read<AppProvider>().currentUser;
    if (club == null || user == null) return;
    if (_postContentController.text.isEmpty) return;

    final success = await ClubLeaderService.createClubPost(
      clubId: club.id,
      authorId: user.id,
      content: _postContentController.text,
      title: _postTitleController.text.isEmpty ? null : _postTitleController.text,
    );

    if (success) {
      _postTitleController.clear();
      _postContentController.clear();
      await _loadData();
    }
  }

  Future<void> _createActivity() async {
    final club = _state.club;
    final user = context.read<AppProvider>().currentUser;
    if (club == null || user == null) return;
    if (_activityTitleController.text.isEmpty) return;

    final success = await ClubLeaderService.createClubActivity(
      clubId: club.id,
      creatorId: user.id,
      title: _activityTitleController.text,
      description: _activityDescController.text.isEmpty
          ? null
          : _activityDescController.text,
      date: DateTime.now().add(const Duration(days: 7)),
    );
    if (success) {
      _activityTitleController.clear();
      _activityDescController.clear();
      await _loadData();
    }
  }

  Future<void> _updateMemberStatus(ClubMember member, String status) async {
    final success = await ClubLeaderService.updateMemberStatus(
      membershipId: member.id,
      status: status,
    );
    if (success) {
      await _loadData();
    }
  }

  Future<void> _selectEventDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedEventDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedEventDate = picked;
      });
    }
  }

  Future<void> _selectEventTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _eventTimeController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _createEvent() async {
    final club = _state.club;
    final user = context.read<AppProvider>().currentUser;
    if (club == null || user == null) return;
    if (_eventTitleController.text.isEmpty ||
        _selectedEventLocation == null ||
        _selectedEventDate == null ||
        _eventTimeController.text.isEmpty ||
        _selectedEventCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await ClubLeaderService.createEvent(
      clubId: club.id,
      organizerId: user.id,
      title: _eventTitleController.text,
      description: _eventDescController.text,
      eventDate: _selectedEventDate!,
      eventTime: _eventTimeController.text,
      location: _selectedEventLocation!,
      category: _selectedEventCategory!,
      visibility: VisibilityScope.campus,
    );

    if (success) {
      _eventTitleController.clear();
      _eventDescController.clear();
      _eventTimeController.clear();
      setState(() {
        _selectedEventDate = null;
        _selectedEventCategory = null;
        _selectedEventLocation = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã tạo sự kiện. Đang chờ admin duyệt.'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Có lỗi xảy ra khi tạo sự kiện'),
          backgroundColor: Colors.red,
        ),
      );
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
                      child: RefreshIndicator(
                        onRefresh: _loadData,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildOverviewTab(),
                            _buildActivitiesTab(),
                            _buildEventsTab(),
                            _buildPostsTab(),
                            _buildMembersTab(),
                          ],
                        ),
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

  Widget _buildMembersSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thành viên',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (_state.pendingMembers.isNotEmpty)
                CustomBadge(
                  text: '${_state.pendingMembers.length} chờ duyệt',
                  type: BadgeType.warning,
                  size: BadgeSize.small,
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_state.pendingMembers.isNotEmpty) ...[
            Text(
              'Yêu cầu chờ duyệt',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            ..._state.pendingMembers.map((member) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.userId,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Vai trò: ${member.role}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(LucideIcons.x, color: Colors.red),
                        onPressed: () => _updateMemberStatus(member, 'removed'),
                        tooltip: 'Từ chối',
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.check, color: Colors.green),
                        onPressed: () => _updateMemberStatus(member, 'active'),
                        tooltip: 'Chấp nhận',
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
          ],
          if (_state.members.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Chưa có thành viên nào',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                ),
              ),
            )
          else
            ..._state.members.map((member) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          member.userId.isNotEmpty ? member.userId[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: Colors.white,
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
                              member.userId,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Vai trò: ${member.role}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildPostComposer() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.fileText,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Tạo bài viết',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomInput(
            controller: _postTitleController,
            hintText: 'Tiêu đề (tùy chọn)',
            labelText: 'Tiêu đề',
            prefixIcon: LucideIcons.type,
          ),
          const SizedBox(height: 16),
          CustomInput(
            controller: _postContentController,
            hintText: 'Viết nội dung bài viết...',
            labelText: 'Nội dung',
            prefixIcon: LucideIcons.edit,
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: CustomButton(
              text: 'Đăng bài',
              icon: LucideIcons.send,
              onPressed: _createPost,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.fileText,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Bài viết gần đây',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_state.posts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      LucideIcons.fileText,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Chưa có bài viết nào',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._state.posts.map((post) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (post.title != null && post.title!.isNotEmpty) ...[
                        Text(
                          post.title!,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        post.content,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildActivityComposer() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.calendarCheck,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Tạo hoạt động',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomInput(
            controller: _activityTitleController,
            hintText: 'Tiêu đề hoạt động',
            labelText: 'Tiêu đề',
            prefixIcon: LucideIcons.type,
          ),
          const SizedBox(height: 16),
          CustomInput(
            controller: _activityDescController,
            hintText: 'Mô tả hoạt động...',
            labelText: 'Mô tả',
            prefixIcon: LucideIcons.fileText,
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: CustomButton(
              text: 'Tạo hoạt động',
              icon: LucideIcons.plus,
              onPressed: _createActivity,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.calendarCheck,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Hoạt động sắp tới',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_state.activities.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      LucideIcons.calendarCheck,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Chưa có hoạt động nào',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._state.activities.map((activity) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          LucideIcons.calendar,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity.title,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${activity.date.toLocal().toIso8601String().substring(0, 10)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      CustomBadge(
                        text: activity.status.value,
                        type: activity.status == ApprovalStatus.approved
                            ? BadgeType.success
                            : activity.status == ApprovalStatus.pending
                                ? BadgeType.warning
                                : BadgeType.error,
                        size: BadgeSize.small,
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildEventComposer() {
    final categories = [
      'Học thuật',
      'Văn hóa',
      'Thể thao',
      'Nghề nghiệp',
    ];

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.calendar,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Tạo sự kiện',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomInput(
            controller: _eventTitleController,
            hintText: 'Tên sự kiện',
            labelText: 'Tên sự kiện',
            prefixIcon: LucideIcons.type,
          ),
          const SizedBox(height: 16),
          CustomInput(
            controller: _eventDescController,
            hintText: 'Mô tả sự kiện...',
            labelText: 'Mô tả',
            prefixIcon: LucideIcons.fileText,
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _selectEventDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Ngày',
                      prefixIcon: const Icon(LucideIcons.calendar),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _selectedEventDate != null
                          ? '${_selectedEventDate!.day}/${_selectedEventDate!.month}/${_selectedEventDate!.year}'
                          : 'Chọn ngày',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: _selectEventTime,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Giờ',
                      prefixIcon: const Icon(LucideIcons.clock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _eventTimeController.text.isEmpty ? 'Chọn giờ' : _eventTimeController.text,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingLocations)
            const Center(child: CircularProgressIndicator())
          else
            DropdownButtonFormField<String>(
              value: _selectedEventLocation,
              decoration: InputDecoration(
                labelText: 'Địa điểm',
                prefixIcon: const Icon(LucideIcons.mapPin),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _locations.map<DropdownMenuItem<String>>((location) {
                return DropdownMenuItem<String>(
                  value: location['name'] as String,
                  child: Text(location['name'] as String),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedEventLocation = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Vui lòng chọn địa điểm';
                }
                return null;
              },
            ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedEventCategory,
            decoration: InputDecoration(
              labelText: 'Danh mục',
              prefixIcon: const Icon(LucideIcons.tag),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedEventCategory = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: CustomButton(
              text: 'Tạo sự kiện',
              icon: LucideIcons.plus,
              onPressed: _createEvent,
            ),
          ),
        ],
      ),
    );
  }

  // Overview Tab
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

  // Activities Tab
  Widget _buildActivitiesTab() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildActivityComposer(),
          const SizedBox(height: 24),
          _buildActivitiesManagementList(),
        ],
      ),
    );
  }

  // Events Tab
  Widget _buildEventsTab() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEventComposer(),
          const SizedBox(height: 24),
          _buildEventsManagementList(),
        ],
      ),
    );
  }

  // Posts Tab
  Widget _buildPostsTab() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostComposer(),
          const SizedBox(height: 24),
          _buildPostsManagementList(),
        ],
      ),
    );
  }

  // Members Tab
  Widget _buildMembersTab() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMembersSection(),
        ],
      ),
    );
  }

  Widget _buildSearchSection(String title, String query, Function(String) onChanged, IconData icon) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Tìm kiếm $title',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Nhập từ khóa tìm kiếm...',
              prefixIcon: const Icon(LucideIcons.search),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => onChanged(''),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSearchResults() {
    final filtered = _searchMembers.isEmpty
        ? _state.members
        : _state.members.where((m) {
            return m.userId.toLowerCase().contains(_searchMembers.toLowerCase());
          }).toList();

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kết quả tìm kiếm thành viên (${filtered.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Không tìm thấy thành viên nào',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            ...filtered.map((member) => _buildMemberCard(member)),
        ],
      ),
    );
  }

  Widget _buildActivitiesSearchResults() {
    final filtered = _searchActivities.isEmpty
        ? _state.activities
        : _state.activities.where((a) {
            return a.title.toLowerCase().contains(_searchActivities.toLowerCase()) ||
                (a.description?.toLowerCase().contains(_searchActivities.toLowerCase()) ?? false);
          }).toList();

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kết quả tìm kiếm hoạt động (${filtered.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Không tìm thấy hoạt động nào',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            ...filtered.map((activity) => _buildActivityCard(activity, showActions: false)),
        ],
      ),
    );
  }

  Widget _buildEventsSearchResults() {
    final filtered = _searchEvents.isEmpty
        ? _state.events
        : _state.events.where((e) {
            return e.title.toLowerCase().contains(_searchEvents.toLowerCase()) ||
                (e.description?.toLowerCase().contains(_searchEvents.toLowerCase()) ?? false) ||
                e.location.toLowerCase().contains(_searchEvents.toLowerCase());
          }).toList();

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kết quả tìm kiếm sự kiện (${filtered.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Không tìm thấy sự kiện nào',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            ...filtered.map((event) => _buildEventCard(event, showActions: false)),
        ],
      ),
    );
  }

  Widget _buildPostsSearchResults() {
    final filtered = _searchPosts.isEmpty
        ? _state.posts
        : _state.posts.where((p) {
            return (p.title?.toLowerCase().contains(_searchPosts.toLowerCase()) ?? false) ||
                p.content.toLowerCase().contains(_searchPosts.toLowerCase());
          }).toList();

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kết quả tìm kiếm bài viết (${filtered.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Không tìm thấy bài viết nào',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            ...filtered.map((post) => _buildPostCard(post, showActions: false)),
        ],
      ),
    );
  }

  Widget _buildManagementSection(String title, IconData icon, Widget composer, Widget list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              'Quản lý $title',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        composer,
        const SizedBox(height: 16),
        list,
      ],
    );
  }

  Widget _buildActivitiesManagementList() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danh sách hoạt động',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          if (_state.activities.isEmpty)
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
            ..._state.activities.map((activity) => _buildActivityCard(activity, showActions: true)),
        ],
      ),
    );
  }

  Widget _buildEventsManagementList() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danh sách sự kiện',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          if (_state.events.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Chưa có sự kiện nào',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            ..._state.events.map((event) => _buildEventCard(event, showActions: true)),
        ],
      ),
    );
  }

  Widget _buildPostsManagementList() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danh sách bài viết',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          if (_state.posts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Chưa có bài viết nào',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            ..._state.posts.map((post) => _buildPostCard(post, showActions: true)),
        ],
      ),
    );
  }

  Widget _buildMemberCard(ClubMember member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.userId,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Vai trò: ${member.role}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(ClubActivity activity, {required bool showActions}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  activity.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              if (showActions) ...[
                IconButton(
                  icon: const Icon(LucideIcons.edit, size: 18),
                  color: Colors.blue,
                  onPressed: () => _editActivity(activity),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.trash2, size: 18),
                  color: Colors.red,
                  onPressed: () => _deleteActivity(activity),
                ),
              ],
            ],
          ),
          if (activity.description != null && activity.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              activity.description!,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(LucideIcons.calendar, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${activity.date.day}/${activity.date.month}/${activity.date.year}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              if (activity.location != null && activity.location!.isNotEmpty) ...[
                const SizedBox(width: 12),
                Icon(LucideIcons.mapPin, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  activity.location!,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Event event, {required bool showActions}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              if (showActions) ...[
                IconButton(
                  icon: const Icon(LucideIcons.edit, size: 18),
                  color: Colors.blue,
                  onPressed: () => _editEvent(event),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.trash2, size: 18),
                  color: Colors.red,
                  onPressed: () => _deleteEvent(event),
                ),
              ],
            ],
          ),
          if (event.description != null && event.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              event.description!,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(LucideIcons.calendar, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${event.date} ${event.time}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(width: 12),
              Icon(LucideIcons.mapPin, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  event.location,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(ClubPost post, {required bool showActions}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (post.title != null && post.title!.isNotEmpty)
                      Text(
                        post.title!,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                  ],
                ),
              ),
              if (showActions) ...[
                IconButton(
                  icon: const Icon(LucideIcons.edit, size: 18),
                  color: Colors.blue,
                  onPressed: () => _editPost(post),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.trash2, size: 18),
                  color: Colors.red,
                  onPressed: () => _deletePost(post),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            post.content,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Future<void> _editActivity(ClubActivity activity) async {
    final titleController = TextEditingController(text: activity.title);
    final descController = TextEditingController(text: activity.description ?? '');
    final locationController = TextEditingController(text: activity.location ?? '');
    DateTime selectedDate = activity.date;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa hoạt động'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    selectedDate = picked;
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Ngày',
                    border: OutlineInputBorder(),
                  ),
                  child: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Địa điểm',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    if (result == true) {
      if (titleController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng nhập tiêu đề'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final success = await ClubLeaderService.updateClubActivity(
        activityId: activity.id,
        title: titleController.text,
        date: selectedDate,
        description: descController.text.isEmpty ? null : descController.text,
        location: locationController.text.isEmpty ? null : locationController.text,
      );

      if (success) {
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã cập nhật hoạt động thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Có lỗi xảy ra khi cập nhật hoạt động'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteActivity(ClubActivity activity) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa hoạt động "${activity.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ClubLeaderService.deleteClubActivity(activity.id);
      if (success) {
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa hoạt động thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Có lỗi xảy ra khi xóa hoạt động'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _editEvent(Event event) async {
    final titleController = TextEditingController(text: event.title);
    final descController = TextEditingController(text: event.description ?? '');
    final maxAttendeesController = TextEditingController(
      text: event.maxAttendees?.toString() ?? '',
    );
    final timeController = TextEditingController(text: event.time);
    
    DateTime? selectedDate;
    try {
      selectedDate = DateTime.parse(event.date);
    } catch (e) {
      selectedDate = DateTime.now();
    }
    
    String? selectedLocation = event.location;
    String? selectedCategory = event.category;
    
    final categories = [
      'Học thuật',
      'Văn hóa',
      'Thể thao',
      'Nghề nghiệp',
    ];

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Sửa sự kiện'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Tên sự kiện',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setDialogState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Ngày',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            selectedDate != null
                                ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                                : 'Chọn ngày',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            timeController.text =
                                '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Giờ',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            timeController.text.isEmpty ? 'Chọn giờ' : timeController.text,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_isLoadingLocations)
                  const CircularProgressIndicator()
                else
                  DropdownButtonFormField<String>(
                    value: selectedLocation,
                    decoration: const InputDecoration(
                      labelText: 'Địa điểm',
                      border: OutlineInputBorder(),
                    ),
                    items: _locations.map<DropdownMenuItem<String>>((location) {
                      return DropdownMenuItem<String>(
                        value: location['name'] as String,
                        child: Text(location['name'] as String),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedLocation = value;
                      });
                    },
                  ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Danh mục',
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedCategory = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: maxAttendeesController,
                  decoration: const InputDecoration(
                    labelText: 'Số lượng tối đa (tùy chọn)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      if (titleController.text.isEmpty ||
          selectedLocation == null ||
          selectedDate == null ||
          timeController.text.isEmpty ||
          selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng điền đầy đủ thông tin'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final success = await ClubLeaderService.updateEvent(
        eventId: event.id,
        title: titleController.text,
        description: descController.text,
        eventDate: selectedDate!,
        eventTime: timeController.text,
        location: selectedLocation!,
        category: selectedCategory!,
        maxAttendees: maxAttendeesController.text.isEmpty
            ? null
            : int.tryParse(maxAttendeesController.text),
      );

      if (success) {
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã cập nhật sự kiện thành công. Đang chờ admin duyệt lại.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Có lỗi xảy ra khi cập nhật sự kiện'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteEvent(Event event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa sự kiện "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ClubLeaderService.deleteEvent(event.id);
      if (success) {
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa sự kiện thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Có lỗi xảy ra khi xóa sự kiện'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _editPost(ClubPost post) async {
    final titleController = TextEditingController(text: post.title ?? '');
    final contentController = TextEditingController(text: post.content);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa bài viết'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề (tùy chọn)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Nội dung',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    if (result == true) {
      if (contentController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng nhập nội dung'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final success = await ClubLeaderService.updateClubPost(
        postId: post.id,
        content: contentController.text,
        title: titleController.text.isEmpty ? null : titleController.text,
      );

      if (success) {
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã cập nhật bài viết thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Có lỗi xảy ra khi cập nhật bài viết'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deletePost(ClubPost post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa bài viết này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ClubLeaderService.deleteClubPost(post.id);
      if (success) {
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa bài viết thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Có lỗi xảy ra khi xóa bài viết'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildEventsSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.calendar,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Sự kiện của CLB',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_state.events.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      LucideIcons.calendar,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Chưa có sự kiện nào',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._state.events.map((event) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          CustomBadge(
                            text: event.status == ApprovalStatus.approved
                                ? 'Đã duyệt'
                                : event.status == ApprovalStatus.pending
                                    ? 'Chờ duyệt'
                                    : 'Từ chối',
                            type: event.status == ApprovalStatus.approved
                                ? BadgeType.success
                                : event.status == ApprovalStatus.pending
                                    ? BadgeType.warning
                                    : BadgeType.error,
                            size: BadgeSize.small,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.calendar,
                            size: 16,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${event.date} ${event.time}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.mapPin,
                            size: 16,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event.location,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}

