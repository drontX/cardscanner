import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/step_header.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    // 1. Kiểm tra thông tin rỗng
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin!')),
      );
      return;
    }

    // 2. Kiểm tra mật khẩu khớp
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu xác nhận không khớp!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Gọi Firebase đăng ký
      String? error = await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _nameController.text.trim(),
      );

      if (!mounted) return;

      if (error == null) {
        // Đăng ký Firebase thành công -> Chuyển sang Bước 2 (Nhập OTP)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpScreen(
              phoneNumber: _phoneController.text.trim().isEmpty
                  ? '0901 234 567'
                  : _phoneController.text.trim(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $error')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xảy ra lỗi: ${e.toString()}')),
        );
      }
    } finally {
      // Luôn luôn dừng xoay loading dù thành công hay thất bại
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D12),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Thanh tiến trình Bước 1/3
              const StepHeader(
                currentStep: 1,
                title: 'Đăng ký',
                subtitle: 'Bước 1/3 — Thông tin cơ bản',
              ),
              const SizedBox(height: 24),
              const Text(
                'Tạo tài khoản\nmới ✨',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Họ và tên',
                hint: 'Nguyễn Văn An',
                prefixIcon: Icons.person_outline,
                controller: _nameController,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Email',
                hint: 'an@email.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Số điện thoại',
                hint: '0901 234 567',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                controller: _phoneController,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Mật khẩu',
                hint: 'Ít nhất 6 ký tự',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Xác nhận mật khẩu',
                hint: 'Nhập lại mật khẩu',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                controller: _confirmPasswordController,
              ),
              const SizedBox(height: 28),
              _isLoading
                  ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF6C5CE7)),
              )
                  : PrimaryButton(
                text: 'Tiếp theo ➔',
                onPressed: _handleRegister,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}