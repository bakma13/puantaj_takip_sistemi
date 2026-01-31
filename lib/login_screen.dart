import 'package:flutter/material.dart';
import 'package:puantaj_takip_sistemi/user_model.dart';
import 'package:puantaj_takip_sistemi/dashboard_screen.dart';
import 'package:puantaj_takip_sistemi/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final User? user = await _authService.login(
        _usernameController.text,
        _passwordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (user != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => DashboardScreen(user: user)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kullanıcı adı veya şifre hatalı!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giriş Yap')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // EKLENEN BÖLÜM: Giriş ekranı görseli
                Image.asset(
                  'assets/images/bvs.png', // pubspec.yaml dosyanızda bu görsel tanımlıydı
                  height: 150, // Görselin yüksekliğini ayarlayabilirsiniz
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 100, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                // EKLENEN BÖLÜM SONU
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Kullanıcı Adı'),
                  validator: (value) =>
                      (value?.isEmpty ?? true) ? 'Bu alan boş bırakılamaz' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Şifre'),
                  obscureText: true,
                  validator: (value) =>
                      (value?.isEmpty ?? true) ? 'Bu alan boş bırakılamaz' : null,
                ),
                const SizedBox(height: 32),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _login,
                        child: const Text('Giriş Yap'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}