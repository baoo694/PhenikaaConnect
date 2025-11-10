import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';
import '../services/supabase_service.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(LucideIcons.megaphone), text: 'Tiện ích'),
            Tab(icon: Icon(LucideIcons.settings), text: 'Cài đặt'),
            Tab(icon: Icon(LucideIcons.user), text: 'Thông tin'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUtilitiesTab(),
          _buildSettingsTab(),
          _buildInfoTab(),
        ],
      ),
    );
  }

  Widget _buildUtilitiesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAnnouncementsCard(),
          const SizedBox(height: 16),
          _buildCarpoolCard(),
          const SizedBox(height: 16),
          _buildLostFoundCard(),
          const SizedBox(height: 16),
          _buildFeedbackCard(),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsCard() {
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
                'Thông báo quan trọng',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Cập nhật mới nhất từ nhà trường',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          _buildAnnouncementsList(),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsList() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        if (appProvider.announcements.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Chưa có thông báo nào'),
            ),
          );
        }

        return Column(
          children: appProvider.announcements.map((announcement) => 
            _buildAnnouncementItem(announcement)
          ).toList(),
        );
      },
    );
  }

  Widget _buildAnnouncementItem(Map<String, dynamic> announcement) {
    final priority = announcement['priority'] ?? 'normal';
    final createdAt = announcement['created_at'] ?? '';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  announcement['title'] ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              CustomBadge(
                text: priority == 'high' ? 'Quan trọng' : 'Thông thường',
                type: priority == 'high' ? BadgeType.warning : BadgeType.primary,
                size: BadgeSize.small,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            createdAt,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarpoolCard() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.car,
                        color: Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Carpool & Đi chung xe',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tìm hoặc chia sẻ chuyến đi',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(LucideIcons.plus),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCarpoolList(),
        ],
      ),
    );
  }

  Widget _buildCarpoolList() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Tính năng đang phát triển'),
      ),
    );
  }

  Widget _buildLostFoundCard() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.package,
                        color: Colors.purple,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Đồ thất lạc',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Báo cáo hoặc tìm đồ bị mất',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(LucideIcons.plus),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLostFoundList(),
        ],
      ),
    );
  }

  Widget _buildLostFoundList() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Tính năng đang phát triển'),
      ),
    );
  }

  Widget _buildFeedbackCard() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.messageSquare,
                color: Colors.green,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Góp ý & Phản hồi',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Chia sẻ ý kiến của bạn với nhà trường',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          CustomInput(
            controller: _feedbackController,
            hintText: 'Nhập góp ý hoặc phản hồi của bạn...',
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Gửi phản hồi',
              onPressed: () {
                if (_feedbackController.text.isNotEmpty) {
                  // Send feedback logic here
                  _feedbackController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Phản hồi đã được gửi!')),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildNotificationSettingsCard(),
          const SizedBox(height: 16),
          _buildPrivacySecurityCard(),
          const SizedBox(height: 16),
          _buildHelpSupportCard(),
          const SizedBox(height: 16),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildNotificationSettingsCard() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.bell,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Cài đặt thông báo',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Quản lý thông báo bạn muốn nhận',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              return Column(
                children: appProvider.notificationSettings.map((setting) => 
                  _buildNotificationSettingItem(setting, appProvider)
                ).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettingItem(Map<String, dynamic> setting, AppProvider appProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            setting['label'],
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Switch(
            value: setting['enabled'],
            onChanged: (value) {
              appProvider.toggleNotification(setting['id']);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySecurityCard() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.shield,
                color: Colors.purple,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Quyền riêng tư & Bảo mật',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingItem('Đổi mật khẩu', LucideIcons.key, () {
            _showChangePasswordDialog();
          }),
          const Divider(),
          _buildSettingItem('Quản lý quyền riêng tư', LucideIcons.lock, () {
            _showPrivacySettingsDialog();
          }),
          const Divider(),
          _buildSettingItem('Lịch sử hoạt động', LucideIcons.history, () {
            _showActivityHistoryDialog();
          }),
        ],
      ),
    );
  }

  Widget _buildHelpSupportCard() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.helpCircle,
                color: Colors.green,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Trợ giúp & Hỗ trợ',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingItem('Câu hỏi thường gặp', LucideIcons.helpCircle, () {
            _showFAQDialog();
          }),
          const Divider(),
          _buildSettingItem('Liên hệ hỗ trợ', LucideIcons.phone, () {
            _showContactSupportDialog();
          }),
          const Divider(),
          _buildSettingItem('Báo cáo vấn đề', LucideIcons.flag, () {
            _showReportProblemDialog();
          }),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: 'Đăng xuất',
        type: ButtonType.error,
        size: ButtonSize.large,
        icon: LucideIcons.logOut,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Đăng xuất'),
              content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final appProvider = Provider.of<AppProvider>(context, listen: false);
                    await appProvider.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    }
                  },
                  child: const Text('Đăng xuất'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 16),
          _buildContactInfoCard(),
          const SizedBox(height: 16),
          _buildAcademicStatsCard(),
          const SizedBox(height: 16),
          _buildAboutAppCard(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return CustomCard(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF7C3AED), Color(0xFFDB2777)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      CustomAvatar(
                        initials: appProvider.currentUser?.name ?? 'U'
                            .split(' ')
                            .map((n) => n[0])
                            .join(''),
                        radius: 40,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        textColor: Colors.white,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appProvider.currentUser?.name ?? 'User',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              appProvider.currentUser?.major ?? 'N/A',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            Text(
                              '${appProvider.currentUser?.year ?? 'N/A'} • MSSV: ${appProvider.currentUser?.studentId ?? 'N/A'}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child:                         Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const EditProfileScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  LucideIcons.user,
                                  color: Colors.black,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Chỉnh sửa hồ sơ',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactInfoCard() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thông tin liên hệ',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow('Email', appProvider.currentUser?.email ?? 'N/A'),
              const Divider(),
              _buildInfoRow('Số điện thoại', appProvider.currentUser?.phone ?? 'N/A'),
              const Divider(),
              _buildInfoRow('Ngành học', appProvider.currentUser?.major ?? 'N/A'),
              const Divider(),
              _buildInfoRow('Năm học', appProvider.currentUser?.year ?? 'N/A'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicStatsCard() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thống kê học tập',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('4', 'Môn học', Colors.blue),
              ),
              Expanded(
                child: _buildStatItem('3.45', 'GPA', Colors.green),
              ),
              Expanded(
                child: _buildStatItem('92', 'Tín chỉ', Colors.purple),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutAppCard() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Về Phenikaa Connect',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Phiên bản: 1.0.0',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const Divider(),
          _buildAboutItem('Điều khoản sử dụng'),
          _buildAboutItem('Chính sách bảo mật'),
          _buildAboutItem('Giới thiệu'),
        ],
      ),
    );
  }

  Widget _buildAboutItem(String title) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  // Dialog methods
  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đổi mật khẩu'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu hiện tại',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu mới',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Xác nhận mật khẩu mới',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mật khẩu xác nhận không khớp'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              if (newPasswordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mật khẩu phải có ít nhất 6 ký tự'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              final appProvider = Provider.of<AppProvider>(context, listen: false);
              final error = await SupabaseService.updatePassword(newPasswordController.text);
              
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error ?? 'Đã đổi mật khẩu thành công'),
                    backgroundColor: error == null ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Đổi mật khẩu'),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quản lý quyền riêng tư'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tùy chọn quyền riêng tư:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text('• Chia sẻ thông tin với người khác'),
              SizedBox(height: 8),
              Text('• Hiển thị email công khai'),
              SizedBox(height: 8),
              Text('• Cho phép tìm kiếm theo email'),
              SizedBox(height: 8),
              Text('• Hiển thị số điện thoại'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showActivityHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lịch sử hoạt động'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Lịch sử hoạt động gần đây:'),
              SizedBox(height: 16),
              Text('• Đăng nhập: Hôm nay 09:30'),
              SizedBox(height: 8),
              Text('• Đăng bài: Hôm qua 14:20'),
              SizedBox(height: 8),
              Text('• Tham gia sự kiện: 2 ngày trước'),
              SizedBox(height: 8),
              Text('• Bình luận: 3 ngày trước'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showFAQDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Câu hỏi thường gặp'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFAQItem('Làm sao để đăng bài?', 'Vào màn hình Cộng đồng, nhập nội dung và nhấn Đăng bài.'),
              _buildFAQItem('Làm sao để tham gia sự kiện?', 'Vào màn hình Đời sống > Sự kiện, chọn sự kiện và nhấn Đăng ký tham gia.'),
              _buildFAQItem('Làm sao để đổi mật khẩu?', 'Vào Cài đặt > Quyền riêng tư & Bảo mật > Đổi mật khẩu.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            answer,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Liên hệ hỗ trợ'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Thông tin liên hệ:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text('📧 Email: support@phenikaa.edu.vn'),
              SizedBox(height: 8),
              Text('📞 Hotline: 024.xxxx.xxxx'),
              SizedBox(height: 8),
              Text('🕐 Thời gian: 8:00 - 17:00 (Thứ 2 - Thứ 6)'),
              SizedBox(height: 8),
              Text('📍 Địa chỉ: Văn phòng Tư vấn Sinh viên'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showReportProblemDialog() {
    final reportController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Báo cáo vấn đề'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: reportController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Mô tả vấn đề',
                  hintText: 'Nhập mô tả chi tiết về vấn đề bạn gặp phải...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              if (reportController.text.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã gửi báo cáo. Cảm ơn bạn đã phản hồi!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Gửi báo cáo'),
          ),
        ],
      ),
    );
  }
}
