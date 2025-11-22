import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/admin_service.dart';
import '../widgets/common_widgets.dart';
import 'admin_announcement_form_sheet.dart';

class AdminAnnouncementDetailScreen extends StatefulWidget {
  final String announcementId;

  const AdminAnnouncementDetailScreen({super.key, required this.announcementId});

  @override
  State<AdminAnnouncementDetailScreen> createState() => _AdminAnnouncementDetailScreenState();
}

class _AdminAnnouncementDetailScreenState extends State<AdminAnnouncementDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _announcement;

  @override
  void initState() {
    super.initState();
    _loadAnnouncement();
  }

  Future<void> _loadAnnouncement() async {
    setState(() => _isLoading = true);
    final announcement = await AdminService.fetchAnnouncementById(widget.announcementId);
    setState(() {
      _announcement = announcement;
      _isLoading = false;
    });
  }

  Future<void> _deleteAnnouncement() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa thông báo này?'),
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
      final success = await AdminService.deleteAnnouncement(widget.announcementId);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa thông báo thành công'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate deletion
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Xóa thông báo thất bại'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _editAnnouncement() async {
    if (_announcement == null) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AdminAnnouncementFormSheet(announcement: _announcement!),
      ),
    );

    if (result == true) {
      await _loadAnnouncement();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết thông báo'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.edit),
            onPressed: _announcement != null ? _editAnnouncement : null,
            tooltip: 'Sửa',
          ),
          IconButton(
            icon: const Icon(LucideIcons.trash2),
            onPressed: _announcement != null ? _deleteAnnouncement : null,
            tooltip: 'Xóa',
            color: Colors.red,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _announcement == null
              ? const Center(child: Text('Không tìm thấy thông báo'))
              : RefreshIndicator(
                  onRefresh: _loadAnnouncement,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and priority
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _announcement!['title'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildPriorityBadge(_announcement!['priority'] ?? 'normal'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Category
                        if (_announcement!['category'] != null) ...[
                          Chip(
                            label: Text(_announcement!['category'] ?? 'Khác'),
                            avatar: const Icon(LucideIcons.tag, size: 16),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Content
                        CustomCard(
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nội dung',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _announcement!['content'] ?? '',
                                  style: const TextStyle(fontSize: 16, height: 1.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Details
                        CustomCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Thông tin',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                LucideIcons.user,
                                'Người tạo',
                                _announcement!['users']?['name'] ?? 'Hệ thống',
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                LucideIcons.users,
                                'Đối tượng',
                                _getTargetAudienceLabel(_announcement!['target_audience']),
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                LucideIcons.calendar,
                                'Ngày tạo',
                                _formatDateTime(_announcement!['created_at']),
                              ),
                              if (_announcement!['updated_at'] != null &&
                                  _announcement!['updated_at'] != _announcement!['created_at']) ...[
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  LucideIcons.edit,
                                  'Cập nhật lần cuối',
                                  _formatDateTime(_announcement!['updated_at']),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    String label;
    Color color;
    switch (priority) {
      case 'high':
        label = 'Khẩn cấp';
        color = Colors.red;
        break;
      case 'low':
        label = 'Thấp';
        color = Colors.grey;
        break;
      default:
        label = 'Thông thường';
        color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  String _getTargetAudienceLabel(String? target) {
    switch (target) {
      case 'all':
        return 'Tất cả sinh viên';
      case 'specific_major':
        return 'Theo ngành học';
      case 'specific_year':
        return 'Theo năm học';
      default:
        return 'Không xác định';
    }
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return 'Không xác định';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }
}

