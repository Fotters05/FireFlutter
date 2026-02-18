import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cars/car_bloc.dart';
import '../../core/notification_service.dart';

class AddCarPageAdmin extends StatefulWidget {
  final String userId;

  const AddCarPageAdmin({super.key, required this.userId});

  @override
  State<AddCarPageAdmin> createState() => _AddCarPageAdminState();
}

class _AddCarPageAdminState extends State<AddCarPageAdmin> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _mileageController = TextEditingController();
  final _priceController = TextEditingController();
  final _colorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String _selectedFuelType = 'Бензин';
  String _selectedTransmission = 'Механика';

  final List<String> _fuelTypes = [
    'Бензин',
    'Дизель',
    'Электро',
    'Гибрид',
    'Газ'
  ];
  final List<String> _transmissions = [
    'Механика',
    'Автомат',
    'Робот',
    'Вариатор'
  ];

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    _priceController.dispose();
    _colorController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _addCar() {
    if (_formKey.currentState!.validate()) {
      final brand = _brandController.text.trim();
      final model = _modelController.text.trim();

      context.read<CarBloc>().add(
            AddCarEvent(
              brand: brand,
              model: model,
              year: int.parse(_yearController.text),
              mileage: int.parse(_mileageController.text),
              price: double.parse(_priceController.text),
              color: _colorController.text.trim(),
              fuelType: _selectedFuelType,
              transmission: _selectedTransmission,
              userId: widget.userId,
              imageUrl: _imageUrlController.text.trim().isEmpty
                  ? null
                  : _imageUrlController.text.trim(),
              description: _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
            ),
          );

      NotificationService().showCarAddedNotification(brand, model);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$brand $model добавлен'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Добавить автомобиль'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Основная информация',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Марка',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите марку';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Модель',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите модель';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _yearController,
                      decoration: const InputDecoration(
                        labelText: 'Год',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите год';
                        }
                        final year = int.tryParse(value);
                        if (year == null) {
                          return 'Введите число';
                        }
                        if (year < 1980) {
                          return 'Не ниже 1980';
                        }
                        if (year > 2026) {
                          return 'Не выше 2026';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _mileageController,
                      decoration: const InputDecoration(
                        labelText: 'Пробег (км)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите пробег';
                        }
                        final mileage = int.tryParse(value);
                        if (mileage == null) {
                          return 'Введите число';
                        }
                        if (mileage < 0) {
                          return 'Пробег не может быть отрицательным';
                        }
                        if (mileage > 1000000) {
                          return 'Пробег не может быть больше 1.000.000 км';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: 'Цвет',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите цвет';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Технические характеристики',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedFuelType,
                decoration: const InputDecoration(
                  labelText: 'Тип топлива',
                  border: OutlineInputBorder(),
                ),
                items: _fuelTypes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedFuelType = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedTransmission,
                decoration: const InputDecoration(
                  labelText: 'Коробка передач',
                  border: OutlineInputBorder(),
                ),
                items: _transmissions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTransmission = newValue!;
                  });
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Цена и описание',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Цена (₽)',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите цену';
                  }
                  final price = double.tryParse(value);
                  if (price == null) {
                    return 'Введите корректную цену';
                  }
                  if (price <= 0) {
                    return 'Цена должна быть больше 0';
                  }
                  if (price > 1000000000) {
                    return 'Цена не может быть больше 1.000.000.000 ₽';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Описание',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL изображения',
                  border: OutlineInputBorder(),
                  hintText: 'https://example.com/car.jpg',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addCar,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Добавить автомобиль',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
