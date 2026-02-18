import 'package:equatable/equatable.dart';
import '../cars/car_models.dart';

class CartItem extends Equatable {
  final CarEntity car;
  final int quantity;

  const CartItem({
    required this.car,
    this.quantity = 1,
  });

  double get totalPrice => car.price * quantity;

  CartItem copyWith({
    CarEntity? car,
    int? quantity,
  }) {
    return CartItem(
      car: car ?? this.car,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object> get props => [car, quantity];
}

class Order extends Equatable {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final String userEmail;
  final String userName;
  final String? userPhone;
  final String? userAddress;

  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.userEmail,
    required this.userName,
    this.userPhone,
    this.userAddress,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        items,
        totalAmount,
        status,
        createdAt,
        userEmail,
        userName,
        userPhone,
        userAddress,
      ];

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'userEmail': userEmail,
      'userName': userName,
      'userPhone': userPhone,
      'userAddress': userAddress,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json, String id) {
    return Order(
      id: id,
      userId: json['userId'],
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      userEmail: json['userEmail'],
      userName: json['userName'],
      userPhone: json['userPhone'],
      userAddress: json['userAddress'],
    );
  }
}

class OrderItem extends Equatable {
  final String carId;
  final String brand;
  final String model;
  final double price;
  final int quantity;
  final String? imageUrl;

  const OrderItem({
    required this.carId,
    required this.brand,
    required this.model,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });

  double get totalPrice => price * quantity;

  @override
  List<Object?> get props => [carId, brand, model, price, quantity, imageUrl];

  Map<String, dynamic> toJson() {
    return {
      'carId': carId,
      'brand': brand,
      'model': model,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      carId: json['carId'],
      brand: json['brand'],
      model: json['model'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'],
      imageUrl: json['imageUrl'],
    );
  }
}
