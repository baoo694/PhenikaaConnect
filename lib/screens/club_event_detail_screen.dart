import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/event.dart';
import '../widgets/common_widgets.dart';

class ClubEventDetailScreen extends StatelessWidget {
  final Event event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewAttendees;

  const ClubEventDetailScreen({
    super.key,
    required this.event,
    required this.onEdit,
    required this.onDelete,
    required this.onViewAttendees,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'văn hóa':
      case 'van hoa':
        return LucideIcons.music;
      case 'thể thao':
      case 'the thao':
        return LucideIcons.activity;
      case 'học thuật':
      case 'hoc thuat':
        return LucideIcons.bookOpen;
      case 'tình nguyện':
      case 'tinh nguyen':
        return LucideIcons.heart;
      default:
        return LucideIcons.calendar;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'văn hóa':
      case 'van hoa':
        return Colors.green;
      case 'thể thao':
      case 'the thao':
        return Colors.orange;
      case 'học thuật':
      case 'hoc thuat':
        return Colors.blue;
      case 'tình nguyện':
      case 'tinh nguyen':
        return Colors.pink;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(event.category);
    final categoryIcon = _getCategoryIcon(event.category);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.edit),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(LucideIcons.trash2),
                color: Colors.red,
                onPressed: onDelete,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: null,
              centerTitle: false,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      categoryColor,
                      categoryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          categoryIcon,
                          size: 64,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          event.category,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Chi tiết sự kiện',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tags
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        CustomBadge(
                          text: event.category,
                          type: BadgeType.primary,
                          size: BadgeSize.small,
                        ),
                        CustomBadge(
                          text: '${event.attendees} người tham gia',
                          type: BadgeType.outline,
                          size: BadgeSize.small,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Event ID/Title
                    Text(
                      event.title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Organizer
                    _buildDetailRow(
                      context,
                      icon: LucideIcons.user,
                      label: 'Tổ chức bởi',
                      value: event.organizer,
                    ),
                    const SizedBox(height: 16),
                    // Description
                    if (event.description != null && event.description!.isNotEmpty) ...[
                      Text(
                        'Mô tả',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.description!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                    ],
                    // Date and Time
                    _buildDetailRow(
                      context,
                      icon: LucideIcons.calendar,
                      label: 'Ngày và giờ',
                      value: '${event.date} • ${event.time}',
                    ),
                    const SizedBox(height: 16),
                    // Location
                    _buildDetailRow(
                      context,
                      icon: LucideIcons.mapPin,
                      label: 'Địa điểm',
                      value: event.location,
                    ),
                    const SizedBox(height: 16),
                    // Max Attendees
                    if (event.maxAttendees != null)
                      _buildDetailRow(
                        context,
                        icon: LucideIcons.users,
                        label: 'Số người tối đa',
                        value: '${event.maxAttendees} người',
                      ),
                    const SizedBox(height: 16),
                    // Club
                    if (event.clubName != null && event.clubName!.isNotEmpty)
                      _buildDetailRow(
                        context,
                        icon: LucideIcons.users,
                        label: 'CLB',
                        value: event.clubName!,
                      ),
                    const SizedBox(height: 16),
                    // Status
                    _buildDetailRow(
                      context,
                      icon: LucideIcons.info,
                      label: 'Trạng thái',
                      value: event.status.value,
                    ),
                    const SizedBox(height: 24),
                    // View Attendees Button
                    CustomButton(
                      text: 'Xem người tham gia',
                      icon: LucideIcons.users,
                      onPressed: onViewAttendees,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

