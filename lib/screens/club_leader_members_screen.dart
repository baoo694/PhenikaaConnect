import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../services/club_leader_service.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';

class ClubLeaderMembersScreen extends StatefulWidget {
  final String clubId;

  const ClubLeaderMembersScreen({super.key, required this.clubId});

  @override
  State<ClubLeaderMembersScreen> createState() => _ClubLeaderMembersScreenState();
}

class _ClubLeaderMembersScreenState extends State<ClubLeaderMembersScreen> {
  bool _isLoading = true;
  List<ClubMember> _members = [];
  List<ClubMember> _pendingMembers = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);
    final members = await ClubLeaderService.fetchMembers(widget.clubId);
    setState(() {
      _members = members.where((m) => m.status == 'active').toList();
      _pendingMembers = members.where((m) => m.status == 'pending').toList();
      _isLoading = false;
    });
  }

  Future<void> _updateMemberStatus(ClubMember member, String status) async {
    final success = await ClubLeaderService.updateMemberStatus(
      membershipId: member.id,
      status: status,
    );
    if (success) {
      await _loadMembers();
    }
  }

  void _showMemberDetail(ClubMember member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (member.avatar != null)
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(member.avatar!),
                    )
                  else
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        member.userName.isNotEmpty ? member.userName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.userName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (member.studentId.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'MSSV: ${member.studentId}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Vai trò', member.role),
              if (member.major.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDetailRow('Ngành học', member.major),
              ],
              if (member.year.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDetailRow('Năm học', member.year),
              ],
              const SizedBox(height: 12),
              _buildDetailRow('Trạng thái', member.status),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  List<ClubMember> get _filteredMembers {
    if (_searchQuery.isEmpty) return _members;
    return _members.where((m) {
      return m.userName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.studentId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.major.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: null,
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm thành viên...',
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
          // Members list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadMembers,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pending members
                          if (_pendingMembers.isNotEmpty) ...[
                            CustomCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Yêu cầu chờ duyệt',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      CustomBadge(
                                        text: '${_pendingMembers.length}',
                                        type: BadgeType.warning,
                                        size: BadgeSize.small,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  ..._pendingMembers.map((member) => _buildPendingMemberCard(member)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          // Active members
                          CustomCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Thành viên (${_filteredMembers.length})',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (_filteredMembers.isEmpty)
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Text(
                                        _searchQuery.isEmpty
                                            ? 'Chưa có thành viên nào'
                                            : 'Không tìm thấy thành viên',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    ),
                                  )
                                else
                                  ..._filteredMembers.map((member) => _buildMemberCard(member)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingMemberCard(ClubMember member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
        ),
      ),
      child: InkWell(
        onTap: () => _showMemberDetail(member),
        child: Row(
          children: [
            if (member.avatar != null)
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(member.avatar!),
              )
            else
              CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  LucideIcons.user,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.userName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (member.studentId.isNotEmpty || member.major.isNotEmpty || member.year.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (member.studentId.isNotEmpty) 'MSSV: ${member.studentId}',
                        if (member.major.isNotEmpty) member.major,
                        if (member.year.isNotEmpty) 'Năm ${member.year}',
                      ].join(' • '),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(LucideIcons.x, color: Colors.red),
              onPressed: () => _updateMemberStatus(member, 'removed'),
              tooltip: 'Từ chối',
            ),
            IconButton(
              icon: const Icon(LucideIcons.check, color: Colors.green),
              onPressed: () => _updateMemberStatus(member, 'active'),
              tooltip: 'Chấp nhận',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(ClubMember member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        onTap: () => _showMemberDetail(member),
        child: Row(
          children: [
            if (member.avatar != null)
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(member.avatar!),
              )
            else
              CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  member.userName.isNotEmpty ? member.userName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
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
                    member.userName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (member.studentId.isNotEmpty || member.major.isNotEmpty || member.year.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (member.studentId.isNotEmpty) 'MSSV: ${member.studentId}',
                        if (member.major.isNotEmpty) member.major,
                        if (member.year.isNotEmpty) 'Năm ${member.year}',
                      ].join(' • '),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text(
                    'Vai trò: ${member.role}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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

