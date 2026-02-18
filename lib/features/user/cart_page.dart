import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../auth/auth_bloc.dart';
import '../cart/cart_bloc.dart';
import '../cart/cart_models.dart' as models;
import '../cart/order_repository.dart';
import '../../injection_container.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

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
            title: const Text('Корзина'),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state is! CartLoaded || state.items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          size: 100, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Корзина пуста',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        return _CartItemCard(item: item);
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Итого:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${state.totalAmount.toStringAsFixed(0)} ₽',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _checkout(context, state, authState.user),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Оформить заказ',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _checkout(BuildContext context, CartLoaded cartState, user) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final order = models.Order(
        id: '',
        userId: user.uid,
        items: cartState.items
            .map((item) => models.OrderItem(
                  carId: item.car.id,
                  brand: item.car.brand,
                  model: item.car.model,
                  price: item.car.price,
                  quantity: item.quantity,
                  imageUrl: item.car.imageUrl,
                ))
            .toList(),
        totalAmount: cartState.totalAmount,
        status: 'pending',
        createdAt: DateTime.now(),
        userEmail: user.email,
        userName: user.name,
        userPhone: user.phone,
        userAddress: user.address,
      );

      final repository = sl<OrderRepository>();
      final result = await repository.createOrder(order);

      result.fold(
        (failure) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        (orderId) async {
          // Очищаем корзину
          context.read<CartBloc>().add(ClearCartEvent());

          Navigator.pop(context);
          
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Заказ оформлен!'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Номер заказа: #${orderId.substring(0, 8).toUpperCase()}'),
                  const SizedBox(height: 8),
                  const Text('Спасибо за ваш заказ!'),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

class _CartItemCard extends StatelessWidget {
  final models.CartItem item;

  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.car.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: item.car.imageUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Icon(Icons.directions_car),
                      ),
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(Icons.directions_car),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.car.brand} ${item.car.model}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.car.price.toStringAsFixed(0)} ₽',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (item.quantity > 1) {
                            context.read<CartBloc>().add(
                                  UpdateQuantityEvent(
                                    item.car.id,
                                    item.quantity - 1,
                                  ),
                                );
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: item.quantity >= 5
                            ? null
                            : () {
                                context.read<CartBloc>().add(
                                      UpdateQuantityEvent(
                                        item.car.id,
                                        item.quantity + 1,
                                      ),
                                    );
                                if (item.quantity + 1 >= 5) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Максимум 5 штук'),
                                      duration: Duration(seconds: 2),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                              },
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: item.quantity >= 5 ? Colors.grey : null,
                        ),
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  onPressed: () {
                    context.read<CartBloc>().add(
                          RemoveFromCartEvent(item.car.id),
                        );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Удалено из корзины'),
                              duration: Duration(seconds: 2),
                              backgroundColor: Colors.orange,
                            ),
                          );
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
                const SizedBox(height: 8),
                Text(
                  '${item.totalPrice.toStringAsFixed(0)} ₽',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
