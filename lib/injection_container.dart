import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import 'features/auth/auth_bloc.dart';
import 'features/auth/auth_repository.dart';
import 'features/cars/car_bloc.dart';
import 'features/cars/car_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerFactory(() => AuthBloc(repository: sl()));
  sl.registerFactory(() => CarBloc(repository: sl()));

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      firebaseAuth: sl(),
      firestore: sl(),
    ),
  );
  
  sl.registerLazySingleton<CarRepository>(
    () => CarRepositoryImpl(firestore: sl()),
  );

  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
}
