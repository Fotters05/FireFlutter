import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'cart_models.dart';
import '../cars/car_models.dart';

// Events
abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object> get props => [];
}

class AddToCartEvent extends CartEvent {
  final CarEntity car;
  const AddToCartEvent(this.car);
  @override
  List<Object> get props => [car];
}

class RemoveFromCartEvent extends CartEvent {
  final String carId;
  const RemoveFromCartEvent(this.carId);
  @override
  List<Object> get props => [carId];
}

class UpdateQuantityEvent extends CartEvent {
  final String carId;
  final int quantity;
  const UpdateQuantityEvent(this.carId, this.quantity);
  @override
  List<Object> get props => [carId, quantity];
}

class ClearCartEvent extends CartEvent {}

// States
abstract class CartState extends Equatable {
  const CartState();
  @override
  List<Object> get props => [];
}

class CartInitial extends CartState {}

class CartLoaded extends CartState {
  final List<CartItem> items;
  final double totalAmount;

  const CartLoaded({
    required this.items,
    required this.totalAmount,
  });

  @override
  List<Object> get props => [items, totalAmount];
}

// BLoC
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartInitial()) {
    on<AddToCartEvent>(_onAddToCart);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<UpdateQuantityEvent>(_onUpdateQuantity);
    on<ClearCartEvent>(_onClearCart);
  }

  List<CartItem> _items = [];

  void _onAddToCart(AddToCartEvent event, Emitter<CartState> emit) {
    final existingIndex = _items.indexWhere((item) => item.car.id == event.car.id);
    
    if (existingIndex >= 0) {
      // Проверяем лимит 5 штук на один товар
      if (_items[existingIndex].quantity >= 5) {
        // Не добавляем, достигнут лимит
        return;
      }
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + 1,
      );
    } else {
      _items.add(CartItem(car: event.car));
    }

    final total = _items.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );

    emit(CartLoaded(items: List.from(_items), totalAmount: total));
  }

  void _onRemoveFromCart(RemoveFromCartEvent event, Emitter<CartState> emit) {
    _items.removeWhere((item) => item.car.id == event.carId);

    final total = _items.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );

    emit(CartLoaded(items: List.from(_items), totalAmount: total));
  }

  void _onUpdateQuantity(UpdateQuantityEvent event, Emitter<CartState> emit) {
    final index = _items.indexWhere((item) => item.car.id == event.carId);
    
    if (index >= 0) {
      if (event.quantity <= 0) {
        _items.removeAt(index);
      } else if (event.quantity > 5) {
        // Ограничение 5 штук
        _items[index] = _items[index].copyWith(quantity: 5);
      } else {
        _items[index] = _items[index].copyWith(quantity: event.quantity);
      }
    }

    final total = _items.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );

    emit(CartLoaded(items: List.from(_items), totalAmount: total));
  }

  void _onClearCart(ClearCartEvent event, Emitter<CartState> emit) {
    _items.clear();
    emit(const CartLoaded(items: [], totalAmount: 0));
  }
}
