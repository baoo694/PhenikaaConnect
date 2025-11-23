import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../services/club_leader_service.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';
import 'club_leader_event_form_sheet.dart';
import 'club_event_detail_screen.dart';

class ClubLeaderEventsScreen extends StatefulWidget {
  final String clubId;

  const ClubLeaderEventsScreen({super.key, required this.clubId});

  @override
  State<ClubLeaderEventsScreen> createState() => _ClubLeaderEventsScreenState();
}

class _ClubLeaderEventsScreenState extends State<ClubLeaderEventsScreen> {
  bool _isLoading = true;
  List<Event> _events = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    final events = await ClubLeaderService.fetchClubEvents(widget.clubId);
    setState(() {
      _events = events;
      _isLoading = false;
    });
  }

  Future<void> _createEvent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClubLeaderEventFormSheet(clubId: widget.clubId),
      ),
    );
    if (result == true) {
      await _loadEvents();
    }
  }

  Future<void> _editEvent(Event event) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClubLeaderEventFormSheet(event: event, clubId: widget.clubId),
      ),
    );
    if (result == true) {
      await _loadEvents();
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
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa sự kiện thành công'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadEvents();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Có lỗi xảy ra khi xóa sự kiện'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showEventDetail(Event event) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ClubEventDetailScreen(
          event: event,
          onEdit: () => _editEvent(event),
          onDelete: () => _deleteEvent(event),
          onViewAttendees: () => _showEventAttendees(event),
        ),
      ),
    );
  }

  Future<void> _showEventAttendees(Event event) async {
    final attendees = await ClubLeaderService.fetchEventAttendees(event.id);
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
                    '${attendees.length} người',
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
                child: attendees.isEmpty
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
                        itemCount: attendees.length,
                        itemBuilder: (context, index) {
                          final attendee = attendees[index];
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
                                if (attendee['avatar_url'] != null)
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage: NetworkImage(attendee['avatar_url']),
                                  )
                                else
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    child: Text(
                                      (attendee['user_name']?.toString()[0] ?? 'U').toUpperCase(),
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
                                        attendee['user_name'] ?? 'Người dùng',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (attendee['student_id'] != null && attendee['student_id'].toString().isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'MSSV: ${attendee['student_id']}',
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

  List<Event> get _filteredEvents {
    if (_searchQuery.isEmpty) return _events;
    return _events.where((e) {
      return e.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (e.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          e.location.toLowerCase().contains(_searchQuery.toLowerCase());
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
                      hintText: 'Tìm kiếm sự kiện...',
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
                    tooltip: 'Tạo sự kiện mới',
                    onPressed: _createEvent,
                  ),
                ),
              ],
            ),
          ),
          // Events list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadEvents,
                    child: _filteredEvents.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(LucideIcons.calendar, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'Chưa có sự kiện nào'
                                      : 'Không tìm thấy sự kiện',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredEvents.length,
                            itemBuilder: (context, index) {
                              final event = _filteredEvents[index];
                              return _buildEventCard(event);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return InkWell(
      onTap: () => _showEventDetail(event),
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
                    event.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
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
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(LucideIcons.users, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${event.attendees} người tham gia',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                if (event.maxAttendees != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '/ ${event.maxAttendees} tối đa',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _showEventAttendees(event),
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

