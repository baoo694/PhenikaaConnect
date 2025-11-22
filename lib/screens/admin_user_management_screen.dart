import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/user.dart' as app_models;
import '../services/admin_service.dart';
import '../widgets/common_widgets.dart';
import 'admin_user_form_sheet.dart';
import 'admin_user_detail_screen.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  bool _isLoading = true;
  List<app_models.User> _users = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final users = await AdminService.fetchUsers();
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  Future<void> _searchUsers() async {
    if (_searchQuery.isEmpty) {
      await _loadUsers();
      return;
    }
    setState(() => _isLoading = true);
    final users = await AdminService.searchUsers(_searchQuery);
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  Future<void> _deleteUser(app_models.User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa người dùng "${user.name}"?'),
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
      final success = await AdminService.deleteUser(user.id);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa người dùng thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
        await _loadUsers();
      }
    }
  }

  Future<void> _toggleUserLock(app_models.User user) async {
    final success = await AdminService.toggleUserLock(
      userId: user.id,
      isLocked: !user.isLocked,
    );
    if (success) {
      await _loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm theo tên, email, mã SV...',
                      prefixIcon: const Icon(LucideIcons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                });
                                _loadUsers();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      if (value.isEmpty) {
                        _loadUsers();
                      } else {
                        _searchUsers();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(LucideIcons.plus),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminUserFormSheet(),
                      ),
                    );
                    if (result == true) {
                      await _loadUsers();
                    }
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Users list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.users, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Chưa có người dùng nào'
                                  : 'Không tìm thấy người dùng',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadUsers,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _users.length,
                          itemBuilder: (context, index) {
                            final user = _users[index];
                            return _buildUserCard(user);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(app_models.User user) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminUserDetailScreen(user: user),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: user.avatar != null && user.avatar!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(user.avatar!, fit: BoxFit.cover),
                    )
                  : Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(LucideIcons.creditCard, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          user.studentId,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(LucideIcons.graduationCap, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${user.major} • ${user.year}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Switch(
                  value: !user.isLocked,
                  onChanged: (_) => _toggleUserLock(user),
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(LucideIcons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Sửa'),
                        ],
                      ),
                      onTap: () async {
                        await Future.delayed(const Duration(milliseconds: 100));
                        if (mounted) {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminUserFormSheet(user: user),
                            ),
                          );
                          if (result == true) {
                            await _loadUsers();
                          }
                        }
                      },
                    ),
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(LucideIcons.trash2, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Xóa', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                      onTap: () {
                        Future.delayed(const Duration(milliseconds: 100), () {
                          _deleteUser(user);
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

