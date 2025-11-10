import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _studentIdController;
  late TextEditingController _phoneController;
  String? _selectedMajor;
  String? _selectedYear;

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
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final user = appProvider.currentUser;
    
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _studentIdController = TextEditingController(text: user?.studentId ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _selectedMajor = user?.major ?? '';
    _selectedYear = user?.year ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _studentIdController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      
      final updatedUser = appProvider.currentUser?.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        major: _selectedMajor ?? '',
        year: _selectedYear ?? '',
      );

      if (updatedUser != null) {
        // TODO: Call update user API when implemented
        // await SupabaseService.updateUser(updatedUser);
        appProvider.updateUser(updatedUser);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật thông tin thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
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
        title: const Text('Chỉnh sửa hồ sơ'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _handleSave,
            child: const Text(
              'Lưu',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Picture
              Center(
                child: Stack(
                  children: [
                    CustomAvatar(
                      initials: _nameController.text
                          .split(' ')
                          .map((n) => n.isNotEmpty ? n[0] : '')
                          .join(''),
                      radius: 50,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          LucideIcons.camera,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Name Input
              CustomInput(
                controller: _nameController,
                labelText: 'Họ và tên',
                hintText: 'Nhập họ tên của bạn',
                prefixIcon: LucideIcons.user,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập họ tên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email Input (readonly)
              CustomInput(
                controller: _emailController,
                labelText: 'Email',
                enabled: false,
                prefixIcon: LucideIcons.mail,
              ),
              const SizedBox(height: 16),

              // Student ID Input (readonly)
              CustomInput(
                controller: _studentIdController,
                labelText: 'Mã số sinh viên',
                enabled: false,
                prefixIcon: LucideIcons.creditCard,
              ),
              const SizedBox(height: 16),

              // Major Dropdown
              DropdownButtonFormField<String>(
                value: _selectedMajor,
                decoration: InputDecoration(
                  label: const Text('Ngành học'),
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
                  setState(() => _selectedMajor = value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng chọn ngành học';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Year Dropdown
              DropdownButtonFormField<String>(
                value: _selectedYear,
                decoration: InputDecoration(
                  label: const Text('Năm học'),
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
                  setState(() => _selectedYear = value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng chọn năm học';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone Input
              CustomInput(
                controller: _phoneController,
                labelText: 'Số điện thoại',
                hintText: '0123456789',
                keyboardType: TextInputType.phone,
                prefixIcon: LucideIcons.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

