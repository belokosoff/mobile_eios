import 'package:eios/presentation/screens/tabs_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/storage/token_storage.dart';

class LoginScreen extends StatefulWidget {
  @Preview(
    name: "123",
    textScaleFactor: 1.0,
    brightness: Brightness.dark
  )
  
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
    final token = await TokenStorage.getAccessToken();
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
      MaterialPageRoute(builder: (context) => const TabsScreen())
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
            SizedBox(
              width: 250,
              child: TextField(controller: _emailController, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Email")),
            ),
            Padding(padding: const EdgeInsets.all(12.0)),
            SizedBox(
              width: 250,
              child: TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Пароль")),
            ),
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