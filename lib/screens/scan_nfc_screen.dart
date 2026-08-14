import 'package:flutter/material.dart';

class ScanNfcScreen extends StatefulWidget {
  final int currentCardCount;

  const ScanNfcScreen({super.key, this.currentCardCount = 0});

  @override
  State<ScanNfcScreen> createState() => _ScanNfcScreenState();
}

class _ScanNfcScreenState extends State<ScanNfcScreen> {
  int _selectedTab = 0; // 0: NFC, 1: QR
  bool _isScanning = false;

  // Danh sách 3 thẻ mẫu chuẩn theo từng lần quét
  final List<Map<String, String>> _presetCards = [
    {
      'bank': 'Vietcombank',
      'type': 'Digital Card',
      'number': '4532 1547 0831 2904',
      'holder': 'NGUYEN VAN AN',
      'expires': '08/28',
      'brand': 'VISA',
      'openedDate': '15/03/2022',
      'initialBalance': '2500000',
      'theme': 'blue',
    },
    {
      'bank': 'Techcombank',
      'type': 'Digital Card',
      'number': '5412 7534 1809 3321',
      'holder': 'NGUYEN VAN AN',
      'expires': '11/27',
      'brand': 'MC',
      'openedDate': '20/10/2023',
      'initialBalance': '1800000',
      'theme': 'orange',
    },
    {
      'bank': 'MB Bank',
      'type': 'Digital Card',
      'number': '4916 2231 8844 5521',
      'holder': 'NGUYEN VAN AN',
      'expires': '03/29',
      'brand': 'VISA',
      'openedDate': '01/01/2024',
      'initialBalance': '3200000',
      'theme': 'green',
    },
  ];

  void _startScanning() async {
    if (widget.currentCardCount >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn đã liên kết tối đa 3 thẻ ngân hàng!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isScanning = true);

    // Mô phỏng 2 giây quét NFC
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Lấy thẻ tương ứng với lượt quét
    final newCard = _presetCards[widget.currentCardCount];

    // Trả thẻ về trang Home
    Navigator.pop(context, newCard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0B10),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Quét thanh toán',
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            // Tab Switcher
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1A24),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTab == 0 ? const Color(0xFF6C5CE7) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.wifi, color: _selectedTab == 0 ? Colors.white : Colors.white54, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Quét NFC',
                              style: TextStyle(
                                color: _selectedTab == 0 ? Colors.white : Colors.white54,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTab == 1 ? const Color(0xFF6C5CE7) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.qr_code_scanner, color: _selectedTab == 1 ? Colors.white : Colors.white54, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Quét QR',
                              style: TextStyle(
                                color: _selectedTab == 1 ? Colors.white : Colors.white54,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Khung NFC
            SizedBox(
              width: 230,
              height: 230,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Positioned(top: 0, left: 0, child: _CornerBracket(isTop: true, isLeft: true)),
                  const Positioned(top: 0, right: 0, child: _CornerBracket(isTop: true, isLeft: false)),
                  const Positioned(bottom: 0, left: 0, child: _CornerBracket(isTop: false, isLeft: true)),
                  const Positioned(bottom: 0, right: 0, child: _CornerBracket(isTop: false, isLeft: false)),

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1B26),
                      shape: BoxShape.circle,
                      boxShadow: _isScanning
                          ? [
                        BoxShadow(
                          color: const Color(0xFF6C5CE7).withOpacity(0.8),
                          blurRadius: 40,
                          spreadRadius: 12,
                        )
                      ]
                          : [],
                    ),
                    child: Icon(
                      Icons.wifi,
                      color: _isScanning ? const Color(0xFF20D89A) : const Color(0xFF8B6BFF),
                      size: 48,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            Text(
              _isScanning
                  ? 'Đang nhận diện thẻ ${widget.currentCardCount + 1}/3...'
                  : 'Đặt thẻ gần mặt sau điện thoại',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Đã liên kết ${widget.currentCardCount}/3 thẻ',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),

            const SizedBox(height: 32),

            // Nút Quét
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isScanning ? null : _startScanning,
                child: _isScanning
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('Bắt đầu quét', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _CornerBracket extends StatelessWidget {
  final bool isTop;
  final bool isLeft;
  const _CornerBracket({required this.isTop, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: Color(0xFF8B6BFF), width: 3) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: Color(0xFF8B6BFF), width: 3) : BorderSide.none,
          left: isLeft ? const BorderSide(color: Color(0xFF8B6BFF), width: 3) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: Color(0xFF8B6BFF), width: 3) : BorderSide.none,
        ),
      ),
    );
  }
}