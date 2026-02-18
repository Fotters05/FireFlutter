import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cars/car_bloc.dart';
import '../cars/car_models.dart';
import '../../core/notification_service.dart';

class EditCarPageAdmin extends StatefulWidget {
  final String userId;
  final CarEntity car;

  const EditCarPageAdmin({
    super.key,
    required this.userId,
    required this.car,
  });

  @override
  State<EditCarPageAdmin> createState() => _EditCarPageAdminState();
}

class _EditCarPageAdminState extends State<EditCarPageAdmin> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _mileageController;
  late TextEditingController _priceController;
  late TextEditingController _colorController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;

  late String _selectedFuelType;
  late String _selectedTransmission;

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
  void initState() {
    super.initState();
    _brandController = TextEditingController(text: widget.car.brand);
    _modelController = TextEditingController(text: widget.car.model);
    _yearController = TextEditingController(text: widget.car.year.toString());
    _mileageController = TextEditingController(text: widget.car.mileage.toString());
    _priceController = TextEditingController(text: widget.car.price.toString());
    _colorController = TextEditingController(text: widget.car.color);
    _descriptionController = TextEditingController(text: widget.car.description);
    _imageUrlController = TextEditingController(text: widget.car.imageUrl ?? '');
    _selectedFuelType = widget.car.fuelType;
    _selectedTransmission = widget.car.transmission;
  }

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

  void _updateCar() {
    if (_formKey.currentState!.validate()) {
      // Сначала удаляем старый
      context.read<CarBloc>().add(
            DeleteCarEvent(
              carId: widget.car.id,
              userId: widget.userId,
            ),
          );

      // Затем добавляем обновленный
      Future.delayed(const Duration(milliseconds: 500), () {
        context.read<CarBloc>().add(
              AddCarEvent(
                brand: _brandController.text.trim(),
                model: _modelController.text.trim(),
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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_brandController.text} ${_modelController.text} обновлен'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Редактировать автомобиль'),
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
                          return 'Год не может быть ниже 1980';
                        }
                        if (year > 2026) {
                          return 'Год не может быть выше 2026';
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
                  onPressed: _updateCar,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Сохранить изменения',
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
