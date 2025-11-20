import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';

class ClubDetailScreen extends StatefulWidget {
  final Map<String, dynamic> club;

  const ClubDetailScreen({
    super.key,
    required this.club,
  });

  @override
  State<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen> {
  late Map<String, dynamic> _currentClub;

  @override
  void initState() {
    super.initState();
    _currentClub = Map<String, dynamic>.from(widget.club);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết CLB'),
      ),
      body: SingleChildScrollView(
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
                      Expanded(
                        child: Text(
                          _currentClub['name'] ?? 'Tên CLB',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: (_currentClub['active'] ?? true) ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          (_currentClub['active'] ?? true) ? 'Hoạt động' : 'Tạm dừng',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
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
                          _currentClub['category'] ?? 'Danh mục',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.users,
                            size: 18,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_currentClub['members'] ?? _currentClub['members_count'] ?? 0} thành viên',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Mô tả',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentClub['description'] ?? 'Chưa có mô tả',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Consumer<AppProvider>(
                    builder: (context, appProvider, child) {
                      // Get the latest club state from provider
                      final currentClub = appProvider.clubs.firstWhere(
                        (c) => c['id'] == _currentClub['id'],
                        orElse: () => _currentClub,
                      );
                      
                      // Update local state if provider has newer data
                      if (currentClub['members_count'] != _currentClub['members_count'] ||
                          currentClub['isJoined'] != _currentClub['isJoined']) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() {
                            _currentClub = currentClub;
                          });
                        });
                      }
                      
                      // Hide button if already joined
                      if (_currentClub['isJoined'] == true) {
                        return const SizedBox.shrink();
                      }
                      
                      return SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: 'Tham gia CLB',
                          icon: LucideIcons.userPlus,
                          size: ButtonSize.large,
                          onPressed: () async {
                            if (_currentClub['id'] != null) {
                              final success = await appProvider.joinClub(_currentClub['id']);
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
                                // Update local state immediately
                                if (success) {
                                  setState(() {
                                    final currentMembers = _currentClub['members_count'] ?? _currentClub['members'] ?? 0;
                                    _currentClub = {
                                      ..._currentClub,
                                      'members_count': currentMembers + 1,
                                      'members': currentMembers + 1,
                                      'isJoined': true,
                                    };
                                  });
                                }
                              }
                            }
                          },
                        ),
                      );
                    },
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

