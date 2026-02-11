import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class CarEntity extends Equatable {
  final String id;
  final String brand;
  final String model;
  final int year;
  final int mileage;
  final double price;
  final String color;
  final String fuelType;
  final String transmission;
  final String userId;
  final DateTime createdAt;

  const CarEntity({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.mileage,
    required this.price,
    required this.color,
    required this.fuelType,
    required this.transmission,
    required this.userId,
    required this.createdAt,
  });

  @override
  List<Object> get props => [
        id,
        brand,
        model,
        year,
        mileage,
        price,
        color,
        fuelType,
        transmission,
        userId,
        createdAt
      ];
}

class CarModel extends CarEntity {
  const CarModel({
    required super.id,
    required super.brand,
    required super.model,
    required super.year,
    required super.mileage,
    required super.price,
    required super.color,
    required super.fuelType,
    required super.transmission,
    required super.userId,
    required super.createdAt,
  });

  factory CarModel.fromJson(Map<String, dynamic> json, String id) {
    return CarModel(
      id: id,
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
      mileage: json['mileage'],
      price: (json['price'] as num).toDouble(),
      color: json['color'],
      fuelType: json['fuelType'],
      transmission: json['transmission'],
      userId: json['userId'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'model': model,
      'year': year,
      'mileage': mileage,
      'price': price,
      'color': color,
      'fuelType': fuelType,
      'transmission': transmission,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
