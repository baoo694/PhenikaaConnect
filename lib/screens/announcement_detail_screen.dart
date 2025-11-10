import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/common_widgets.dart';

class AnnouncementDetailScreen extends StatelessWidget {
  final Map<String, dynamic> announcement;

  const AnnouncementDetailScreen({
    super.key,
    required this.announcement,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết thông báo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildContent(context),
            const SizedBox(height: 24),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (announcement['important'] == true) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  announcement['title'] ?? 'Không có tiêu đề',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CustomBadge(
                text: announcement['category'] ?? 'Khác',
                type: BadgeType.outline,
                size: BadgeSize.small,
              ),
              const SizedBox(width: 8),
              if (announcement['priority'] == 'high')
                CustomBadge(
                  text: 'Quan trọng',
                  type: BadgeType.primary,
                  size: BadgeSize.small,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
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
                'Nội dung thông báo',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            announcement['content'] ?? 'Không có nội dung',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return CustomCard(
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
                'Thông tin thông báo',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            context,
            LucideIcons.user,
            'Người đăng',
            announcement['author'] ?? 'Hệ thống',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            LucideIcons.clock,
            'Thời gian đăng',
            announcement['time'] ?? 'Không xác định',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            LucideIcons.users,
            'Đối tượng',
            _getTargetAudienceText(announcement['target_audience']),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            LucideIcons.flag,
            'Mức độ ưu tiên',
            _getPriorityText(announcement['priority']),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
            ),
          ),
        ),
      ],
    );
  }

  String _getTargetAudienceText(String? targetAudience) {
    switch (targetAudience) {
      case 'all':
        return 'Tất cả sinh viên';
      case 'specific_major':
        return 'Sinh viên chuyên ngành cụ thể';
      case 'specific_year':
        return 'Sinh viên năm cụ thể';
      default:
        return 'Không xác định';
    }
  }

  String _getPriorityText(String? priority) {
    switch (priority) {
      case 'high':
        return 'Cao (Quan trọng)';
      case 'normal':
        return 'Bình thường';
      case 'low':
        return 'Thấp';
      case 'urgent':
        return 'Khẩn cấp';
      default:
        return 'Không xác định';
    }
  }
}



