import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/event.dart';
import '../models/user.dart' as app_models;
import '../services/admin_service.dart';
import '../widgets/common_widgets.dart';
import 'admin_event_management_screen.dart';
import 'admin_user_management_screen.dart';
import 'admin_club_management_screen.dart';
import 'admin_announcement_form_sheet.dart';
import 'admin_announcement_detail_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  List<Club> _pendingClubs = [];
  List<Event> _pendingEvents = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final results = await Future.wait([
      AdminService.fetchDashboardStats(),
      AdminService.fetchPendingClubs(),
      AdminService.fetchPendingEvents(),
    ]);

    setState(() {
      _stats = results[0] as Map<String, dynamic>;
      _pendingClubs = results[1] as List<Club>;
      _pendingEvents = results[2] as List<Event>;
      _isLoading = false;
    });
  }

  Future<void> _reviewClub(Club club, bool approved) async {
    final success = await AdminService.reviewClub(
      clubId: club.id,
      approved: approved,
    );
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(approved
                ? 'Đã duyệt câu lạc bộ ${club.name}'
                : 'Đã từ chối câu lạc bộ ${club.name}'),
            backgroundColor: approved ? Colors.green : Colors.orange,
          ),
        );
      }
      await _loadData();
    }
  }

  Future<void> _reviewEvent(Event event, bool approved) async {
    final success = await AdminService.reviewEvent(
      eventId: event.id,
      approved: approved,
    );
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(approved
                ? 'Đã duyệt sự kiện ${event.title}'
                : 'Đã từ chối sự kiện ${event.title}'),
            backgroundColor: approved ? Colors.green : Colors.orange,
          ),
        );
      }
      await _loadData();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng điều hành Admin'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(icon: Icon(LucideIcons.layoutDashboard), text: 'Tổng quan'),
              Tab(icon: Icon(LucideIcons.bell), text: 'Thông báo'),
              Tab(icon: Icon(LucideIcons.calendar), text: 'Sự kiện'),
              Tab(icon: Icon(LucideIcons.users), text: 'Người dùng'),
              Tab(icon: Icon(LucideIcons.users), text: 'Câu lạc bộ'),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildAnnouncementsTab(),
                const AdminEventManagementScreen(),
                const AdminUserManagementScreen(),
                const AdminClubManagementScreen(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsSection(),
            const SizedBox(height: 24),
            _buildApprovalsSection(),
            const SizedBox(height: 24),
            _buildQuickActionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng quan hệ thống',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.refreshCw),
                onPressed: _loadData,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Sinh viên',
                  _stats['users'] ?? 0,
                  Colors.blue,
                  LucideIcons.users,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'CLB',
                  _stats['clubs'] ?? 0,
                  Colors.green,
                  LucideIcons.users,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Sự kiện',
                  _stats['events'] ?? 0,
                  Colors.orange,
                  LucideIcons.calendar,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Thành viên CLB',
                  _stats['memberships'] ?? 0,
                  Colors.purple,
                  LucideIcons.userPlus,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  value.toString(),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalsSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Phê duyệt chờ xử lý',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (_pendingClubs.isNotEmpty || _pendingEvents.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_pendingClubs.length + _pendingEvents.length}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_pendingClubs.isEmpty && _pendingEvents.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(LucideIcons.checkCircle2, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'Không có yêu cầu chờ duyệt',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          if (_pendingEvents.isNotEmpty) ...[
            _buildSectionHeader('Sự kiện (${_pendingEvents.length})'),
            const SizedBox(height: 8),
            ..._pendingEvents.map((event) => _buildEventApprovalItem(event)),
            if (_pendingClubs.isNotEmpty) const SizedBox(height: 16),
          ],
          if (_pendingClubs.isNotEmpty) ...[
            if (_pendingEvents.isNotEmpty) const SizedBox(height: 8),
            _buildSectionHeader('Câu lạc bộ (${_pendingClubs.length})'),
            const SizedBox(height: 8),
            ..._pendingClubs.map((club) => _buildClubApprovalItem(club)),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildEventApprovalItem(Event event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                if (event.description != null && event.description!.isNotEmpty)
                  Text(
                    event.description!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(LucideIcons.calendar, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${event.date} ${event.time}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(LucideIcons.mapPin, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        event.location,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(LucideIcons.tag, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      event.category,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => _reviewEvent(event, false),
                tooltip: 'Từ chối',
              ),
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () => _reviewEvent(event, true),
                tooltip: 'Duyệt',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClubApprovalItem(Club club) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  club.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  club.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(LucideIcons.users, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${club.members} thành viên',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(LucideIcons.tag, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      club.category,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => _reviewClub(club, false),
                tooltip: 'Từ chối',
              ),
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () => _reviewClub(club, true),
                tooltip: 'Duyệt',
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildQuickActionsSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thao tác nhanh',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildQuickActionButton(
                'Gửi thông báo',
                LucideIcons.bell,
                Colors.blue,
                () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminAnnouncementFormSheet(),
                    ),
                  );
                  if (result == true) {
                    // Reload if needed
                  }
                },
              ),
              _buildQuickActionButton(
                'Thêm sự kiện',
                LucideIcons.calendarPlus,
                Colors.orange,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminEventManagementScreen(),
                    ),
                  );
                },
              ),
              _buildQuickActionButton(
                'Quản lý người dùng',
                LucideIcons.users,
                Colors.green,
                () {
                  _tabController.animateTo(3);
                },
              ),
              _buildQuickActionButton(
                'Quản lý CLB',
                LucideIcons.users,
                Colors.purple,
                () {
                  _tabController.animateTo(4);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementsTab() {
    return _AnnouncementsTabContent();
  }
}

class _AnnouncementsTabContent extends StatefulWidget {
  @override
  State<_AnnouncementsTabContent> createState() => _AnnouncementsTabContentState();
}

class _AnnouncementsTabContentState extends State<_AnnouncementsTabContent> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _announcements = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    setState(() => _isLoading = true);
    final announcements = await AdminService.fetchAnnouncements();
    setState(() {
      _announcements = announcements;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredAnnouncements {
    if (_searchQuery.isEmpty) return _announcements;
    return _announcements.where((announcement) {
      final title = (announcement['title'] ?? '').toString().toLowerCase();
      final description = (announcement['description'] ?? '').toString().toLowerCase();
      final category = (announcement['category'] ?? '').toString().toLowerCase();
      final createdBy = announcement['users'];
      final creatorName = createdBy != null && createdBy is Map
          ? (createdBy['name'] ?? '').toString().toLowerCase()
          : '';
      final query = _searchQuery.toLowerCase();
      return title.contains(query) ||
          description.contains(query) ||
          category.contains(query) ||
          creatorName.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm thông báo...',
                      prefixIcon: const Icon(LucideIcons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(LucideIcons.plus),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminAnnouncementFormSheet(),
                      ),
                    );
                    if (result == true) {
                      await _loadAnnouncements();
                    }
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Announcements list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadAnnouncements,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredAnnouncements.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.bell,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty
                                    ? 'Chưa có thông báo nào'
                                    : 'Không tìm thấy thông báo',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredAnnouncements.length,
                          itemBuilder: (context, index) {
                            final announcement = _filteredAnnouncements[index];
                            return _buildAnnouncementCard(announcement);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(Map<String, dynamic> announcement) {
    final category = announcement['category'] ?? 'Khác';
    final priority = announcement['priority'] ?? 'normal';
    final createdBy = announcement['users'];
    final createdAt = announcement['created_at'];
    
    String priorityLabel;
    Color priorityColor;
    switch (priority) {
      case 'high':
        priorityLabel = 'Khẩn cấp';
        priorityColor = Colors.red;
        break;
      case 'low':
        priorityLabel = 'Thấp';
        priorityColor = Colors.grey;
        break;
      default:
        priorityLabel = 'Thông thường';
        priorityColor = Colors.blue;
    }

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminAnnouncementDetailScreen(
              announcementId: announcement['id'] ?? '',
            ),
          ),
        );
        if (result == true) {
          // Reload if announcement was deleted
          await _loadAnnouncements();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  announcement['title'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  priorityLabel,
                  style: TextStyle(
                    color: priorityColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            announcement['content'] ?? '',
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Chip(
                label: Text(category),
                labelStyle: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 8),
              if (createdBy != null)
                Text(
                  'Bởi: ${createdBy['name'] ?? ''}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              const Spacer(),
              if (createdAt != null)
                Text(
                  _formatTimeAgo(createdAt.toString()),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
            ],
          ),
        ],
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
