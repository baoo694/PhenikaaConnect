import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({
    super.key,
    required this.event,
  });

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

    final config = categoryConfig[event.category] ??
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
              event.category,
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
      ),
      body: SingleChildScrollView(
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
              child: event.image.isNotEmpty
                  ? Image.network(
                      event.image,
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
                        text: event.category,
                        type: BadgeType.primary,
                        size: BadgeSize.small,
                      ),
                      const SizedBox(width: 8),
                      CustomBadge(
                        text: '${event.attendees} người tham gia',
                        type: BadgeType.outline,
                        size: BadgeSize.small,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Title
                  Text(
                    event.title,
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
                        'Tổ chức bởi ${event.organizer}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  
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
                              '${event.date} • ${event.time}',
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
                              event.location,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    child: Consumer<AppProvider>(
                      builder: (context, appProvider, child) {
                        return CustomButton(
                          text: 'Đăng ký tham gia',
                          icon: LucideIcons.users,
                          size: ButtonSize.large,
                          onPressed: () async {
                            final success = await appProvider.joinEvent(event.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? 'Đã đăng ký tham gia sự kiện'
                                        : 'Đăng ký thất bại. Vui lòng thử lại.',
                                  ),
                                  backgroundColor:
                                      success ? Colors.green : Colors.red,
                                ),
                              );
                              if (success) {
                                appProvider.loadEvents();
                              }
                            }
                          },
                        );
                      },
                    ),
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

