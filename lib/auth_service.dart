import 'package:puantaj_takip_sistemi/user_model.dart';

class AuthService {
  // Sahte (mock) kullanıcı veritabanı.
  // Gerçek bir uygulamada bu veriler bir sunucudan veya Firebase'den gelir.
  final List<User> _users = [
    User(id: '1', username: 'resulyilal', role: UserRole.regular),
    User(id: '2', username: 'bektas', role: UserRole.admin),
    User(id: '3', username: 'tolga', role: UserRole.superAdmin),
  ];

  // Sahte (mock) şifreler. Şifreleri asla bu şekilde saklamayın!
  final Map<String, String> _passwords = {
    'resulyilal': '1907',
    'bektas': '1907',
    'tolga': '1907',
  };

  Future<User?> login(String username, String password) async {
    // Simülasyon için küçük bir gecikme ekleyelim.
    await Future.delayed(const Duration(seconds: 1));

    try {
      final user = _users.firstWhere((u) => u.username == username);
      if (_passwords[username] == password) {
        return user;
      }
      return null;
    } catch (e) {
      return null; // Kullanıcı bulunamadı
    }
  }
}