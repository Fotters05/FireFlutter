import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../auth/auth_bloc.dart';
import '../cars/car_bloc.dart';
import '../cars/car_models.dart';
import '../cart/cart_bloc.dart';
import '../cart/cart_models.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  String _sortBy = 'date';
  String _filterFuelType = 'Все';
  String _filterTransmission = 'Все';
  String _searchQuery = '';

  List<CarEntity> _filterAndSortCars(List<CarEntity> cars) {
    var filtered = cars.where((car) {
      final matchesFuel =
          _filterFuelType == 'Все' || car.fuelType == _filterFuelType;
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
            title: const Text('Каталог автомобилей'),
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
                ],
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
                      final filteredCars = _filterAndSortCars(state.cars);

                      if (filteredCars.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 16),
                              Text(
                                state.cars.isEmpty
                                    ? 'Каталог пуст'
                                    : 'Ничего не найдено',
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

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.62,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: filteredCars.length,
                        itemBuilder: (context, index) {
                          final car = filteredCars[index];
                          return _CarCard(car: car);
                        },
                      );
                    }

                    return const Center(child: Text('Неизвестное состояние'));
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CarCard extends StatelessWidget {
  final CarEntity car;

  const _CarCard({required this.car});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          _showCarDetails(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: car.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: car.imageUrl!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 120,
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 120,
                        color: Colors.grey[200],
                        child: const Icon(Icons.directions_car, size: 50),
                      ),
                    )
                  : Container(
                      height: 120,
                      color: Colors.grey[200],
                      child: const Icon(Icons.directions_car, size: 50),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      car.brand,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      car.model,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${car.year} г.',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey[500],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${car.price.toStringAsFixed(0)} ₽',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      height: 30,
                      child: ElevatedButton(
                        onPressed: () {
                          final cartState = context.read<CartBloc>().state;
                          if (cartState is CartLoaded) {
                            final existingItem = cartState.items.firstWhere(
                              (item) => item.car.id == car.id,
                              orElse: () => CartItem(car: car, quantity: 0),
                            );
                            if (existingItem.quantity >= 5) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Максимум 5 штук одного товара'),
                                  duration: Duration(seconds: 2),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }
                          }
                          context.read<CartBloc>().add(AddToCartEvent(car));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${car.brand} ${car.model} добавлен'),
                              duration: const Duration(seconds: 2),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 2),
                        ),
                        child: const Text('В корзину', style: TextStyle(fontSize: 10)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCarDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (car.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: car.imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  '${car.brand} ${car.model}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${car.price.toStringAsFixed(0)} ₽',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 20),
                _DetailRow(label: 'Год выпуска', value: '${car.year}'),
                _DetailRow(label: 'Пробег', value: '${car.mileage} км'),
                _DetailRow(label: 'Цвет', value: car.color),
                _DetailRow(label: 'Топливо', value: car.fuelType),
                _DetailRow(label: 'КПП', value: car.transmission),
                if (car.description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Описание',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    car.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<CartBloc>().add(AddToCartEvent(car));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${car.brand} ${car.model} добавлен в корзину'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Добавить в корзину'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

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
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
