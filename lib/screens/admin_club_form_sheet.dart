import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../services/admin_service.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';

class AdminClubFormSheet extends StatefulWidget {
  final Map<String, dynamic>? club;

  const AdminClubFormSheet({super.key, this.club});

  @override
  State<AdminClubFormSheet> createState() => _AdminClubFormSheetState();
}

class _AdminClubFormSheetState extends State<AdminClubFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedCategory;
  String? _selectedStatus;
  String? _selectedVisibility;
  bool _isLoading = false;

  final List<String> _categories = [
    'Học thuật',
    'Văn hóa',
    'Thể thao',
    'Nghề nghiệp',
  ];

  final List<String> _statuses = [
    'pending',
    'approved',
    'rejected',
  ];

  final List<String> _visibilities = [
    'public',
    'campus',
    'club_only',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.club != null) {
      _nameController.text = widget.club!['name'] ?? '';
      _descriptionController.text = widget.club!['description'] ?? '';
      
      // Ensure category exists in list
      final category = widget.club!['category'];
      _selectedCategory = _categories.contains(category) ? category : null;
      
      // Ensure status exists in list
      final status = widget.club!['status'];
      _selectedStatus = _statuses.contains(status) ? status : null;
      
      // Ensure visibility exists in list
      final visibility = widget.club!['visibility'];
      _selectedVisibility = _visibilities.contains(visibility) ? visibility : null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ duyệt';
      case 'approved':
        return 'Đã duyệt';
      case 'rejected':
        return 'Từ chối';
      default:
        return status;
    }
  }

  String _getVisibilityLabel(String visibility) {
    switch (visibility) {
      case 'public':
        return 'Công khai';
      case 'campus':
        return 'Nội bộ';
      case 'club_only':
        return 'Chỉ CLB';
      default:
        return visibility;
    }
  }

  Future<void> _submitClub() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null || _selectedVisibility == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn đầy đủ thông tin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // When editing, status is required
    if (widget.club != null && _selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn trạng thái'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final clubData = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'category': _selectedCategory!,
      'visibility': _selectedVisibility!,
    };

    bool success;
    if (widget.club != null) {
      // When editing, include status
      clubData['status'] = _selectedStatus!;
      success = await AdminService.updateClub(widget.club!['id'], clubData);
    } else {
      // Create club - admin can create clubs, automatically approved
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final currentUser = appProvider.currentUser;
      
      // Add leader_id if creating new club
      if (currentUser != null) {
        clubData['leader_id'] = currentUser.id;
      }
      
      // Admin-created clubs are automatically approved
      // This is handled in AdminService.createClub
      success = await AdminService.createClub(clubData);
    }

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.club != null
                ? 'Đã cập nhật câu lạc bộ thành công'
                : 'Đã tạo câu lạc bộ thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Có lỗi xảy ra'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.club != null ? 'Sửa câu lạc bộ' : 'Thêm câu lạc bộ mới'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomInput(
              controller: _nameController,
              hintText: 'Tên câu lạc bộ',
              labelText: 'Tên câu lạc bộ',
              prefixIcon: LucideIcons.users,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên câu lạc bộ';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomInput(
              controller: _descriptionController,
              hintText: 'Mô tả',
              labelText: 'Mô tả',
              prefixIcon: LucideIcons.fileText,
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Danh mục',
                prefixIcon: const Icon(LucideIcons.tag),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Vui lòng chọn danh mục';
                }
                return null;
              },
            ),
            // Only show status field when editing (admin-created clubs are auto-approved)
            if (widget.club != null) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Trạng thái',
                  prefixIcon: const Icon(LucideIcons.checkCircle2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _statuses.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(_getStatusLabel(status)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Vui lòng chọn trạng thái';
                  }
                  return null;
                },
              ),
            ] else ...[
              // Show info that admin-created clubs are auto-approved
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.checkCircle2,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'CLB do admin tạo sẽ được duyệt tự động',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.green.shade700,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedVisibility,
              decoration: InputDecoration(
                labelText: 'Phạm vi hiển thị',
                prefixIcon: const Icon(LucideIcons.eye),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _visibilities.map((visibility) {
                return DropdownMenuItem(
                  value: visibility,
                  child: Text(_getVisibilityLabel(visibility)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedVisibility = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Vui lòng chọn phạm vi hiển thị';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: widget.club != null ? 'Cập nhật' : 'Tạo câu lạc bộ',
              icon: widget.club != null ? LucideIcons.save : LucideIcons.plus,
              onPressed: _isLoading ? null : _submitClub,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

