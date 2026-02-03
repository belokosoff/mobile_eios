import 'package:eios/data/storage/token_storage.dart';
import 'package:eios/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserModel> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = UserRepository().getUserProfile();
  }

  void _logout() async {
    await TokenStorage.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Профиль")),
      body: FutureBuilder<UserModel>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
             return Center(child: Text("Ошибка: ${snapshot.error}"));
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user.photo?.urlMedium != null
                      ? NetworkImage(user.photo!.urlMedium!)
                      : const AssetImage('assets/placeholder.png') as ImageProvider,
                ),
                const SizedBox(height: 16),
                Text(
                  user.fio ?? "Фамилия не указана",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  user.email ?? "Email не указан",
                  style: const TextStyle(color: Colors.grey),
                ),
                const Divider(height: 32),
                Wrap(
                  spacing: 8,
                  children: user.roles!.map((role) => Chip(
                    label: Text(role.name ?? ''),
                    backgroundColor: Colors.blue.shade50,
                  )).toList(),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text("Выйти из аккаунта", style: TextStyle(color: Colors.red)),
                  onTap: _logout,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}