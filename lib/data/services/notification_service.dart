import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_history_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> initialize() async {
    tzdata.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
  }

  Future<void> requestPermissions() async {
    // Request permissions for Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> showMealNotification({
    required String mealName,
    required String calories,
    required String protein,
  }) async {
    // التحقق من حالة كتم الإشعارات
    final prefs = await SharedPreferences.getInstance();
    final isMuted = prefs.getBool('notificationsMuted') ?? false;

    if (isMuted) {
      // حفظ في السجل فقط بدون عرض الإشعار
      await NotificationHistoryService.addNotification(
        title: 'تم إضافة وجبة جديدة',
        body: '$mealName - $calories سعرة حرارية',
        type: 'meal',
        data: {'mealName': mealName, 'calories': calories, 'protein': protein},
      );
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'meal_channel',
          'وجبات',
          channelDescription: 'إشعارات الوجبات المضافة',
          importance: Importance.high,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final notificationId = DateTime.now().millisecond;
    await _notificationsPlugin.show(
      notificationId,
      'تم إضافة وجبة جديدة',
      '$mealName - $calories سعرة حرارية',
      details,
    );

    // حفظ في السجل
    await NotificationHistoryService.addNotification(
      title: 'تم إضافة وجبة جديدة',
      body: '$mealName - $calories سعرة حرارية',
      type: 'meal',
      data: {'mealName': mealName, 'calories': calories, 'protein': protein},
    );
  }

  Future<void> scheduleDailyTip(String tip) async {
    // التحقق من حالة كتم الإشعارات
    final prefs = await SharedPreferences.getInstance();
    final isMuted = prefs.getBool('notificationsMuted') ?? false;

    if (isMuted) {
      // حفظ في السجل فقط بدون عرض الإشعار
      await NotificationHistoryService.addNotification(
        title: 'نصيحة اليوم',
        body: tip,
        type: 'tip',
      );
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'tips_channel',
          'نصائح',
          channelDescription: 'نصائح التغذية والرياضة',
          importance: Importance.high,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // عرض الإشعار فوراً
    final notificationId = DateTime.now().millisecond + 100;
    await _notificationsPlugin.show(
      notificationId,
      'نصيحة اليوم 💡',
      tip,
      details,
    );

    // حفظ في السجل
    await NotificationHistoryService.addNotification(
      title: 'نصيحة اليوم',
      body: tip,
      type: 'tip',
    );
  }
}
