import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/admin_service.dart';
import '../widgets/common_widgets.dart';

class AdminAnnouncementFormSheet extends StatefulWidget {
  final Map<String, dynamic>? announcement;

  const AdminAnnouncementFormSheet({super.key, this.announcement});

  @override
  State<AdminAnnouncementFormSheet> createState() => _AdminAnnouncementFormSheetState();
}

class _AdminAnnouncementFormSheetState extends State<AdminAnnouncementFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  String _selectedPriority = 'normal';
  String? _selectedTargetAudience;
  String? _selectedCategory;
  String? _selectedMajor;
  String? _selectedYear;
  bool _isLoading = false;

  final List<String> _priorities = [
    'low',
    'normal',
    'high',
  ];

  final List<String> _categories = [
    'Học tập',
    'Tuyển sinh',
    'Sự kiện',
    'Khác',
  ];

  final List<String> _targetAudiences = [
    'all',
    'specific_major',
    'specific_year',
  ];

  final List<String> _majors = [
    'Khoa học máy tính',
    'Kỹ thuật phần mềm',
    'Công nghệ thông tin',
    'An toàn thông tin',
    'Quản trị kinh doanh',
    'Kế toán',
    'Tài chính - Ngân hàng',
    'Kỹ thuật điện tử',
    'Kỹ thuật cơ khí',
    'Thiết kế đồ họa',
    'Marketing',
    'Khác',
  ];

  final List<String> _years = [
    'Năm 1',
    'Năm 2',
    'Năm 3',
    'Năm 4',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.announcement != null) {
      _titleController.text = widget.announcement!['title'] ?? '';
      _contentController.text = widget.announcement!['content'] ?? '';
      _selectedPriority = widget.announcement!['priority'] ?? 'normal';
      _selectedCategory = widget.announcement!['category'];
      _selectedTargetAudience = widget.announcement!['target_audience'] ?? 'all';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  String _getPriorityLabel(String priority) {
    switch (priority) {
      case 'low':
        return 'Thấp';
      case 'normal':
        return 'Thông thường';
      case 'high':
        return 'Khẩn cấp';
      default:
        return priority;
    }
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
        return 'Chưa chọn';
    }
  }

  String _getTargetAudienceValue() {
    if (_selectedTargetAudience == 'specific_major' && _selectedMajor != null) {
      return _selectedMajor!;
    } else if (_selectedTargetAudience == 'specific_year' && _selectedYear != null) {
      return _selectedYear!;
    }
    return 'all';
  }

  Future<void> _submitAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn phân loại thông báo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedTargetAudience == 'specific_major' && _selectedMajor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ngành học'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedTargetAudience == 'specific_year' && _selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn năm học'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    bool success;
    if (widget.announcement != null) {
      // Update existing announcement
      success = await AdminService.updateAnnouncement(
        announcementId: widget.announcement!['id'],
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        priority: _selectedPriority,
        targetAudience: _getTargetAudienceValue(),
        category: _selectedCategory,
      );
    } else {
      // Create new announcement
      success = await AdminService.sendBroadcastAnnouncement(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        priority: _selectedPriority,
        targetAudience: _getTargetAudienceValue(),
        category: _selectedCategory,
      );
    }

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.announcement != null
                ? 'Đã cập nhật thông báo thành công'
                : 'Đã gửi thông báo thành công'),
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
        title: Text(widget.announcement != null ? 'Sửa thông báo' : 'Gửi thông báo'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
                    children: [
                      // Title
                      CustomInput(
                        controller: _titleController,
                        hintText: 'Tiêu đề thông báo',
                        labelText: 'Tiêu đề',
                        prefixIcon: LucideIcons.type,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tiêu đề';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Content
                      CustomInput(
                        controller: _contentController,
                        hintText: 'Nội dung thông báo',
                        labelText: 'Nội dung',
                        prefixIcon: LucideIcons.fileText,
                        maxLines: 6,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập nội dung';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Category
                      Text(
                        'Phân loại thông báo',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _categories.map((category) {
                          final isSelected = _selectedCategory == category;
                          return ChoiceChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            selectedColor: Theme.of(context).colorScheme.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : null,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Priority
                      Text(
                        'Mức độ ưu tiên',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _priorities.map((priority) {
                          final isSelected = _selectedPriority == priority;
                          return ChoiceChip(
                            label: Text(_getPriorityLabel(priority)),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedPriority = priority;
                              });
                            },
                            selectedColor: Theme.of(context).colorScheme.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : null,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Target Audience
                      Text(
                        'Đối tượng nhận thông báo',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _targetAudiences.map((target) {
                          final isSelected = _selectedTargetAudience == target;
                          return ChoiceChip(
                            label: Text(_getTargetAudienceLabel(target)),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedTargetAudience = target;
                                if (target != 'specific_major') _selectedMajor = null;
                                if (target != 'specific_year') _selectedYear = null;
                              });
                            },
                            selectedColor: Theme.of(context).colorScheme.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : null,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Major selection (if specific_major selected)
                      if (_selectedTargetAudience == 'specific_major') ...[
                        DropdownButtonFormField<String>(
                          value: _selectedMajor,
                          decoration: InputDecoration(
                            labelText: 'Chọn ngành học',
                            prefixIcon: const Icon(LucideIcons.graduationCap),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: _majors.map((major) {
                            return DropdownMenuItem(
                              value: major,
                              child: Text(major),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedMajor = value;
                            });
                          },
                          validator: (value) {
                            if (_selectedTargetAudience == 'specific_major' && value == null) {
                              return 'Vui lòng chọn ngành học';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Year selection (if specific_year selected)
                      if (_selectedTargetAudience == 'specific_year') ...[
                        DropdownButtonFormField<String>(
                          value: _selectedYear,
                          decoration: InputDecoration(
                            labelText: 'Chọn năm học',
                            prefixIcon: const Icon(LucideIcons.calendar),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: _years.map((year) {
                            return DropdownMenuItem(
                              value: year,
                              child: Text(year),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedYear = value;
                            });
                          },
                          validator: (value) {
                            if (_selectedTargetAudience == 'specific_year' && value == null) {
                              return 'Vui lòng chọn năm học';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      const SizedBox(height: 24),

                      // Submit button
                      CustomButton(
                        text: widget.announcement != null ? 'Cập nhật' : 'Gửi thông báo',
                        icon: widget.announcement != null ? LucideIcons.save : LucideIcons.send,
                        onPressed: _isLoading ? null : _submitAnnouncement,
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
      ),
    );
  }
}
