import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart'; // 1. Import thư viện Firebase
import 'constants/app_colors.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
void main() async { // 2. Thêm từ khóa async ở đây
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Khởi tạo Firebase trước khi chạy app
  await Firebase.initializeApp();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const CardWalletApp());
}

class CardWalletApp extends StatelessWidget {
  const CardWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CardWallet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          surface: kSurface,
          primary: kAccent,
        ),
        scaffoldBackgroundColor: kBg,
        fontFamily: 'SF Pro Display',
        useMaterial3: true,
      ),
        home: const WelcomeScreen()
    );
  }
}