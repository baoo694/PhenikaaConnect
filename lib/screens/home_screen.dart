import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';
import '../models/chat.dart';
import '../models/course.dart';
import 'announcements_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 0,
        titleSpacing: 16,
        title: Consumer<AppProvider>(
          builder: (context, appProvider, child) {
            return Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phenikaa Connect',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        'Hệ sinh thái số cho sinh viên',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      appProvider.currentUser?.name ?? 'User',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      'MSSV: ${appProvider.currentUser?.studentId ?? 'N/A'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    (appProvider.currentUser?.name ?? 'U')
                        .split(' ')
                        .where((part) => part.isNotEmpty)
                        .map((n) => n[0])
                        .take(2)
                        .join('')
                        .toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            context.read<AppProvider>().refreshAllData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(context),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildTodaySchedule(context),
              const SizedBox(height: 24),
              _buildAnnouncementsAndEvents(context),
              const SizedBox(height: 24),
              _buildRecentActivity(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final now = DateTime.now();
    final greeting = _greetingForTime(now);
    final dateText =
        'Hôm nay là ${_weekdayToVietnamese(now.weekday)}, ${now.day} Tháng ${now.month}, ${now.year}';
    final todayEnglish = _weekdayToEnglish(now.weekday);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF7C3AED), Color(0xFFDB2777)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting 👋',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            dateText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              final announcementsCount = appProvider.unreadAnnouncementsCount;
              final scheduleCount = appProvider.isScheduleLoading
                  ? null
                  : appProvider.getSchedulesForDay(todayEnglish).length;
              final scheduleText = appProvider.isScheduleLoading
                  ? 'Đang tải lịch học...'
                  : '$scheduleCount lớp học hôm nay';
              return Row(
                children: [
                  _buildBadge(context, scheduleText),
                  const SizedBox(width: 8),
                  _buildBadge(
                    context,
                    '$announcementsCount thông báo mới',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'icon': LucideIcons.bookOpen, 
        'label': 'Lịch học', 
        'color': Colors.blue,
        'onTap': () => _navigateToSchedule(context),
      },
      {
        'icon': LucideIcons.messageSquare, 
        'label': 'Q&A', 
        'color': Colors.purple,
        'onTap': () => _navigateToQA(context),
      },
      {
        'icon': LucideIcons.mapPin, 
        'label': 'Bản đồ', 
        'color': Colors.green,
        'onTap': () => _navigateToMap(context),
      },
      {
        'icon': LucideIcons.calendar, 
        'label': 'Sự kiện', 
        'color': Colors.orange,
        'onTap': () => _navigateToEvents(context),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thao tác nhanh',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.8,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _buildQuickActionCard(
              context,
              icon: action['icon'] as IconData,
              label: action['label'] as String,
              color: action['color'] as Color,
              onTap: action['onTap'] as VoidCallback,
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        // Add haptic feedback
        // HapticFeedback.lightImpact();
        
        // Add scale animation
        Future.delayed(const Duration(milliseconds: 100), onTap);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: 1.0,
              duration: const Duration(milliseconds: 150),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 10,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySchedule(BuildContext context) {
    final todayName = _weekdayToEnglish(DateTime.now().weekday);
    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          final isLoading = appProvider.isScheduleLoading;
          final schedules = appProvider.getSchedulesForDay(todayName);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.clock,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Lịch học hôm nay',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => _navigateToSchedule(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Xem tất cả'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (schedules.isEmpty)
                Center(
                  child: Text(
                    'Chưa có lịch học cho hôm nay',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                  ),
                )
              else
                Column(
                  children: schedules.take(3).map((cls) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildTodayClassTile(context, cls),
                    );
                  }).toList(),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, dynamic cls) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                cls.subject,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  cls.room,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                LucideIcons.clock,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                cls.time,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayClassTile(BuildContext context, ClassSchedule cls) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: _homeScheduleGradient(cls.color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              LucideIcons.bookOpen,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cls.subject,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${cls.time} • ${cls.room}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.85),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _homeScheduleGradient(String? color) {
    final baseColor = _colorFromHex(color);
    return LinearGradient(
      colors: [
        baseColor,
        Color.lerp(baseColor, Colors.black, 0.2) ?? baseColor,
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }

  Color _colorFromHex(String? color) {
    if (color == null || color.isEmpty) {
      return const Color(0xFF3B82F6);
    }
    var cleaned = color.replaceAll('#', '').trim();
    if (cleaned.length == 3) {
      cleaned = cleaned.split('').map((char) => '$char$char').join();
    }
    if (cleaned.length == 6) {
      cleaned = 'ff$cleaned';
    } else if (cleaned.length != 8) {
      cleaned = 'ff3b82f6';
    }
    try {
      return Color(int.parse(cleaned, radix: 16));
    } catch (_) {
      return const Color(0xFF3B82F6);
    }
  }

  String _weekdayToEnglish(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return 'Monday';
    }
  }

  Widget _buildAnnouncementsAndEvents(BuildContext context) {
    return Column(
      children: [
        _buildAnnouncements(context),
        const SizedBox(height: 16),
        _buildEvents(context),
      ],
    );
  }

  Widget _buildAnnouncements(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.megaphone,
                color: Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Thông báo',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              final announcements = appProvider.announcements;
              if (announcements.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Chưa có thông báo nào',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                    ),
                  ),
                );
              }

              return Column(
                children: announcements.take(2).map((ann) {
                  final announcementData = _mapToAnnouncementCardData(ann);
                  return _buildAnnouncementItem(context, announcementData);
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _navigateToAllAnnouncements(context),
              child: const Text('Xem tất cả thông báo'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementItem(BuildContext context, AnnouncementCardData announcement) {
    final isHighPriority = announcement.priority == AnnouncementPriority.high;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHighPriority
            ? const Color(0xFFFFF5F5)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighPriority
              ? const Color(0xFFFECACA)
              : Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        announcement.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    CustomBadge(
                      text: isHighPriority ? 'Khẩn' : 'Thông báo',
                      type: isHighPriority ? BadgeType.error : BadgeType.outline,
                      size: BadgeSize.small,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  announcement.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvents(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.calendar,
                color: Colors.purple,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Sự kiện sắp tới',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              if (appProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (appProvider.events.isEmpty) {
                return const Center(
                  child: Text('Chưa có sự kiện nào'),
                );
              }
              
              return Column(
                children: appProvider.events.take(2).map((event) => 
                  _buildEventItem(context, event)
                ).toList(),
              );
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _navigateToAllEvents(context),
              child: const Text('Xem tất cả sự kiện'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(BuildContext context, dynamic event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Oct',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                Text(
                  '25',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${event.attendees} người tham gia',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.trendingUp,
                color: Colors.green,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Hoạt động gần đây',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              if (appProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (appProvider.posts.isEmpty) {
                return const Center(
                  child: Text('Chưa có hoạt động nào'),
                );
              }
              
              return Column(
                children: appProvider.posts.take(3).map((post) => 
                  _buildActivityItem(context, post)
                ).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, dynamic post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              post.author[0],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: post.author,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: ' đã đăng bài mới',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  post.time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Navigation methods for quick actions
  void _navigateToSchedule(BuildContext context) {
    // Navigate to Academic tab (index 1) for schedule/timetable
    Provider.of<AppProvider>(context, listen: false).setSelectedTab(1);
  }

  void _navigateToQA(BuildContext context) {
    // Navigate to Social tab (index 2) for Q&A
    Provider.of<AppProvider>(context, listen: false).setSelectedTab(2);
  }

  void _navigateToMap(BuildContext context) {
    // Navigate to Campus tab (index 3) and Map sub-tab (index 0)
    Provider.of<AppProvider>(context, listen: false).setSelectedTabWithSubTab(3, 0);
  }

  void _navigateToEvents(BuildContext context) {
    // Navigate to Campus tab (index 3) and Events sub-tab (index 1)
    Provider.of<AppProvider>(context, listen: false).setSelectedTabWithSubTab(3, 1);
  }

  void _navigateToAllEvents(BuildContext context) {
    // Navigate to Campus tab (index 3) and Events sub-tab (index 1)
    Provider.of<AppProvider>(context, listen: false).setSelectedTabWithSubTab(3, 1);
  }

  void _navigateToAllAnnouncements(BuildContext context) {
    // Navigate to Announcements screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AnnouncementsScreen(),
      ),
    );
  }

  // Placeholder methods for data not yet implemented in Supabase
  Widget _buildPlaceholderClassCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lập trình Flutter',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'A101',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                LucideIcons.clock,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '08:00 - 10:00',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderAnnouncement(BuildContext context) {
    return Container();
  }

  AnnouncementCardData _mapToAnnouncementCardData(Map<String, dynamic> map) {
    final priorityStr = (map['priority'] ?? 'medium').toString();
    AnnouncementPriority priority;
    switch (priorityStr) {
      case 'high':
        priority = AnnouncementPriority.high;
        break;
      case 'low':
        priority = AnnouncementPriority.low;
        break;
      default:
        priority = AnnouncementPriority.medium;
    }

    return AnnouncementCardData(
      title: map['title']?.toString() ?? '',
      description: map['content']?.toString() ?? '',
      priority: priority,
    );
  }

  String _weekdayToVietnamese(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Thứ Hai';
      case DateTime.tuesday:
        return 'Thứ Ba';
      case DateTime.wednesday:
        return 'Thứ Tư';
      case DateTime.thursday:
        return 'Thứ Năm';
      case DateTime.friday:
        return 'Thứ Sáu';
      case DateTime.saturday:
        return 'Thứ Bảy';
      case DateTime.sunday:
        return 'Chủ Nhật';
      default:
        return 'Thứ Hai';
    }
  }

  String _greetingForTime(DateTime dateTime) {
    final hour = dateTime.hour;
    if (hour < 12) {
      return 'Chào buổi sáng!';
    } else if (hour < 18) {
      return 'Chào buổi chiều!';
    } else {
      return 'Chào buổi tối!';
    }
  }
}

class AnnouncementCardData {
  final String title;
  final String description;
  final AnnouncementPriority priority;

  const AnnouncementCardData({
    required this.title,
    required this.description,
    required this.priority,
  });
}

enum AnnouncementPriority { high, medium, low }
