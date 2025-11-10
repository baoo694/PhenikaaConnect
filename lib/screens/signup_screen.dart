import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';
import 'main_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _studentIdController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      
      final userData = {
        'email': _emailController.text.trim(),
        'student_id': _studentIdController.text.trim(),
        'name': _nameController.text.trim(),
        'major': _selectedMajor ?? '',
        'year': _selectedYear ?? '',
        'phone': _phoneController.text.trim(),
      };

      final errorMessage = await appProvider.signUp(
        _emailController.text.trim(),
        _passwordController.text,
        userData,
      );

      if (errorMessage == null) {
        // Load user data
        await appProvider.loadCurrentUser();
        await appProvider.initialize();

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Email Input
                CustomInput(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'email@phenikaa.edu.vn',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: LucideIcons.mail,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!value.contains('@')) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Input
                CustomInput(
                  controller: _passwordController,
                  labelText: 'Mật khẩu',
                  hintText: 'Tối thiểu 6 ký tự',
                  obscureText: _obscurePassword,
                  prefixIcon: LucideIcons.lock,
                  suffixIcon: _obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
                  onSuffixTap: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    if (value.length < 6) {
                      return 'Mật khẩu phải có ít nhất 6 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password Input
                CustomInput(
                  controller: _confirmPasswordController,
                  labelText: 'Xác nhận mật khẩu',
                  hintText: 'Nhập lại mật khẩu',
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: LucideIcons.lock,
                  suffixIcon: _obscureConfirmPassword ? LucideIcons.eye : LucideIcons.eyeOff,
                  onSuffixTap: () {
                    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng xác nhận mật khẩu';
                    }
                    if (value != _passwordController.text) {
                      return 'Mật khẩu không khớp';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

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

                // Student ID Input
                CustomInput(
                  controller: _studentIdController,
                  labelText: 'Mã số sinh viên',
                  hintText: 'PH12345',
                  prefixIcon: LucideIcons.creditCard,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mã số sinh viên';
                    }
                    return null;
                  },
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
                const SizedBox(height: 32),

                // Sign Up Button
                CustomButton(
                  text: 'Đăng ký',
                  onPressed: _isLoading ? null : _handleSignUp,
                  size: ButtonSize.large,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Đã có tài khoản? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Đăng nhập ngay'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

