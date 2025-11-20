import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';
import '../models/event.dart';
import 'event_detail_screen.dart';
import 'club_detail_screen.dart';

class CampusScreen extends StatefulWidget {
  const CampusScreen({super.key});

  @override
  State<CampusScreen> createState() => _CampusScreenState();
}

class _CampusScreenState extends State<CampusScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';
  bool _showJoinedOnly = false; // Filter for joined events
  bool _showJoinedClubsOnly = false; // Filter for joined clubs
  int _lastProviderSubTabIndex = 0; // Track the last sub tab index from provider

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3, 
      vsync: this,
      animationDuration: const Duration(milliseconds: 300),
    );
    
    // Initialize _lastProviderSubTabIndex from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      _lastProviderSubTabIndex = appProvider.selectedSubTabIndex;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        // Update tab controller when sub tab index changes from provider
        if (appProvider.selectedSubTabIndex != _lastProviderSubTabIndex) {
          _lastProviderSubTabIndex = appProvider.selectedSubTabIndex;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_tabController.index != appProvider.selectedSubTabIndex) {
              _tabController.animateTo(
                appProvider.selectedSubTabIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          });
        }
        
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
            elevation: 0,
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(LucideIcons.mapPin), text: 'Bản đồ'),
                Tab(icon: Icon(LucideIcons.calendar), text: 'Sự kiện'),
                Tab(icon: Icon(LucideIcons.users), text: 'CLB'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.1, 0.0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOut,
                      )),
                      child: child,
                    ),
                  );
                },
                child: _buildMapTab(),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.1, 0.0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOut,
                      )),
                      child: child,
                    ),
                  );
                },
                child: _buildEventsTab(),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.1, 0.0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOut,
                      )),
                      child: child,
                    ),
                  );
                },
                child: _buildClubsTab(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMapTab() {
    return RefreshIndicator(
      onRefresh: () =>
          context.read<AppProvider>().loadLocations(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bản đồ trường học',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tìm đường trong khuôn viên Phenikaa',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 16),
            CustomInput(
              hintText: 'Tìm kiếm địa điểm...',
              prefixIcon: LucideIcons.search,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _buildMapPlaceholder(),
                  const SizedBox(height: 16),
                  _buildPopularLocations(),
                  const SizedBox(height: 16),
                  _buildLocationsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.3),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.navigation,
              size: 48,
              color: Colors.white,
            ),
            SizedBox(height: 12),
            Text(
              'Bản đồ tương tác GPS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Dẫn đường thông minh trong trường',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularLocations() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        if (appProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (appProvider.locations.isEmpty) {
          return const Center(
            child: Text('Chưa có địa điểm nào'),
          );
        }

        // Filter popular locations
        final popularLocations = appProvider.locations
            .where((location) => location['popular'] == true)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  LucideIcons.star,
                  size: 16,
                  color: Colors.amber,
                ),
                const SizedBox(width: 8),
                Text(
                  'Địa điểm phổ biến',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: popularLocations.length,
              itemBuilder: (context, index) {
                final location = popularLocations[index];
                return _buildPopularLocationCard(location);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildPopularLocationCard(dynamic location) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.mapPin,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 4),
            Text(
              location['name'],
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationsList() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        if (appProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (appProvider.locations.isEmpty) {
          return const Center(
            child: Text('Chưa có địa điểm nào'),
          );
        }
        
        final filteredLocations = appProvider.locations.where((loc) =>
            loc['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            loc['type'].toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();

        return Column(
          children: filteredLocations.map((location) => _buildLocationItem(location)).toList(),
        );
      },
    );
  }

  Widget _buildLocationItem(dynamic location) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              LucideIcons.mapPin,
              color: Color(0xFF10B981),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location['name'],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${location['building']}, ${location['floor']}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomBadge(
                text: location['type'],
                type: BadgeType.outline,
                size: BadgeSize.small,
              ),
              if (location['popular']) ...[
                const SizedBox(height: 4),
                const Icon(
                  LucideIcons.star,
                  size: 12,
                  color: Colors.amber,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventsTab() {
    return Column(
      children: [
        // Fixed header section
        Container(
          padding: const EdgeInsets.all(16),
          child: CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sự kiện trường học',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Khám phá và tham gia các sự kiện trong trường',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                _buildCategoryFilter(),
                const SizedBox(height: 12),
                _buildJoinedFilter(),
              ],
            ),
          ),
        ),
        // Scrollable events list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () =>
                context.read<AppProvider>().loadEvents(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: _buildEventsList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['Tất cả', 'Học thuật', 'Văn hóa', 'Thể thao', 'Nghề nghiệp'];

    return SingleChildScrollView(
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
    );
  }

  Widget _buildJoinedFilter() {
    return InkWell(
      onTap: () {
        setState(() {
          _showJoinedOnly = !_showJoinedOnly;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _showJoinedOnly
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _showJoinedOnly
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.checkCircle,
              size: 16,
              color: _showJoinedOnly
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 8),
            Text(
              'Sự kiện đã tham gia',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _showJoinedOnly
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontWeight: _showJoinedOnly ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        if (appProvider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        var filteredEvents = _selectedCategory == 'Tất cả'
            ? appProvider.events
            : appProvider.events.where((e) => e.category == _selectedCategory).toList();
        
        // Filter by joined status if enabled
        if (_showJoinedOnly) {
          filteredEvents = filteredEvents.where((e) => e.isJoined).toList();
        }

        if (filteredEvents.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.calendar,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Không có sự kiện nào',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hãy thử chọn danh mục khác',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: filteredEvents.map((event) => _buildEventCard(event)).toList(),
        );
      },
    );
  }

  Widget _buildEventImagePlaceholder(dynamic event) {
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
              size: 64,
              color: Colors.white.withOpacity(0.9),
            ),
            const SizedBox(height: 12),
            Text(
              event.category,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sự kiện',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(dynamic event) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EventDetailScreen(event: event),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: event.image.isNotEmpty
                  ? Image.network(
                      event.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildEventImagePlaceholder(event);
                      },
                    )
                  : _buildEventImagePlaceholder(event),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomBadge(
                      text: event.category,
                      type: BadgeType.primary,
                      size: BadgeSize.small,
                    ),
                    const SizedBox(width: 8),
                    CustomBadge(
                      text: '${event.attendees} người',
                      type: BadgeType.outline,
                      size: BadgeSize.small,
                    ),
                    if (event.isJoined) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.checkCircle,
                              size: 12,
                              color: Colors.green.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Đã tham gia',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tổ chức bởi ${event.organizer}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      LucideIcons.calendar,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${event.date} • ${event.time}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      LucideIcons.mapPin,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      event.location,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Xem chi tiết',
                    icon: LucideIcons.arrowRight,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EventDetailScreen(event: event),
                        ),
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

  Widget _buildClubsTab() {
    return RefreshIndicator(
      onRefresh: () =>
          context.read<AppProvider>().loadClubs(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.users,
                        color: Colors.orange,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Câu lạc bộ & Tổ chức sinh viên',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tham gia CLB và kết nối với sinh viên',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildJoinedClubsFilter(),
                  const SizedBox(height: 16),
                  _buildClubsGrid(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinedClubsFilter() {
    return InkWell(
      onTap: () {
        setState(() {
          _showJoinedClubsOnly = !_showJoinedClubsOnly;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _showJoinedClubsOnly
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _showJoinedClubsOnly
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.checkCircle,
              size: 16,
              color: _showJoinedClubsOnly
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 8),
            Text(
              'CLB đã tham gia',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _showJoinedClubsOnly
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontWeight: _showJoinedClubsOnly ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClubsGrid() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        if (appProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (appProvider.clubs.isEmpty) {
          return const Center(
            child: Text('Chưa có câu lạc bộ nào'),
          );
        }
        
        var filteredClubs = appProvider.clubs;
        
        // Filter by joined status if enabled
        if (_showJoinedClubsOnly) {
          filteredClubs = filteredClubs.where((c) => c['isJoined'] == true).toList();
        }
        
        if (filteredClubs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.users,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'Không có CLB nào',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hãy thử tắt bộ lọc',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          );
        }
        
        return Column(
          children: filteredClubs.map((club) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildClubCard({
                'id': club['id'],
                'name': club['name'],
                'category': club['category'],
                'members': club['members_count'],
                'description': club['description'],
                'active': club['active'],
                'isJoined': club['isJoined'] ?? false,
              }),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildClubCard(Map<String, dynamic> club) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  club['name'],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (club['isJoined'] == true) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.shade200,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.checkCircle,
                        size: 12,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Đã tham gia',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Hoạt động',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            club['description'],
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Text(
                  club['category'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(
                    LucideIcons.users,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${club['members']} thành viên',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (club['isJoined'] != true) ...[
                Expanded(
                  child: Consumer<AppProvider>(
                    builder: (context, appProvider, child) {
                      return CustomButton(
                        text: 'Tham gia',
                        size: ButtonSize.small,
                        onPressed: () async {
                          if (club['id'] != null) {
                            final success = await appProvider.joinClub(club['id']);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? 'Đã tham gia CLB thành công!'
                                        : 'Tham gia thất bại. Bạn có thể đã là thành viên.',
                                  ),
                                  backgroundColor:
                                      success ? Colors.green : Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: CustomButton(
                  text: 'Xem thêm',
                  type: ButtonType.outline,
                  size: ButtonSize.small,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ClubDetailScreen(club: club),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
