import 'dart:async';
import 'notification_service.dart';
import 'tips_service.dart';

class BackgroundTipsService {
  static Timer? _timer;
  static bool _isRunning = false;

  static void start() {
    if (_isRunning) return;
    
    _isRunning = true;
    
    // إرسال نصيحة فوراً عند البدء
    _sendTip();
    
    // إرسال نصيحة كل دقيقة
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _sendTip();
    });
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  static void _sendTip() {
    final tip = TipsService.getRandomTip();
    NotificationService().scheduleDailyTip(tip);
  }

  static bool get isRunning => _isRunning;
}
