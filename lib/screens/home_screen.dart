import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import 'scan_nfc_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _currentHomeCardPage = 0;
  int _currentManageCardPage = 0;

  final PageController _homePageController = PageController();
  final PageController _managePageController = PageController();
  final AuthService _authService = AuthService();

  double _balance = 0;
  String _userName = "Nguyễn Văn An";
  String _userEmail = "nguyen.van.an@email.com";
  bool _isNotificationOn = true;

  final List<Map<String, String>> _cards = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = _authService.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.displayName ?? "Nguyễn Văn An";
        _userEmail = user.email ?? "nguyen.van.an@email.com";
      });
    }
  }

  void _toggleNotification() {
    setState(() {
      _isNotificationOn = !_isNotificationOn;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isNotificationOn ? 'Đã bật thông báo' : 'Đã tắt thông báo'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _openScanNfcScreen() async {
    final newCard = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) => ScanNfcScreen(currentCardCount: _cards.length),
      ),
    );

    if (newCard != null) {
      setState(() {
        _cards.add(newCard);
        double cardBalance = double.tryParse(newCard['initialBalance'] ?? '0') ?? 0;
        _balance += cardBalance;
        _currentHomeCardPage = _cards.length - 1;
        _currentManageCardPage = _cards.length - 1;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã liên kết ${newCard['bank']} thành công!'),
          backgroundColor: const Color(0xFF20D89A),
        ),
      );

      Future.delayed(const Duration(milliseconds: 100), () {
        if (_homePageController.hasClients) {
          _homePageController.animateToPage(
            _currentHomeCardPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép $label!'),
        backgroundColor: const Color(0xFF8B6BFF),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0B10),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeTab(),
            _buildMyCardsTab(),
            const Center(child: Text('Trang Giao dịch', style: TextStyle(color: Colors.white))),
            _buildAccountTab(), // TAB 4: THÔNG TIN TÀI KHOẢN
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF12111A),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08), width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF8B6BFF),
          unselectedItemColor: Colors.white38,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Trang chủ'),
            BottomNavigationBarItem(icon: Icon(Icons.credit_card_rounded), label: 'Thẻ của tôi'),
            BottomNavigationBarItem(icon: Icon(Icons.swap_horiz_rounded), label: 'Giao dịch'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Tài khoản'),
          ],
        ),
      ),
    );
  }

  // ==================== TAB 1: TRANG CHỦ ====================
  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Xin chào,', style: TextStyle(color: Colors.white54, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(_userName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: _toggleNotification,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), shape: BoxShape.circle),
                      child: Icon(
                        _isNotificationOn ? Icons.notifications_none_rounded : Icons.notifications_off_outlined,
                        color: _isNotificationOn ? Colors.white70 : Colors.white24,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Bấm vào Profile Picture -> Chuyển sang Tab Tài khoản
                  GestureDetector(
                    onTap: () => setState(() => _selectedIndex = 3),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(color: Color(0xFF8B6BFF), shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text(
                        _userName.isNotEmpty ? _userName[0].toUpperCase() : 'N',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tổng số dư
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF16151F),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tổng số dư', style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 6),
                Text(
                  '${_balance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ',
                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.circle, color: _cards.isEmpty ? Colors.white38 : const Color(0xFF20D89A), size: 8),
                    const SizedBox(width: 6),
                    Text(
                      _cards.isEmpty ? 'Chưa liên kết thẻ ngân hàng' : '+2.4% so với tháng trước',
                      style: TextStyle(
                        color: _cards.isEmpty ? Colors.white38 : const Color(0xFF20D89A),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Thẻ của tôi', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: _openScanNfcScreen,
                child: const Text('Xem tất cả', style: TextStyle(color: Color(0xFF8B6BFF), fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 14),

          SizedBox(
            height: 185,
            child: PageView.builder(
              controller: _homePageController,
              itemCount: _cards.length + 1,
              onPageChanged: (index) => setState(() => _currentHomeCardPage = index),
              itemBuilder: (context, index) {
                if (index < _cards.length) {
                  return _buildStyledCreditCard(_cards[index]);
                } else {
                  return _buildVirtualAddCard();
                }
              },
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_cards.length + 1, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentHomeCardPage == index ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentHomeCardPage == index ? const Color(0xFF8B6BFF) : Colors.white24,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          _buildCardDetailPanel(_currentHomeCardPage),
          const SizedBox(height: 22),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSquareAction(icon: Icons.add, label: 'Nạp tiền', bgColor: const Color(0xFF262043), iconColor: const Color(0xFF8B6BFF)),
              _buildSquareAction(icon: Icons.arrow_forward_rounded, label: 'Chuyển', bgColor: const Color(0xFF382319), iconColor: const Color(0xFFFF8A65)),
              _buildSquareAction(icon: Icons.arrow_back_rounded, label: 'Nhận', bgColor: const Color(0xFF15352E), iconColor: const Color(0xFF20D89A)),
              _buildSquareAction(icon: Icons.wb_sunny_outlined, label: 'Khác', bgColor: const Color(0xFF24262E), iconColor: Colors.white70),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== TAB 2: THẺ CỦA TÔI ====================
  Widget _buildMyCardsTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Xin', style: TextStyle(color: Colors.white54, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(_userName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              GestureDetector(
                onTap: () => setState(() => _selectedIndex = 3),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(color: Color(0xFFE58BB1), shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(
                    _userName.isNotEmpty ? _userName[0].toUpperCase() : 'N',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (_cards.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.credit_card_off_rounded, size: 64, color: Colors.white.withOpacity(0.2)),
                    const SizedBox(height: 16),
                    const Text('Chưa có thẻ nào được thêm', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Hãy quét thẻ NFC ở Trang chủ để hiển thị tại đây', style: TextStyle(color: Colors.white38, fontSize: 12), textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5CE7),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _openScanNfcScreen,
                      icon: const Icon(Icons.wifi, color: Colors.white, size: 18),
                      label: const Text('Quét thẻ ngay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 185,
              child: PageView.builder(
                controller: _managePageController,
                itemCount: _cards.length,
                onPageChanged: (index) => setState(() => _currentManageCardPage = index),
                itemBuilder: (context, index) {
                  return _buildStyledCreditCard(_cards[index]);
                },
              ),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_cards.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentManageCardPage == index ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentManageCardPage == index ? const Color(0xFF8B6BFF) : Colors.white24,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            _buildCardDetailPanel(_currentManageCardPage),
            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E1D2B),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _openScanNfcScreen,
                      child: const Text('Quét thẻ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E1D2B),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Mở cài đặt quản lý thẻ...')),
                        );
                      },
                      child: const Text('Quản lý', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),

            Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C5CE7).withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chạm NFC để thanh toán ngay')),
                  );
                },
                icon: const Icon(Icons.wifi, color: Colors.white, size: 20),
                label: const Text('Thanh toán', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  // ==================== TAB 4: THÔNG TIN TÀI KHOẢN (ẢNH 1 & 2) ====================
  Widget _buildAccountTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Top
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tài khoản', style: TextStyle(color: Colors.white54, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(_userName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: _toggleNotification,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), shape: BoxShape.circle),
                      child: Icon(
                        _isNotificationOn ? Icons.notifications_none_rounded : Icons.notifications_off_outlined,
                        color: _isNotificationOn ? Colors.white70 : Colors.white24,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(color: Color(0xFF8B6BFF), shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Text(
                      _userName.isNotEmpty ? _userName[0].toUpperCase() : 'N',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // User Profile Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF16151F),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Color(0xFF8B6BFF),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _userName.isNotEmpty ? _userName[0].toUpperCase() : 'N',
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF20D89A),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF16151F), width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_userName, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(_userEmail, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(color: Color(0xFF20D89A), shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          const Text('Tài khoản đã xác minh', style: TextStyle(color: Color(0xFF20D89A), fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.edit_outlined, color: Colors.white60, size: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // KHUNG 1: THÔNG TIN CÁ NHÂN
          _buildInfoSection(
            icon: Icons.person_outline_rounded,
            title: 'Thông tin cá nhân',
            children: [
              _buildAccountRow('Họ và tên', _userName),
              Divider(color: Colors.white.withOpacity(0.06), height: 24),
              _buildAccountRow('Ngày sinh', '15/03/1995'),
              Divider(color: Colors.white.withOpacity(0.06), height: 24),
              _buildAccountRow('Giới tính', 'Nam'),
              Divider(color: Colors.white.withOpacity(0.06), height: 24),
              _buildAccountRowWithCopy('CCCD / CMND', '••••••••1234', '079195001234'),
            ],
          ),
          const SizedBox(height: 16),

          // KHUNG 2: THÔNG TIN LIÊN HỆ
          _buildInfoSection(
            icon: Icons.alternate_email_rounded,
            title: 'Thông tin liên hệ',
            children: [
              _buildAccountRowWithDot('Email', _userEmail),
              Divider(color: Colors.white.withOpacity(0.06), height: 24),
              _buildAccountRowWithDot('Số điện thoại', '+84 912 345 678'),
              Divider(color: Colors.white.withOpacity(0.06), height: 24),
              _buildAccountRow('Địa chỉ', '123 Nguyễn Huệ, Q.1, TP.HCM'),
            ],
          ),
          const SizedBox(height: 16),

          // KHUNG 3: THÔNG TIN TÀI KHOẢN NGÂN HÀNG
          _buildInfoSection(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Thông tin tài khoản ngân hàng',
            children: [
              _buildAccountRowWithCopy('Số tài khoản', '•••• •••• 2904', '4532154708312904'),
              Divider(color: Colors.white.withOpacity(0.06), height: 24),
              _buildAccountRow('Ngân hàng', _cards.isNotEmpty ? _cards[0]['bank']! : 'Vietcombank'),
              Divider(color: Colors.white.withOpacity(0.06), height: 24),
              _buildAccountRow('Ngày mở thẻ', _cards.isNotEmpty ? (_cards[0]['openedDate'] ?? '15/03/2022') : '15/03/2022'),
              Divider(color: Colors.white.withOpacity(0.06), height: 24),
              _buildAccountRow('Loại tài khoản', 'Tài khoản thanh toán'),
              Divider(color: Colors.white.withOpacity(0.06), height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Trạng thái', style: TextStyle(color: Colors.white54, fontSize: 13)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF20D89A).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.circle, color: Color(0xFF20D89A), size: 6),
                        SizedBox(width: 6),
                        Text('Đang hoạt động', style: TextStyle(color: Color(0xFF20D89A), fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // NÚT ĐĂNG XUẤT (ẢNH 2)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFF231215),
                side: const BorderSide(color: Color(0xFF5E2228), width: 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () async {
                await _authService.signOut();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã đăng xuất tài khoản')),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, color: Color(0xFFFF4D4D), size: 20),
                  SizedBox(width: 8),
                  Text('Đăng xuất', style: TextStyle(color: Color(0xFFFF4D4D), fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Helper Widget dựng Khung nhóm thông tin
  Widget _buildInfoSection({required IconData icon, required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF16151F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF8B6BFF), size: 18),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildAccountRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildAccountRowWithDot(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
        Row(
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(width: 6),
            Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF20D89A), shape: BoxShape.circle)),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountRowWithCopy(String label, String displayValue, String rawValue) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
        Row(
          children: [
            Text(displayValue, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => _copyToClipboard(rawValue, label),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF282441),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Sao chép', style: TextStyle(color: Color(0xFF8B6BFF), fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helpers cho Thẻ
  Widget _buildStyledCreditCard(Map<String, String> card) {
    List<Color> gradientColors;
    final theme = card['theme'] ?? 'blue';

    if (theme == 'orange') {
      gradientColors = const [Color(0xFFFA5E29), Color(0xFFB52D0A)];
    } else if (theme == 'green') {
      gradientColors = const [Color(0xFF00A86B), Color(0xFF005C3B)];
    } else {
      gradientColors = const [Color(0xFF3B4CCA), Color(0xFF1E2675)];
    }

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(card['bank']!, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
              Text(card['brand']!, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
            ],
          ),
          Row(
            children: [
              Container(width: 30, height: 22, decoration: BoxDecoration(color: const Color(0xFFE2B857), borderRadius: BorderRadius.circular(4))),
              const SizedBox(width: 8),
              const Icon(Icons.wifi, color: Colors.white54, size: 16),
            ],
          ),
          Text(card['number']!, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.6)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(card['holder']!, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              Text(card['expires']!, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVirtualAddCard() {
    return GestureDetector(
      onTap: _openScanNfcScreen,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF16151F),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF8B6BFF).withOpacity(0.5), width: 1.5),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: Color(0xFF262043), shape: BoxShape.circle),
                child: const Icon(Icons.add_rounded, color: Color(0xFF8B6BFF), size: 26),
              ),
              const SizedBox(height: 10),
              const Text('Thêm thẻ ngân hàng', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              const Text('Chạm thẻ NFC để liên kết ngay', style: TextStyle(color: Colors.white38, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardDetailPanel(int currentPage) {
    if (_cards.isEmpty || currentPage >= _cards.length) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF16151F),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          children: [
            _buildDetailRow('Số tài khoản', '•••• ----'),
            Divider(color: Colors.white.withOpacity(0.06), height: 20),
            _buildDetailRow('Ngày mở thẻ', '--/--/----'),
            Divider(color: Colors.white.withOpacity(0.06), height: 20),
            _buildDetailRow('Ngân hàng', 'Chưa liên kết'),
          ],
        ),
      );
    }

    final activeCard = _cards[currentPage];
    final cardNumber = activeCard['number'] ?? '';
    final last4 = cardNumber.length >= 4 ? cardNumber.substring(cardNumber.length - 4) : '2904';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF16151F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          _buildDetailRow('Số tài khoản', '•••• $last4'),
          Divider(color: Colors.white.withOpacity(0.06), height: 20),
          _buildDetailRow('Ngày mở thẻ', activeCard['openedDate'] ?? '15/03/2022'),
          Divider(color: Colors.white.withOpacity(0.06), height: 20),
          _buildDetailRow('Ngân hàng', activeCard['bank'] ?? 'Vietcombank'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w400)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildSquareAction({required IconData icon, required String label, required Color bgColor, required Color iconColor}) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    );
  }
}