import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/auth_widgets.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  // Danh sách hình ảnh các thẻ (Thay đường dẫn ảnh của bạn vào đây)
  final List<Map<String, String>> _cardList = [
    {
      'imagePath': 'assets/images/card_vietcombank.png',
      'title': 'Vietcombank Card',
    },
    {
      'imagePath': 'assets/images/card_techcombank.png',
      'title': 'Techcombank Card',
    },
    {
      'imagePath': 'assets/images/card_mbbank.png',
      'title': 'MB Bank Card',
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < _cardList.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D12),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Logo
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB062FF), Color(0xFFFF5280)],
                  ),
                ),
                child: const Icon(Icons.credit_card, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ứng dụng quét thẻ ngân hàng',
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, height: 1.2),
              ),
              const SizedBox(height: 10),
              Text(
                'Lưu trữ thẻ Visa & Mastercard chip EMV.\nThanh toán không tiếp xúc qua NFC.',
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              // Badges
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildChip('🔒 Bảo mật cao'),
                  _buildChip('⚡ NFC'),
                  _buildChip('⚡ Nhanh chóng'),
                  _buildChip('🏦 Đa ngân hàng'),
                ],
              ),
              const Spacer(),

              // Kích thước thẻ đã được chỉnh to hơn (Height 210)
              SizedBox(
                height: 210,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _cardList.length,
                  itemBuilder: (context, index) {
                    final item = _cardList[index];
                    return _buildCardImageSlot(
                      imagePath: item['imagePath']!,
                      title: item['title']!,
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              // Indicator chấm tròn
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _cardList.length,
                      (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 22 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? const Color(0xFF8B6BFF) : Colors.white24,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),

              const Spacer(),
              // Actions
              PrimaryButton(
                text: 'Đăng nhập',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withOpacity(0.15)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Tạo tài khoản', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Bảo mật bởi mã hóa AES-256 & chip EMV',
                  style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
    );
  }

  // Khung hiển thị ảnh thẻ (To hơn & có ô chờ chèn ảnh)
  Widget _buildCardImageSlot({required String imagePath, required String title}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B6BFF).withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          // Nếu chưa khai báo hoặc chưa bỏ ảnh vào assets, sẽ hiện giao diện chờ dưới đây
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF2A2A38), Color(0xFF161622)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined, color: Colors.white.withOpacity(0.4), size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'Bỏ ảnh thẻ vào đây\n($title)',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}