import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/storage/token_storage.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authRepo = AuthRepository();
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  void _checkToken() async {
    final token = await TokenStorage.getToken();
    if (token != null && token.isNotEmpty) {
      _navigateToMain();
    }
  }

  void _handleLogin() async {
    final success = await _authRepo.login(
      _emailController.text, 
      _passwordController.text
    );

    if (success) {
      _navigateToMain();
    } else {
      setState(() {
        _errorMessage = "Неверный логин или пароль";
      });
    }
  }

  void _navigateToMain() {
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (context) => const MainScreen())
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Вход")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: "Пароль")),
            const SizedBox(height: 20),
            if (_errorMessage.isNotEmpty) 
              Text(_errorMessage, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _handleLogin,
              child: const Text("Войти"),
            ),
          ],
        ),
      ),
    );
  }
}