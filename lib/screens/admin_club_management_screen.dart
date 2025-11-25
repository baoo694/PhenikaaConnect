import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/event.dart';
import '../services/admin_service.dart';
import '../widgets/common_widgets.dart';
import 'admin_club_detail_screen.dart';

class AdminClubManagementScreen extends StatefulWidget {
  const AdminClubManagementScreen({super.key});

  @override
  State<AdminClubManagementScreen> createState() => _AdminClubManagementScreenState();
}

class _AdminClubManagementScreenState extends State<AdminClubManagementScreen> {
  bool _isLoading = true;
  List<Club> _clubs = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadClubs();
  }

  Future<void> _loadClubs() async {
    setState(() => _isLoading = true);
    final clubs = await AdminService.fetchAllClubs();
    setState(() {
      _clubs = clubs;
      _isLoading = false;
    });
  }

  Future<void> _deleteClub(Club club) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa câu lạc bộ "${club.name}"? Hành động này không thể hoàn tác.'),
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
      final success = await AdminService.deleteClub(club.id);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa câu lạc bộ thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
        await _loadClubs();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Có lỗi xảy ra khi xóa câu lạc bộ'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  List<Club> get _filteredClubs {
    if (_searchQuery.isEmpty) return _clubs;
    return _clubs.where((club) {
      return club.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          club.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          club.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
      ),
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
                      hintText: 'Tìm kiếm câu lạc bộ...',
                      prefixIcon: const Icon(LucideIcons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                });
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
                    },
                  ),
                ),
              ],
            ),
          ),
          // Clubs list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredClubs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.users, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Chưa có câu lạc bộ nào'
                                  : 'Không tìm thấy câu lạc bộ',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadClubs,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredClubs.length,
                          itemBuilder: (context, index) {
                            final club = _filteredClubs[index];
                            return _buildClubCard(club);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildClubCard(Club club) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminClubDetailScreen(clubId: club.id),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      LucideIcons.users,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                club.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: club.status == ApprovalStatus.approved
                                    ? Colors.green.withOpacity(0.1)
                                    : club.status == ApprovalStatus.pending
                                        ? Colors.orange.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                club.status == ApprovalStatus.approved
                                    ? 'Đã duyệt'
                                    : club.status == ApprovalStatus.pending
                                        ? 'Chờ duyệt'
                                        : 'Từ chối',
                                style: TextStyle(
                                  color: club.status == ApprovalStatus.approved
                                      ? Colors.green
                                      : club.status == ApprovalStatus.pending
                                          ? Colors.orange
                                          : Colors.red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          club.description,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(LucideIcons.users, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '${club.members} thành viên',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                            const SizedBox(width: 12),
                            Icon(LucideIcons.tag, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              club.category,
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
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
                    _deleteClub(club);
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

