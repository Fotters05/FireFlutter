import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth/auth_bloc.dart';
import 'car_bloc.dart';
import 'car_models.dart';
import 'car_pages.dart';

class CarsPageWithFilter extends StatefulWidget {
  const CarsPageWithFilter({super.key});

  @override
  State<CarsPageWithFilter> createState() => _CarsPageWithFilterState();
}

class _CarsPageWithFilterState extends State<CarsPageWithFilter>
    with SingleTickerProviderStateMixin {
  String _sortBy = 'date';
  String _filterFuelType = 'Все';
  String _filterTransmission = 'Все';
  String _searchQuery = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<CarEntity> _filterAndSortCars(List<CarEntity> cars) {
    var filtered = cars.where((car) {
      final matchesFuel = _filterFuelType == 'Все' ||
          car.fuelType == _filterFuelType;
      final matchesTransmission = _filterTransmission == 'Все' ||
          car.transmission == _filterTransmission;
      final matchesSearch = _searchQuery.isEmpty ||
          car.brand.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          car.model.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFuel && matchesTransmission && matchesSearch;
    }).toList();

    switch (_sortBy) {
      case 'price_asc':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'year':
        filtered.sort((a, b) => b.year.compareTo(a.year));
        break;
      case 'mileage':
        filtered.sort((a, b) => a.mileage.compareTo(b.mileage));
        break;
      case 'date':
      default:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return filtered;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Фильтры'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _filterFuelType,
                  decoration: const InputDecoration(
                    labelText: 'Тип топлива',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Все', 'Бензин', 'Дизель', 'Электро', 'Гибрид', 'Газ']
                      .map((value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _filterFuelType = value!);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _filterTransmission,
                  decoration: const InputDecoration(
                    labelText: 'КПП',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Все', 'Механика', 'Автомат', 'Робот', 'Вариатор']
                      .map((value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _filterTransmission = value!);
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _filterFuelType = 'Все';
                _filterTransmission = 'Все';
              });
              Navigator.pop(dialogContext);
            },
            child: const Text('Сбросить'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('Применить'),
          ),
        ],
      ),
    );
  }

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
            title: Text('Автомобили - ${authState.user.name}'),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterDialog,
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort),
                onSelected: (value) {
                  setState(() => _sortBy = value);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'date',
                    child: Text('По дате добавления'),
                  ),
                  const PopupMenuItem(
                    value: 'price_asc',
                    child: Text('По цене (возрастание)'),
                  ),
                  const PopupMenuItem(
                    value: 'price_desc',
                    child: Text('По цене (убывание)'),
                  ),
                  const PopupMenuItem(
                    value: 'year',
                    child: Text('По году выпуска'),
                  ),
                  const PopupMenuItem(
                    value: 'mileage',
                    child: Text('По пробегу'),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  context.read<AuthBloc>().add(SignOutEvent());
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Поиск по марке или модели',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),
              Expanded(
                child: BlocBuilder<CarBloc, CarState>(
                  builder: (context, state) {
                    if (state is CarInitial) {
                      context.read<CarBloc>().add(
                            LoadCarsEvent(userId: authState.user.uid),
                          );
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is CarLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.black,
                        ),
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
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<CarBloc>().add(
                                      LoadCarsEvent(userId: authState.user.uid),
                                    );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Повторить'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is CarLoaded) {
                      final filteredCars = _filterAndSortCars(state.cars);

                      if (filteredCars.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 16),
                              Text(
                                state.cars.isEmpty
                                    ? 'Нет автомобилей'
                                    : 'Ничего не найдено',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.cars.isEmpty
                                    ? 'Добавьте свой первый автомобиль'
                                    : 'Попробуйте изменить фильтры',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        );
                      }

                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredCars.length,
                          itemBuilder: (context, index) {
                            final car = filteredCars[index];
                            return _CarCard(
                              car: car,
                              userId: authState.user.uid,
                              index: index,
                            );
                          },
                        ),
                      );
                    }

                    return const Center(child: Text('Неизвестное состояние'));
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddCarPage(
                    userId: authState.user.uid,
                  ),
                ),
              );
            },
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

class _CarCard extends StatefulWidget {
  final CarEntity car;
  final String userId;
  final int index;

  const _CarCard({
    required this.car,
    required this.userId,
    required this.index,
  });

  @override
  State<_CarCard> createState() => _CarCardState();
}

class _CarCardState extends State<_CarCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300 + (widget.index * 50)),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.car.brand,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.car.model,
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          title: const Text('Удалить автомобиль?'),
                          content: Text(
                            'Вы уверены, что хотите удалить ${widget.car.brand} ${widget.car.model}?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('Отмена'),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<CarBloc>().add(
                                      DeleteCarEvent(
                                        carId: widget.car.id,
                                        userId: widget.userId,
                                      ),
                                    );
                                Navigator.pop(dialogContext);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Автомобиль удален'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _InfoRow(label: 'Год', value: widget.car.year.toString()),
                  const Divider(),
                  _InfoRow(label: 'Пробег', value: '${widget.car.mileage} км'),
                  const Divider(),
                  _InfoRow(label: 'Цвет', value: widget.car.color),
                  const Divider(),
                  _InfoRow(label: 'Топливо', value: widget.car.fuelType),
                  const Divider(),
                  _InfoRow(label: 'КПП', value: widget.car.transmission),
                  const Divider(),
                  _InfoRow(
                    label: 'Цена',
                    value: '${widget.car.price.toStringAsFixed(0)} ₽',
                    isPrice: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isPrice;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isPrice = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isPrice ? 18 : 14,
              fontWeight: isPrice ? FontWeight.bold : FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
