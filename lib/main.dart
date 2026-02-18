import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'injection_container.dart' as di;
import 'core/notification_service.dart';
import 'features/auth/auth_bloc.dart';
import 'features/auth/auth_pages.dart';
import 'features/cars/car_bloc.dart';
import 'features/cart/cart_bloc.dart';
import 'features/user/user_home_page.dart';
import 'features/admin/admin_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await di.init();
  await NotificationService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<AuthBloc>()..add(CheckAuthStatusEvent()),
        ),
        BlocProvider(
          create: (_) => di.sl<CarBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<CartBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Автосалон',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            // Очищаем корзину при выходе или смене пользователя
            if (state is AuthUnauthenticated) {
              context.read<CartBloc>().add(ClearCartEvent());
            }
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthLoading || state is AuthInitial) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (state is AuthAuthenticated) {
                // Загружаем автомобили при входе
                context.read<CarBloc>().add(LoadCarsEvent(userId: state.user.uid));
                
                // Проверяем роль пользователя
                if (state.user.role == 'admin') {
                  return const AdminHomePage();
                }
                return const UserHomePage();
              }

              return const SignInPage();
            },
          ),
        ),
      ),
    );
  }
}
