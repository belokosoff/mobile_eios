import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eios/presentation/screens/login/login_screen.dart';

import 'bloc/profile_bloc.dart';
import 'bloc/profile_event.dart';
import 'bloc/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc()..add(ProfileStarted()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Выход'),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context.read<ProfileBloc>().add(ProfileLogoutRequested());
            },
            child: const Text('Выйти', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (prev, curr) =>
          curr.logoutSuccess ||
          (curr.errorMessage != prev.errorMessage && curr.errorMessage != null),
      listener: (context, state) {
        if (state.logoutSuccess) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
          return;
        }

        if (state.errorMessage != null && state.isLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Профиль"),
          actions: [
            BlocBuilder<ProfileBloc, ProfileState>(
              buildWhen: (prev, curr) => prev.isLoading != curr.isLoading,
              builder: (context, state) => IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: state.isLoading
                    ? null
                    : () => context.read<ProfileBloc>().add(ProfileRefreshed()),
                tooltip: 'Обновить',
              ),
            ),
            IconButton(
              icon: const Icon(Icons.output_outlined),
              onPressed: () => _showLogoutDialog(context),
              tooltip: 'Выйти',
            ),
          ],
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) => _buildBody(context, state),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProfileState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.isError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Ошибка загрузки профиля',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                state.errorMessage ?? '',
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () =>
                    context.read<ProfileBloc>().add(ProfileStarted()),
                icon: const Icon(Icons.refresh),
                label: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    final user = state.user;
    if (user == null) {
      return const Center(child: Text('Нет данных'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProfileBloc>().add(ProfileRefreshed());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildAvatar(context, user.photo?.urlMedium),
            const SizedBox(height: 20),
            Text(
              user.fio ?? "Имя не указано",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (user.email != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.email, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    user.email!,
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            const Divider(),
            _buildInfoSection(user),
            const Divider(height: 32),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Выйти из аккаунта",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () => _showLogoutDialog(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, String? photoUrl) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          width: 3,
        ),
      ),
      child: CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey[200],
        backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
        child: photoUrl == null
            ? Icon(Icons.person, size: 60, color: Colors.grey[400])
            : null,
      ),
    );
  }

  Widget _buildInfoSection(dynamic user) {
    return Column(
      children: [
        if (user.fio != null)
          _buildInfoTile(
            icon: Icons.person_outline,
            label: 'Фамилия',
            value: user.fio!,
          ),
        if (user.birthDate != null)
          _buildInfoTile(
            icon: Icons.cake_outlined,
            label: 'Дата рождения',
            value: _formatDate(user.birthDate!),
          ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
