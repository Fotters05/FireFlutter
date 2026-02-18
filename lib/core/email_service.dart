import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/cart/cart_models.dart' as cart;

class EmailService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Отправка email через Firestore (будет обработано Cloud Function)
  Future<void> sendOrderConfirmation(cart.Order order) async {
    try {
      await _firestore.collection('mail').add({
        'to': [order.userEmail],
        'template': {
          'name': 'orderConfirmation',
          'data': {
            'userName': order.userName,
            'orderId': order.id,
            'items': order.items.map((item) => {
              'brand': item.brand,
              'model': item.model,
              'quantity': item.quantity,
              'price': item.price,
              'total': item.totalPrice,
            }).toList(),
            'totalAmount': order.totalAmount,
            'orderDate': order.createdAt.toIso8601String(),
            'phone': order.userPhone ?? 'Не указан',
            'address': order.userAddress ?? 'Не указан',
          },
        },
      });
      print('Email отправлен на ${order.userEmail}');
    } catch (e) {
      print('Ошибка отправки email: $e');
    }
  }

  // Простая версия без Cloud Functions - просто логируем
  Future<void> logOrderEmail(cart.Order order) async {
    final emailContent = '''
<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: #000; color: #fff; padding: 20px; text-align: center; }
        .order-info { background: #f5f5f5; padding: 15px; margin: 20px 0; border-radius: 5px; }
        .item { border-bottom: 1px solid #ddd; padding: 10px 0; }
        .item:last-child { border-bottom: none; }
        .total { background: #000; color: #fff; padding: 15px; text-align: center; font-size: 20px; font-weight: bold; margin-top: 20px; }
        .footer { text-align: center; color: #666; margin-top: 30px; font-size: 12px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚗 АВТОСАЛОН</h1>
            <p>Подтверждение заказа</p>
        </div>
        
        <div class="order-info">
            <h2>Заказ #${order.id.substring(0, 8).toUpperCase()}</h2>
            <p><strong>Дата:</strong> ${_formatDate(order.createdAt)}</p>
            <p><strong>Клиент:</strong> ${order.userName}</p>
            <p><strong>Email:</strong> ${order.userEmail}</p>
            <p><strong>Телефон:</strong> ${order.userPhone ?? 'Не указан'}</p>
            <p><strong>Адрес:</strong> ${order.userAddress ?? 'Не указан'}</p>
        </div>
        
        <h3>Ваш заказ:</h3>
        ${order.items.map((item) => '''
        <div class="item">
            <strong>${item.brand} ${item.model}</strong><br>
            Количество: ${item.quantity} шт. × ${item.price.toStringAsFixed(0)} ₽<br>
            <strong>Итого: ${item.totalPrice.toStringAsFixed(0)} ₽</strong>
        </div>
        ''').join('')}
        
        <div class="total">
            ОБЩАЯ СУММА: ${order.totalAmount.toStringAsFixed(0)} ₽
        </div>
        
        <div class="footer">
            <p>Спасибо за ваш заказ!</p>
            <p>Мы свяжемся с вами в ближайшее время для подтверждения.</p>
            <p>© 2026 Автосалон. Все права защищены.</p>
        </div>
    </div>
</body>
</html>
    ''';
    
    print('═══════════════════════════════════════');
    print('EMAIL ОТПРАВЛЕН НА: ${order.userEmail}');
    print('ЗАКАЗ: #${order.id.substring(0, 8).toUpperCase()}');
    print('СУММА: ${order.totalAmount.toStringAsFixed(0)} ₽');
    print('═══════════════════════════════════════');
    
    // Сохраняем в Firestore для истории
    await _firestore.collection('email_logs').add({
      'to': order.userEmail,
      'subject': 'Подтверждение заказа #${order.id.substring(0, 8).toUpperCase()}',
      'html': emailContent,
      'orderId': order.id,
      'sentAt': FieldValue.serverTimestamp(),
    });
  }

  String _formatDate(DateTime date) {
    final months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year} г., ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
