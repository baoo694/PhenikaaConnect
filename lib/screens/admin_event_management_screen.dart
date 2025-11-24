import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/event.dart';
import '../services/admin_service.dart';
import '../services/club_leader_service.dart';
import '../widgets/common_widgets.dart';
import 'admin_event_form_sheet.dart';
import 'admin_event_detail_screen.dart';

class AdminEventManagementScreen extends StatefulWidget {
  const AdminEventManagementScreen({super.key});

  @override
  State<AdminEventManagementScreen> createState() => _AdminEventManagementScreenState();
}

class _AdminEventManagementScreenState extends State<AdminEventManagementScreen> {
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
    final events = await AdminService.fetchAllEvents();
    setState(() {
      _events = events;
      _isLoading = false;
    });
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
      final success = await AdminService.deleteEvent(event.id);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa sự kiện thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
        await _loadEvents();
      }
    }
  }

  List<Event> get _filteredEvents {
    if (_searchQuery.isEmpty) return _events;
    return _events.where((event) {
      return event.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.category.toLowerCase().contains(_searchQuery.toLowerCase());
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
                      hintText: 'Tìm kiếm sự kiện...',
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
                        builder: (context) => const AdminEventFormSheet(),
                      ),
                    );
                    if (result == true) {
                      await _loadEvents();
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
          // Events list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredEvents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.calendarX, size: 64, color: Colors.grey[400]),
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
                    : RefreshIndicator(
                        onRefresh: _loadEvents,
                        child: ListView.builder(
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
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminEventDetailScreen(event: event),
            ),
          );
          if (result == true) {
            await _loadEvents();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
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
                            '${event.date} ${event.time}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                          const SizedBox(width: 12),
                          Icon(LucideIcons.mapPin, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location,
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(LucideIcons.user, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            event.organizer,
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                          const SizedBox(width: 12),
                          Icon(LucideIcons.users, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${event.attendees} người tham gia',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(LucideIcons.users, size: 16),
                            SizedBox(width: 8),
                            Text('Người tham gia'),
                          ],
                        ),
                        onTap: () {
                          Future.delayed(const Duration(milliseconds: 100), () {
                            _showEventParticipants(event);
                          });
                        },
                      ),
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(LucideIcons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Sửa'),
                        ],
                      ),
                      onTap: () async {
                        await Future.delayed(const Duration(milliseconds: 100));
                        if (mounted) {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminEventFormSheet(event: event),
                            ),
                          );
                          if (result == true) {
                            await _loadEvents();
                          }
                        }
                      },
                    ),
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(LucideIcons.trash2, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Xóa', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                      onTap: () {
                        Future.delayed(const Duration(milliseconds: 100), () {
                          _deleteEvent(event);
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEventParticipants(Event event) async {
    final participants = await ClubLeaderService.fetchEventAttendees(event.id);
    if (!mounted) return;

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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.users, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            'Chưa có người tham gia',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: participants.length,
                      itemBuilder: (context, index) {
                        final attendee = participants[index];
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
            ),
          ],
        ),
      ),
    );
  }
}

