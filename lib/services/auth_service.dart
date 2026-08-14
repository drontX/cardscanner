import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Getter lấy thông tin User hiện tại
  User? get currentUser => _auth.currentUser;

  // 2. Hàm Đăng ký
  Future<String?> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Cập nhật tên hiển thị cho user
      await credential.user?.updateDisplayName(fullName);
      return null; // Không có lỗi
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // 3. Hàm Đăng nhập
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Không có lỗi
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // 4. Hàm Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
  }
}