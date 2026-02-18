import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/failures.dart';
import 'auth_models.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String name,
  });

  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Future<Either<Failure, void>> resetPassword({required String email});
}

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRepositoryImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      return Right(UserModel.fromJson(userDoc.data()!));
    } catch (e) {
      return Left(AuthFailure('Ошибка входа: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userModel = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
      );

      await firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userModel.toJson());

      return Right(userModel);
    } catch (e) {
      return Left(AuthFailure('Ошибка регистрации: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await firebaseAuth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('Ошибка выхода: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) return const Right(null);

      final userDoc = await firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) return const Right(null);

      return Right(UserModel.fromJson(userDoc.data()!));
    } catch (e) {
      return Left(AuthFailure('Ошибка получения пользователя: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('Ошибка сброса пароля: $e'));
    }
  }
}
