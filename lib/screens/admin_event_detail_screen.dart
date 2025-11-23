import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/event.dart';
import '../services/admin_service.dart';
import '../widgets/common_widgets.dart';
import 'admin_event_form_sheet.dart';

class AdminEventDetailScreen extends StatefulWidget {
  final Event event;

  const AdminEventDetailScreen({
    super.key,
    required this.event,
  });

  @override
  State<AdminEventDetailScreen> createState() => _AdminEventDetailScreenState();
}

class _AdminEventDetailScreenState extends State<AdminEventDetailScreen> {
  late Event _currentEvent;
  bool _isLoading = false;
  String? _clubName;

  @override
  void initState() {
    super.initState();
    _currentEvent = widget.event;
    _loadClubName();
  }

  Future<void> _loadClubName() async {
    if (_currentEvent.clubId != null && _currentEvent.clubId!.isNotEmpty) {
      try {
        final clubDetails = await AdminService.fetchClubDetails(_currentEvent.clubId!);
        if (clubDetails != null && mounted) {
          setState(() {
            _clubName = clubDetails['name'] as String?;
          });
        }
      } catch (e) {
        print('Error loading club name: $e');
      }
    }
  }

  Future<void> _deleteEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa sự kiện "${_currentEvent.title}"?'),
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
      setState(() => _isLoading = true);
      final success = await AdminService.deleteEvent(_currentEvent.id);
      setState(() => _isLoading = false);

      if (success) {
        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate deletion
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

  Future<void> _editEvent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminEventFormSheet(event: _currentEvent),
      ),
    );

    if (result == true && mounted) {
      // Reload event data
      final events = await AdminService.fetchAllEvents();
      final updatedEvent = events.firstWhere(
        (e) => e.id == _currentEvent.id,
        orElse: () => _currentEvent,
      );
      setState(() {
        _currentEvent = updatedEvent;
      });
    }
  }

  Widget _buildEventImagePlaceholder(BuildContext context) {
    // Map categories to gradient colors and icons
    final categoryConfig = {
      'Học thuật': {
        'gradient': [Color(0xFF3B82F6), Color(0xFF2563EB)],
        'icon': LucideIcons.graduationCap,
      },
      'Văn hóa': {
        'gradient': [Color(0xFF10B981), Color(0xFF059669)],
        'icon': LucideIcons.music,
      },
      'Thể thao': {
        'gradient': [Color(0xFFEF4444), Color(0xFFDC2626)],
        'icon': LucideIcons.activity,
      },
      'Nghề nghiệp': {
        'gradient': [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
        'icon': LucideIcons.briefcase,
      },
      'Khởi nghiệp': {
        'gradient': [Color(0xFFF59E0B), Color(0xFFD97706)],
        'icon': LucideIcons.zap,
      },
    };

    final config = categoryConfig[_currentEvent.category] ??
        {
          'gradient': [Color(0xFF6366F1), Color(0xFF4F46E5)],
          'icon': LucideIcons.calendar,
        };

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: List<Color>.from(config['gradient'] as List),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              config['icon'] as IconData,
              size: 80,
              color: Colors.white.withOpacity(0.9),
            ),
            const SizedBox(height: 16),
            Text(
              _currentEvent.category,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sự kiện',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sự kiện'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.edit),
            onPressed: _isLoading ? null : _editEvent,
            tooltip: 'Sửa',
          ),
          IconButton(
            icon: const Icon(LucideIcons.trash2),
            onPressed: _isLoading ? null : _deleteEvent,
            tooltip: 'Xóa',
            color: Colors.red,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Image
                  Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                    ),
                    child: _currentEvent.image.isNotEmpty
                        ? Image.network(
                            _currentEvent.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildEventImagePlaceholder(context);
                            },
                          )
                        : _buildEventImagePlaceholder(context),
                  ),

                  // Event Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badges
                        Row(
                          children: [
                            CustomBadge(
                              text: _currentEvent.category,
                              type: BadgeType.primary,
                              size: BadgeSize.small,
                            ),
                            const SizedBox(width: 8),
                            CustomBadge(
                              text: '${_currentEvent.attendees} người tham gia',
                              type: BadgeType.outline,
                              size: BadgeSize.small,
                            ),
                            const SizedBox(width: 8),
                            CustomBadge(
                              text: _currentEvent.visibility.value,
                              type: BadgeType.outline,
                              size: BadgeSize.small,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Title
                        Text(
                          _currentEvent.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),

                        const SizedBox(height: 8),

                        // Organizer
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.user,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tổ chức bởi ${_currentEvent.organizer}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                            ),
                          ],
                        ),

                        // Description
                        if (_currentEvent.description != null && _currentEvent.description!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Mô tả',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currentEvent.description!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Date & Time
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.calendar,
                              size: 20,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ngày và giờ',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_currentEvent.date} • ${_currentEvent.time}',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Location
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.mapPin,
                              size: 20,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Địa điểm',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _currentEvent.location,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Max Attendees
                        if (_currentEvent.maxAttendees != null) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.users,
                                size: 20,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Số người tối đa',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_currentEvent.maxAttendees} người',
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],

                        if (_currentEvent.clubId != null) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.users,
                                size: 20,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'CLB',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _clubName ?? 'Đang tải...',
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Status
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.info,
                              size: 20,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Trạng thái',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _currentEvent.status.value,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
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
                ],
              ),
            ),
    );
  }
}

