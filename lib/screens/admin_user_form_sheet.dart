import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/user.dart' as app_models;
import '../services/admin_service.dart';
import '../widgets/common_widgets.dart';

class AdminUserFormSheet extends StatefulWidget {
  final app_models.User? user;

  const AdminUserFormSheet({super.key, this.user});

  @override
  State<AdminUserFormSheet> createState() => _AdminUserFormSheetState();
}

class _AdminUserFormSheetState extends State<AdminUserFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String? _selectedMajor;
  String? _selectedYear;
  String? _selectedRole;
  bool _isLoading = false;

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

  final List<String> _roles = [
    'user',
    'club_leader',
    'admin',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _nameController.text = widget.user!.name;
      _emailController.text = widget.user!.email;
      _studentIdController.text = widget.user!.studentId;
      _phoneController.text = widget.user!.phone ?? '';
      _selectedMajor = widget.user!.major;
      _selectedYear = widget.user!.year;
      _selectedRole = widget.user!.role.value;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _studentIdController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'user':
        return 'Sinh viên';
      case 'club_leader':
        return 'Trưởng CLB';
      case 'admin':
        return 'Quản trị viên';
      default:
        return role;
    }
  }

  Future<void> _submitUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final userData = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'student_id': _studentIdController.text.trim(),
      'phone': _phoneController.text.trim(),
      'major': _selectedMajor ?? '',
      'year': _selectedYear ?? '',
      'role': _selectedRole ?? 'user',
    };

    bool success;
    if (widget.user != null) {
      success = await AdminService.updateUser(widget.user!.id, userData);
    } else {
      success = await AdminService.createUser(userData);
    }

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.user != null
                ? 'Đã cập nhật người dùng thành công'
                : 'Đã tạo người dùng thành công'),
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
        title: Text(widget.user != null ? 'Sửa người dùng' : 'Thêm người dùng mới'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
                    children: [
                      CustomInput(
                        controller: _nameController,
                        hintText: 'Họ và tên',
                        labelText: 'Họ và tên',
                        prefixIcon: LucideIcons.user,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập họ và tên';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomInput(
                        controller: _emailController,
                        hintText: 'Email',
                        labelText: 'Email',
                        prefixIcon: LucideIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập email';
                          }
                          if (!value.contains('@')) {
                            return 'Email không hợp lệ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomInput(
                        controller: _studentIdController,
                        hintText: 'Mã sinh viên',
                        labelText: 'Mã sinh viên',
                        prefixIcon: LucideIcons.creditCard,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập mã sinh viên';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomInput(
                        controller: _phoneController,
                        hintText: 'Số điện thoại',
                        labelText: 'Số điện thoại',
                        prefixIcon: LucideIcons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedMajor,
                        decoration: InputDecoration(
                          labelText: 'Ngành học',
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
                          if (value == null) {
                            return 'Vui lòng chọn ngành học';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedYear,
                        decoration: InputDecoration(
                          labelText: 'Năm học',
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
                          if (value == null) {
                            return 'Vui lòng chọn năm học';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: InputDecoration(
                          labelText: 'Vai trò',
                          prefixIcon: const Icon(LucideIcons.shield),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _roles.map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(_getRoleLabel(role)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Vui lòng chọn vai trò';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: widget.user != null ? 'Cập nhật' : 'Tạo người dùng',
                        icon: widget.user != null ? LucideIcons.save : LucideIcons.plus,
                        onPressed: _isLoading ? null : _submitUser,
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
      ),
    );
  }
}

