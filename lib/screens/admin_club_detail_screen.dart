import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/admin_service.dart';
import '../widgets/common_widgets.dart';
import 'admin_club_form_sheet.dart';

class AdminClubDetailScreen extends StatefulWidget {
  final String clubId;

  const AdminClubDetailScreen({super.key, required this.clubId});

  @override
  State<AdminClubDetailScreen> createState() => _AdminClubDetailScreenState();
}

class _AdminClubDetailScreenState extends State<AdminClubDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _clubDetails;
  String _memberSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadClubDetails();
  }

  Future<void> _loadClubDetails() async {
    setState(() => _isLoading = true);
    final details = await AdminService.fetchClubDetails(widget.clubId);
    setState(() {
      _clubDetails = details;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredMembers {
    if (_clubDetails == null) return [];
    final members = (_clubDetails!['club_members'] as List?) ?? [];
    if (_memberSearchQuery.isEmpty) {
      return members.map((m) => m as Map<String, dynamic>).toList();
    }
    return members.where((member) {
      final user = member['users'] as Map<String, dynamic>?;
      if (user == null) return false;
      final name = (user['name'] ?? '').toString().toLowerCase();
      final email = (user['email'] ?? '').toString().toLowerCase();
      final studentId = (user['student_id'] ?? '').toString().toLowerCase();
      final query = _memberSearchQuery.toLowerCase();
      return name.contains(query) || email.contains(query) || studentId.contains(query);
    }).map((m) => m as Map<String, dynamic>).toList();
  }

  Future<void> _editClub() async {
    if (_clubDetails == null) return;
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminClubFormSheet(club: _clubDetails),
      ),
    );

    if (result == true && mounted) {
      await _loadClubDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết câu lạc bộ'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.edit),
            onPressed: _clubDetails == null ? null : _editClub,
            tooltip: 'Sửa',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _clubDetails == null
              ? const Center(child: Text('Không tìm thấy thông tin'))
              : RefreshIndicator(
                  onRefresh: _loadClubDetails,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Club info card
                        CustomCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      LucideIcons.users,
                                      color: Theme.of(context).colorScheme.primary,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _clubDetails!['name'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _clubDetails!['category'] ?? '',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _clubDetails!['description'] ?? '',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _buildInfoItem(
                                    LucideIcons.users,
                                    'Thành viên',
                                    '${(_clubDetails!['club_members'] as List?)?.length ?? 0}',
                                  ),
                                  const SizedBox(width: 24),
                                  _buildInfoItem(
                                    LucideIcons.calendar,
                                    'Trạng thái',
                                    _clubDetails!['status'] == 'approved'
                                        ? 'Đã duyệt'
                                        : _clubDetails!['status'] == 'pending'
                                            ? 'Chờ duyệt'
                                            : 'Từ chối',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Leader info
                        if (_clubDetails!['users'] != null) ...[
                          CustomCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Trưởng CLB',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                      child: Text(
                                        (_clubDetails!['users']['name'] ?? 'U')[0].toUpperCase(),
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
                                            _clubDetails!['users']['name'] ?? '',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            _clubDetails!['users']['email'] ?? '',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        // Members list
                        CustomCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Thành viên (${(_clubDetails!['club_members'] as List?)?.length ?? 0})',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Search bar for members
                              TextField(
                                decoration: InputDecoration(
                                  hintText: 'Tìm kiếm thành viên...',
                                  prefixIcon: const Icon(LucideIcons.search),
                                  suffixIcon: _memberSearchQuery.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            setState(() {
                                              _memberSearchQuery = '';
                                            });
                                          },
                                        )
                                      : null,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _memberSearchQuery = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                              if (_filteredMembers.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Text(
                                      _memberSearchQuery.isEmpty
                                          ? 'Chưa có thành viên'
                                          : 'Không tìm thấy thành viên',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ),
                                )
                              else
                                ..._filteredMembers.map((member) {
                                  final user = member['users'] as Map<String, dynamic>?;
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                      child: Text(
                                        (user?['name'] ?? 'U')[0].toUpperCase(),
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    title: Text(user?['name'] ?? ''),
                                    subtitle: Text(
                                      user?['student_id'] ?? user?['email'] ?? '',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  );
                                }).toList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

