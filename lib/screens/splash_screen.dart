import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/app_routes.dart';
import 'wallet/wallet_root.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        fadeRoute(const WalletRoot()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Logo App
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: kAccent,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: kAccent.withOpacity(0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                size: 42,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // App Name
            const Text(
              'CardWallet',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: kText,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Quản lý thẻ & Thanh toán NFC',
              style: TextStyle(fontSize: 14, color: kMuted),
            ),

            const SizedBox(height: 48),

            // Loading indicator
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: kAccent,
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}