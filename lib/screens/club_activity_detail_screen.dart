import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/event.dart';
import '../widgets/common_widgets.dart';

class ClubActivityDetailScreen extends StatelessWidget {
  final ClubActivity activity;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewParticipants;

  const ClubActivityDetailScreen({
    super.key,
    required this.activity,
    required this.onEdit,
    required this.onDelete,
    required this.onViewParticipants,
  });

  IconData _getCategoryIcon() {
    return LucideIcons.calendar;
  }

  Color _getCategoryColor() {
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
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
                      _getCategoryColor(),
                      _getCategoryColor().withOpacity(0.8),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getCategoryIcon(),
                          size: 64,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Hoạt động',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Chi tiết hoạt động',
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
                        text: 'Hoạt động',
                        type: BadgeType.primary,
                        size: BadgeSize.small,
                      ),
                      CustomBadge(
                        text: '${activity.date.day}/${activity.date.month}/${activity.date.year}',
                        type: BadgeType.outline,
                        size: BadgeSize.small,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Title
                  Text(
                    activity.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Description
                  if (activity.description != null && activity.description!.isNotEmpty) ...[
                    Text(
                      'Mô tả',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      activity.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Date
                  _buildDetailRow(
                    context,
                    icon: LucideIcons.calendar,
                    label: 'Ngày và giờ',
                    value: '${activity.date.day}/${activity.date.month}/${activity.date.year} ${activity.date.hour.toString().padLeft(2, '0')}:${activity.date.minute.toString().padLeft(2, '0')}',
                  ),
                  const SizedBox(height: 16),
                  // Location
                  if (activity.location != null && activity.location!.isNotEmpty)
                    _buildDetailRow(
                      context,
                      icon: LucideIcons.mapPin,
                      label: 'Địa điểm',
                      value: activity.location!,
                    ),
                  const SizedBox(height: 24),
                  // View Participants Button
                  CustomButton(
                    text: 'Xem người tham gia',
                    icon: LucideIcons.users,
                    onPressed: onViewParticipants,
                  ),
                ],
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

