import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth/auth_bloc.dart';
import 'orders_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: Text('Не авторизован')),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Профиль'),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Выход'),
                      content: const Text('Вы уверены, что хотите выйти?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Отмена'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            context.read<AuthBloc>().add(SignOutEvent());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Выйти'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.black,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  state.user.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.user.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.email),
                        title: const Text('Email'),
                        subtitle: Text(state.user.email),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Имя'),
                        subtitle: Text(state.user.name),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.badge),
                        title: const Text('Роль'),
                        subtitle: Text(
                          state.user.role == 'admin'
                              ? 'Администратор'
                              : 'Пользователь',
                        ),
                      ),
                      if (state.user.phone != null) ...[
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.phone),
                          title: const Text('Телефон'),
                          subtitle: Text(state.user.phone!),
                        ),
                      ],
                      if (state.user.address != null) ...[
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.location_on),
                          title: const Text('Адрес'),
                          subtitle: Text(state.user.address!),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('История заказов'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrdersPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<AuthBloc>().add(SignOutEvent());
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Выйти из аккаунта'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
