import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import 'features/auth/auth_bloc.dart';
import 'features/auth/auth_repository.dart';
import 'features/cars/car_bloc.dart';
import 'features/cars/car_repository.dart';
import 'features/cart/cart_bloc.dart';
import 'features/cart/order_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Bloc
  sl.registerFactory(() => AuthBloc(repository: sl()));
  sl.registerFactory(() => CarBloc(repository: sl()));
  sl.registerFactory(() => CartBloc());

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      firebaseAuth: sl(),
      firestore: sl(),
    ),
  );

  sl.registerLazySingleton<CarRepository>(
    () => CarRepositoryImpl(firestore: sl()),
  );

  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(firestore: sl()),
  );

  // External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
}
