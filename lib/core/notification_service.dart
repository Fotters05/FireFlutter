import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Запрос разрешений
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Настройка локальных уведомлений
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(initSettings);

    // Обработка уведомлений когда приложение открыто
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Обработка уведомлений когда приложение в фоне
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Получение токена
    final token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Получено уведомление: ${message.notification?.title}');
    
    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Уведомление',
      message.notification?.body ?? '',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel',
          'Основной канал',
          channelDescription: 'Канал для основных уведомлений',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    print('Уведомление открыто: ${message.notification?.title}');
  }

  // Локальное уведомление при добавлении автомобиля
  Future<void> showCarAddedNotification(String brand, String model) async {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Автомобиль добавлен',
      '$brand $model успешно добавлен в каталог',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'car_actions',
          'Действия с автомобилями',
          channelDescription: 'Уведомления о действиях с автомобилями',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // Локальное уведомление при удалении автомобиля
  Future<void> showCarDeletedNotification(String brand, String model) async {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Автомобиль удален',
      '$brand $model удален из каталога',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'car_actions',
          'Действия с автомобилями',
          channelDescription: 'Уведомления о действиях с автомобилями',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
