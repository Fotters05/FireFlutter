import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../core/failures.dart';
import 'car_models.dart';

abstract class CarRepository {
  Future<Either<Failure, void>> addCar({
    required String brand,
    required String model,
    required int year,
    required int mileage,
    required double price,
    required String color,
    required String fuelType,
    required String transmission,
    required String userId,
  });

  Future<Either<Failure, List<CarEntity>>> getCars(String userId);
  Future<Either<Failure, void>> deleteCar(String carId);
}

class CarRepositoryImpl implements CarRepository {
  final FirebaseFirestore firestore;

  CarRepositoryImpl({required this.firestore});

  @override
  Future<Either<Failure, void>> addCar({
    required String brand,
    required String model,
    required int year,
    required int mileage,
    required double price,
    required String color,
    required String fuelType,
    required String transmission,
    required String userId,
  }) async {
    try {
      final car = CarModel(
        id: '',
        brand: brand,
        model: model,
        year: year,
        mileage: mileage,
        price: price,
        color: color,
        fuelType: fuelType,
        transmission: transmission,
        userId: userId,
        createdAt: DateTime.now(),
      );

      await firestore.collection('cars').add(car.toJson());
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Ошибка добавления автомобиля: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CarEntity>>> getCars(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('cars')
          .orderBy('createdAt', descending: true)
          .get();

      final cars = querySnapshot.docs
          .map((doc) => CarModel.fromJson(doc.data(), doc.id))
          .toList();

      return Right(cars);
    } catch (e) {
      return Left(ServerFailure('Ошибка загрузки автомобилей: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCar(String carId) async {
    try {
      await firestore.collection('cars').doc(carId).delete();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Ошибка удаления автомобиля: $e'));
    }
  }
}
