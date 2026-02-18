import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../auth/auth_bloc.dart';
import '../cart/cart_models.dart';
import '../cart/order_repository.dart';
import '../../injection_container.dart';

class AdminStatisticsPage extends StatelessWidget {
  const AdminStatisticsPage({super.key});

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
            title: const Text('Статистика'),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: FutureBuilder<List<Order>>(
            future: _loadAllOrders(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.black),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Ошибка: ${snapshot.error}'),
                    ],
                  ),
                );
              }

              final orders = snapshot.data ?? [];
              final weekData = _getWeekData(orders);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AnimatedStatCard(
                      title: 'Всего заказов',
                      value: orders.length.toString(),
                      icon: Icons.shopping_bag,
                      color: Colors.blue,
                      delay: 0,
                    ),
                    const SizedBox(height: 16),
                    _AnimatedStatCard(
                      title: 'Продано автомобилей',
                      value: _getTotalCars(orders).toString(),
                      icon: Icons.directions_car,
                      color: Colors.green,
                      delay: 100,
                    ),
                    const SizedBox(height: 16),
                    _AnimatedStatCard(
                      title: 'Общая сумма',
                      value: '${_getTotalAmount(orders).toStringAsFixed(0)} ₽',
                      icon: Icons.attach_money,
                      color: Colors.orange,
                      delay: 200,
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Продажи за неделю',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _AnimatedChartContainer(
                      weekData: weekData,
                      getMaxY: _getMaxY,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<List<Order>> _loadAllOrders() async {
    final repository = sl<OrderRepository>();
    final result = await repository.getAllOrders();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (orders) => orders,
    );
  }

  int _getTotalCars(List<Order> orders) {
    return orders.fold<int>(
      0,
      (sum, order) => sum + order.items.fold<int>(
        0,
        (itemSum, item) => itemSum + item.quantity,
      ),
    );
  }

  double _getTotalAmount(List<Order> orders) {
    return orders.fold<double>(
      0,
      (sum, order) => sum + order.totalAmount,
    );
  }

  Map<int, int> _getWeekData(List<Order> orders) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    // Инициализируем данные для каждого дня недели (0 = понедельник, 6 = воскресенье)
    final Map<int, int> weekData = {
      0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0,
    };

    for (final order in orders) {
      if (order.createdAt.isAfter(weekAgo)) {
        // Получаем день недели (1 = понедельник, 7 = воскресенье)
        int dayOfWeek = order.createdAt.weekday - 1; // Преобразуем в 0-6
        
        // Считаем количество автомобилей в заказе
        final carsCount = order.items.fold<int>(
          0,
          (sum, item) => sum + item.quantity,
        );
        
        weekData[dayOfWeek] = (weekData[dayOfWeek] ?? 0) + carsCount;
      }
    }

    return weekData;
  }

  double _getMaxY(Map<int, int> weekData) {
    final maxValue = weekData.values.reduce((a, b) => a > b ? a : b);
    return (maxValue + 2).toDouble(); // Добавляем немного места сверху
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Анимированная карточка статистики
class _AnimatedStatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final int delay;

  const _AnimatedStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.delay,
  });

  @override
  State<_AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<_AnimatedStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Задержка перед анимацией
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: _StatCard(
          title: widget.title,
          value: widget.value,
          icon: widget.icon,
          color: widget.color,
        ),
      ),
    );
  }
}

// Анимированный контейнер для графика
class _AnimatedChartContainer extends StatefulWidget {
  final Map<int, int> weekData;
  final double Function(Map<int, int>) getMaxY;

  const _AnimatedChartContainer({
    required this.weekData,
    required this.getMaxY,
  });

  @override
  State<_AnimatedChartContainer> createState() =>
      _AnimatedChartContainerState();
}

class _AnimatedChartContainerState extends State<_AnimatedChartContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    // Задержка перед анимацией графика
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: widget.weekData.isEmpty
              ? const Center(
                  child: Text('Нет данных за последнюю неделю'),
                )
              : BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: widget.getMaxY(widget.weekData),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${rod.toY.toInt()} авто',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
                            if (value.toInt() >= 0 &&
                                value.toInt() < days.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  days[value.toInt()],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 12),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 1,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey[300],
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: widget.weekData.entries.map((entry) {
                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.toDouble(),
                            color: Colors.black,
                            width: 20,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 800),
                  swapAnimationCurve: Curves.easeInOutCubic,
                ),
        ),
      ),
    );
  }
}
