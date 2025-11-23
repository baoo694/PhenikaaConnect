import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../services/club_leader_service.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';
import 'club_leader_activity_form_sheet.dart';
import 'club_activity_detail_screen.dart';

class ClubLeaderActivitiesScreen extends StatefulWidget {
  final String clubId;

  const ClubLeaderActivitiesScreen({super.key, required this.clubId});

  @override
  State<ClubLeaderActivitiesScreen> createState() => _ClubLeaderActivitiesScreenState();
}

class _ClubLeaderActivitiesScreenState extends State<ClubLeaderActivitiesScreen> {
  bool _isLoading = true;
  List<ClubActivity> _activities = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() => _isLoading = true);
    final activities = await ClubLeaderService.fetchActivities(widget.clubId);
    setState(() {
      _activities = activities;
      _isLoading = false;
    });
  }

  Future<void> _createActivity() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClubLeaderActivityFormSheet(clubId: widget.clubId),
      ),
    );
    if (result == true) {
      await _loadActivities();
    }
  }

  Future<void> _editActivity(ClubActivity activity) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClubLeaderActivityFormSheet(activity: activity, clubId: widget.clubId),
      ),
    );
    if (result == true) {
      await _loadActivities();
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
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa hoạt động thành công'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadActivities();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Có lỗi xảy ra khi xóa hoạt động'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showActivityDetail(ClubActivity activity) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ClubActivityDetailScreen(
          activity: activity,
          onEdit: () => _editActivity(activity),
          onDelete: () => _deleteActivity(activity),
          onViewParticipants: () => _showActivityParticipants(activity),
        ),
      ),
    );
  }

  Future<void> _showActivityParticipants(ClubActivity activity) async {
    final participants = await ClubLeaderService.fetchActivityParticipants(activity.id);
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Người tham gia',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${participants.length} người',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: participants.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.users,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Chưa có người tham gia',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: participants.length,
                        itemBuilder: (context, index) {
                          final participant = participants[index];
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
                                if (participant['avatar_url'] != null)
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage: NetworkImage(participant['avatar_url']),
                                  )
                                else
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    child: Text(
                                      (participant['user_name']?.toString()[0] ?? 'U').toUpperCase(),
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
                                        participant['user_name'] ?? 'Người dùng',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (participant['student_id'] != null && participant['student_id'].toString().isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'MSSV: ${participant['student_id']}',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
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
      ),
    );
  }

  List<ClubActivity> get _filteredActivities {
    if (_searchQuery.isEmpty) return _activities;
    return _activities.where((a) {
      return a.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (a.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: null,
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar and plus button in one row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm hoạt động...',
                      prefixIcon: const Icon(LucideIcons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
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
                const SizedBox(width: 12),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(LucideIcons.plus, color: Colors.white),
                    tooltip: 'Tạo hoạt động mới',
                    onPressed: _createActivity,
                  ),
                ),
              ],
            ),
          ),
          // Activities list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadActivities,
                    child: _filteredActivities.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(LucideIcons.calendarCheck, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'Chưa có hoạt động nào'
                                      : 'Không tìm thấy hoạt động',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredActivities.length,
                            itemBuilder: (context, index) {
                              final activity = _filteredActivities[index];
                              return _buildActivityCard(activity);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(ClubActivity activity) {
    return InkWell(
      onTap: () => _showActivityDetail(activity),
      child: Container(
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
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _showActivityParticipants(activity),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.users,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Xem người tham gia',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
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
}

