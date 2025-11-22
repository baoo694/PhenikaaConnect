import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../widgets/common_widgets.dart';
import '../providers/app_provider.dart';
import 'announcement_detail_screen.dart';

class AnnouncementsScreen extends StatefulWidget {
  final bool showUnreadOnly;

  const AnnouncementsScreen({super.key, this.showUnreadOnly = false});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  String _selectedCategory = 'Tất cả';
  bool _showUnreadOnly = false;

  @override
  void initState() {
    super.initState();
    _showUnreadOnly = widget.showUnreadOnly;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            context.read<AppProvider>().loadAnnouncements(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategoryFilter(),
              const SizedBox(height: 16),
              _buildAnnouncementsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['Tất cả', 'Học tập', 'Sự kiện', 'Tuyển sinh', 'Khác'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle button for unread only
        Consumer<AppProvider>(
          builder: (context, appProvider, child) {
            final unreadCount = appProvider.unreadAnnouncementsCount;
            if (unreadCount == 0 && !_showUnreadOnly) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CustomButton(
                text: _showUnreadOnly 
                    ? 'Hiển thị tất cả ($unreadCount chưa đọc)'
                    : 'Chỉ hiển thị chưa đọc ($unreadCount)',
                type: _showUnreadOnly ? ButtonType.primary : ButtonType.outline,
                size: ButtonSize.small,
                icon: _showUnreadOnly ? LucideIcons.eye : LucideIcons.eyeOff,
                onPressed: () {
                  setState(() {
                    _showUnreadOnly = !_showUnreadOnly;
                  });
                },
              ),
            );
          },
        ),
        // Category filter
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((category) {
              final isSelected = _selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CustomButton(
                  text: category,
                  type: isSelected ? ButtonType.primary : ButtonType.outline,
                  size: ButtonSize.small,
                  onPressed: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementsList() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        if (appProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (appProvider.announcements.isEmpty) {
          return const Center(
            child: Text('Chưa có thông báo nào'),
          );
        }

        // Check if filtering by unread and no unread announcements
        if (_showUnreadOnly) {
          final hasUnread = appProvider.announcements.any((announcement) {
            final idStr = (announcement['id'] ?? '').toString();
            return idStr.isNotEmpty && !appProvider.isAnnouncementRead(idStr);
          });
          if (!hasUnread) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.checkCircle2, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Không có thông báo chưa đọc',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }
        }

        // Map priority to category for filtering
        final announcementsWithCategory = appProvider.announcements.map((announcement) {
          String category = 'Khác';
          if (announcement['priority'] == 'high') {
            category = 'Học tập';
          } else if (announcement['target_audience'] == 'all') {
            category = 'Sự kiện';
          } else if (announcement['title'].toString().toLowerCase().contains('tuyển sinh')) {
            category = 'Tuyển sinh';
          }
          
          final idStr = (announcement['id'] ?? '').toString();
          final isRead = appProvider.isAnnouncementRead(idStr);
          return {
            ...announcement,
            'category': category,
            'important': announcement['priority'] == 'high',
            'author': announcement['users']?['name'] ?? 'Hệ thống',
            'time': _formatTimeAgo(announcement['created_at']),
            'is_read': isRead,
          };
        }).toList();

        var filteredAnnouncements = _selectedCategory == 'Tất cả'
            ? announcementsWithCategory
            : announcementsWithCategory.where((announcement) => announcement['category'] == _selectedCategory).toList();

        // Filter by unread if needed
        if (_showUnreadOnly) {
          filteredAnnouncements = filteredAnnouncements.where((announcement) => announcement['is_read'] != true).toList();
        }

        // Sort: unread first, then by priority (high > normal > low), then by date (newest first)
        filteredAnnouncements.sort((a, b) {
          // First priority: unread announcements come first
          final aIsRead = a['is_read'] == true;
          final bIsRead = b['is_read'] == true;
          if (aIsRead != bIsRead) {
            return aIsRead ? 1 : -1; // unread (false) comes before read (true)
          }

          // Second priority: sort by priority (high > normal > low)
          const priorityOrder = {'high': 0, 'normal': 1, 'low': 2};
          final aPriority = priorityOrder[(a['priority'] ?? 'normal').toString()] ?? 1;
          final bPriority = priorityOrder[(b['priority'] ?? 'normal').toString()] ?? 1;
          if (aPriority != bPriority) {
            return aPriority.compareTo(bPriority);
          }

          // Third priority: sort by date (newest first)
          DateTime parseDate(dynamic value) {
            if (value == null) return DateTime.fromMillisecondsSinceEpoch(0);
            return DateTime.tryParse(value.toString()) ??
                DateTime.fromMillisecondsSinceEpoch(0);
          }

          final aDate = parseDate(a['created_at']);
          final bDate = parseDate(b['created_at']);
          return bDate.compareTo(aDate);
        });

        return Column(
          children: filteredAnnouncements.map((announcement) => 
            _buildAnnouncementCard(announcement)
          ).toList(),
        );
      },
    );
  }

  String _formatTimeAgo(String? dateTimeString) {
    if (dateTimeString == null) return 'Không xác định';
    
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inDays > 0) {
        return '${difference.inDays} ngày trước';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h trước';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m trước';
      } else {
        return 'Vừa xong';
      }
    } catch (e) {
      return 'Không xác định';
    }
  }

  Widget _buildAnnouncementCard(Map<String, dynamic> announcement) {
    final announcementId = (announcement['id'] ?? '').toString();
    final isHighPriority =
        announcement['important'] == true || announcement['priority'] == 'high';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          // Mark as read when opening detail
          if (announcementId.isNotEmpty) {
            Provider.of<AppProvider>(context, listen: false)
                .markAnnouncementRead(announcementId);
          }
          _navigateToDetail(context, announcement);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: CustomCard(
            backgroundColor: isHighPriority
                ? const Color(0xFFFFF5F5)
                : Theme.of(context).colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (announcement['is_read'] != true) ...[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        announcement['title'] ?? 'Không có tiêu đề',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CustomBadge(
                      text: isHighPriority ? 'Khẩn cấp' : 'Thông thường',
                      type: isHighPriority ? BadgeType.error : BadgeType.outline,
                      size: BadgeSize.small,
                    ),
                    const SizedBox(width: 8),
                    CustomBadge(
                      text: announcement['category'] ?? 'Khác',
                      type: BadgeType.outline,
                      size: BadgeSize.small,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  announcement['content'] ?? 'Không có nội dung',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      LucideIcons.user,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      announcement['author'] ?? 'Hệ thống',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                    ),
                    const Spacer(),
                    Icon(
                      LucideIcons.clock,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      announcement['time'] ?? 'Không xác định',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Map<String, dynamic> announcement) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnnouncementDetailScreen(
          announcement: announcement,
        ),
      ),
    );
  }
}
