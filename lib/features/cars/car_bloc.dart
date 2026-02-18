import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'car_models.dart';
import 'car_repository.dart';

abstract class CarEvent extends Equatable {
  const CarEvent();
  @override
  List<Object?> get props => [];
}

class LoadCarsEvent extends CarEvent {
  final String userId;
  const LoadCarsEvent({required this.userId});
  @override
  List<Object> get props => [userId];
}

class AddCarEvent extends CarEvent {
  final String brand;
  final String model;
  final int year;
  final int mileage;
  final double price;
  final String color;
  final String fuelType;
  final String transmission;
  final String userId;
  final String? imageUrl;
  final String? description;

  const AddCarEvent({
    required this.brand,
    required this.model,
    required this.year,
    required this.mileage,
    required this.price,
    required this.color,
    required this.fuelType,
    required this.transmission,
    required this.userId,
    this.imageUrl,
    this.description,
  });

  @override
  List<Object?> get props => [
        brand,
        model,
        year,
        mileage,
        price,
        color,
        fuelType,
        transmission,
        userId,
        imageUrl,
        description,
      ];
}

class DeleteCarEvent extends CarEvent {
  final String carId;
  final String userId;

  const DeleteCarEvent({
    required this.carId,
    required this.userId,
  });

  @override
  List<Object> get props => [carId, userId];
}

abstract class CarState extends Equatable {
  const CarState();
  @override
  List<Object> get props => [];
}

class CarInitial extends CarState {}
class CarLoading extends CarState {}

class CarLoaded extends CarState {
  final List<CarEntity> cars;
  const CarLoaded({required this.cars});
  @override
  List<Object> get props => [cars];
}

class CarError extends CarState {
  final String message;
  const CarError({required this.message});
  @override
  List<Object> get props => [message];
}

class CarBloc extends Bloc<CarEvent, CarState> {
  final CarRepository repository;

  CarBloc({required this.repository}) : super(CarInitial()) {
    on<LoadCarsEvent>(_onLoadCars);
    on<AddCarEvent>(_onAddCar);
    on<DeleteCarEvent>(_onDeleteCar);
  }

  Future<void> _onLoadCars(
    LoadCarsEvent event,
    Emitter<CarState> emit,
  ) async {
    emit(CarLoading());
    final result = await repository.getCars(event.userId);
    result.fold(
      (failure) => emit(CarError(message: failure.message)),
      (cars) => emit(CarLoaded(cars: cars)),
    );
  }

  Future<void> _onAddCar(
    AddCarEvent event,
    Emitter<CarState> emit,
  ) async {
    emit(CarLoading());
    final result = await repository.addCar(
      brand: event.brand,
      model: event.model,
      year: event.year,
      mileage: event.mileage,
      price: event.price,
      color: event.color,
      fuelType: event.fuelType,
      transmission: event.transmission,
      userId: event.userId,
      imageUrl: event.imageUrl,
      description: event.description,
    );
    await result.fold(
      (failure) async => emit(CarError(message: failure.message)),
      (_) async {
        final carsResult = await repository.getCars(event.userId);
        carsResult.fold(
          (failure) => emit(CarError(message: failure.message)),
          (cars) => emit(CarLoaded(cars: cars)),
        );
      },
    );
  }

  Future<void> _onDeleteCar(
    DeleteCarEvent event,
    Emitter<CarState> emit,
  ) async {
    emit(CarLoading());
    final result = await repository.deleteCar(event.carId);
    await result.fold(
      (failure) async => emit(CarError(message: failure.message)),
      (_) async {
        final carsResult = await repository.getCars(event.userId);
        carsResult.fold(
          (failure) => emit(CarError(message: failure.message)),
          (cars) => emit(CarLoaded(cars: cars)),
        );
      },
    );
  }
}
