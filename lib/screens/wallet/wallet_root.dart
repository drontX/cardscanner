import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/wallet_models.dart';
import '../../utils/app_routes.dart';
import '../splash_screen.dart';

class WalletRoot extends StatefulWidget {
  const WalletRoot({super.key});

  @override
  State<WalletRoot> createState() => _WalletRootState();
}

class _WalletRootState extends State<WalletRoot> {
  int _currentIndex = 0;
  final List<BankCard> _cards = List.from(kInitialCards);

  void _showNFCModal(BankCard card) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: kMuted.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: card.accentColor.withOpacity(0.15),
              ),
              child: Icon(Icons.nfc, size: 40, color: card.accentColor),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sẵn sàng thanh toán NFC',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kText),
            ),
            const SizedBox(height: 8),
            Text(
              'Chạm lưng điện thoại vào máy POS của ${card.bank}',
              style: const TextStyle(fontSize: 13, color: kMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Hủy bỏ', style: TextStyle(color: kText)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildCardsHome(),
            const Center(child: Text('Lịch sử giao dịch', style: TextStyle(color: kText))),
            _buildProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: kBorder)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: kSurface,
          selectedItemColor: kAccent,
          unselectedItemColor: kMuted,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: 'Ví thẻ'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Giao dịch'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Cá nhân'),
          ],
        ),
      ),
    );
  }

  Widget _buildCardsHome() {
    final userName = AuthState.fullName ?? 'Nguyễn Văn An';
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Xin chào,', style: TextStyle(fontSize: 13, color: kMuted)),
                Text(userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kText)),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: kAccent, size: 28),
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text('Thẻ của bạn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kText)),
        const SizedBox(height: 16),
        ..._cards.map((card) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: () => _showNFCModal(card),
            child: Container(
              height: 190,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: card.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(color: card.accentColor.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(card.bank, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      Icon(card.type == CardType.visa ? Icons.credit_card : Icons.payment, color: Colors.white),
                    ],
                  ),
                  Text('•••• •••• •••• ${card.lastFour}', style: const TextStyle(fontSize: 20, letterSpacing: 2, color: Colors.white, fontWeight: FontWeight.w600)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('CHỦ THẺ', style: TextStyle(fontSize: 9, color: Colors.white70)),
                          Text(card.holder, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('HẠN DÙNG', style: TextStyle(fontSize: 9, color: Colors.white70)),
                          Text(card.expiry, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildProfileTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tài khoản', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kText)),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.person, color: kAccent),
            title: Text(AuthState.fullName ?? 'Nguyễn Văn An', style: const TextStyle(color: kText)),
            subtitle: Text(AuthState.phoneNumber ?? '0987654321', style: const TextStyle(color: kMuted)),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                AuthState.isLoggedIn = false;
                Navigator.of(context).pushAndRemoveUntil(
                  fadeRoute(const SplashScreen()),
                      (_) => false,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: kAccent2),
              child: const Text('Đăng xuất', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}