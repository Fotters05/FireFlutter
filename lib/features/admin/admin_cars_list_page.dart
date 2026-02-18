import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../auth/auth_bloc.dart';
import '../cars/car_bloc.dart';
import 'admin_edit_car_page.dart';

class AdminCarsListPage extends StatelessWidget {
  const AdminCarsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: Text('Не авторизован')),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text('Админ-панель - ${authState.user.name}'),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  context.read<AuthBloc>().add(SignOutEvent());
                },
              ),
            ],
          ),
          body: BlocBuilder<CarBloc, CarState>(
            builder: (context, state) {
              if (state is CarInitial) {
                context.read<CarBloc>().add(
                      LoadCarsEvent(userId: authState.user.uid),
                    );
                return const Center(child: CircularProgressIndicator());
              }

              if (state is CarLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.black),
                );
              }

              if (state is CarError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Ошибка: ${state.message}'),
                    ],
                  ),
                );
              }

              if (state is CarLoaded) {
                if (state.cars.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_car_outlined,
                            size: 100, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Нет автомобилей',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Добавьте первый автомобиль',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.cars.length,
                  itemBuilder: (context, index) {
                    final car = state.cars[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: car.imageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: car.imageUrl!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[200],
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.directions_car),
                                  ),
                                )
                              : Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.directions_car),
                                ),
                        ),
                        title: Text('${car.brand} ${car.model}'),
                        subtitle: Text(
                          '${car.year} г. • ${car.price.toStringAsFixed(0)} ₽',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditCarPageAdmin(
                                      userId: authState.user.uid,
                                      car: car,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (dialogContext) => AlertDialog(
                                    title: const Text('Удалить автомобиль?'),
                                    content: Text(
                                      'Вы уверены, что хотите удалить ${car.brand} ${car.model}?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(dialogContext),
                                        child: const Text('Отмена'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          context.read<CarBloc>().add(
                                                DeleteCarEvent(
                                                  carId: car.id,
                                                  userId: authState.user.uid,
                                                ),
                                              );
                                          Navigator.pop(dialogContext);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text('Автомобиль удален'),
                                              backgroundColor: Colors.green,
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Удалить'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }

              return const Center(child: Text('Неизвестное состояние'));
            },
          ),
        );
      },
    );
  }
}
