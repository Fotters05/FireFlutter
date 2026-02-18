import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart' hide Order;
import '../../core/failures.dart';
import 'cart_models.dart' as models;

abstract class OrderRepository {
  Future<Either<Failure, String>> createOrder(models.Order order);
  Future<Either<Failure, List<models.Order>>> getUserOrders(String userId);
  Future<Either<Failure, List<models.Order>>> getAllOrders();
  Future<Either<Failure, void>> updateOrderStatus(String orderId, String status);
}

class OrderRepositoryImpl implements OrderRepository {
  final FirebaseFirestore firestore;

  OrderRepositoryImpl({required this.firestore});

  @override
  Future<Either<Failure, String>> createOrder(models.Order order) async {
    try {
      final docRef = await firestore.collection('orders').add(order.toJson());
      return Right(docRef.id);
    } catch (e) {
      return Left(ServerFailure('Ошибка создания заказа: $e'));
    }
  }

  @override
  Future<Either<Failure, List<models.Order>>> getUserOrders(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final orders = querySnapshot.docs
          .map((doc) => models.Order.fromJson(doc.data(), doc.id))
          .toList();

      return Right(orders);
    } catch (e) {
      return Left(ServerFailure('Ошибка загрузки заказов: $e'));
    }
  }

  @override
  Future<Either<Failure, List<models.Order>>> getAllOrders() async {
    try {
      final querySnapshot = await firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();

      final orders = querySnapshot.docs
          .map((doc) => models.Order.fromJson(doc.data(), doc.id))
          .toList();

      return Right(orders);
    } catch (e) {
      return Left(ServerFailure('Ошибка загрузки заказов: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateOrderStatus(String orderId, String status) async {
    try {
      await firestore.collection('orders').doc(orderId).update({
        'status': status,
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Ошибка обновления статуса: $e'));
    }
  }
}
