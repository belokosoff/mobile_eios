import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'data/storage/token_storage.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/tabs_screen.dart';
import 'core/network/api_service.dart';
import 'core/navigation/navigator_key.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  ApiClient().init();
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _initialScreen = const Scaffold(
    body: Center(child: CircularProgressIndicator()),
  );

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final token = await TokenStorage.getAccessToken();
      if (!mounted) return;

      setState(() {
        if (token != null && token.isNotEmpty) {
          _initialScreen = const TabsScreen();
        } else {
          _initialScreen = const LoginScreen();
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => _initialScreen = const LoginScreen());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'EIOS App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: _initialScreen,
    );
  }
}
