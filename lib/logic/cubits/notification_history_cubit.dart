import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/services/notification_history_service.dart';

part 'notification_history_state.dart';

class NotificationHistoryCubit extends Cubit<NotificationHistoryState> {
  NotificationHistoryCubit() : super(const NotificationHistoryInitial());

  void loadNotifications() {
    try {
      final notifications = NotificationHistoryService.getAllNotifications();
      emit(NotificationHistoryLoaded(notifications: notifications));
    } catch (e) {
      emit(NotificationHistoryError(message: e.toString()));
    }
  }

  void loadMealNotifications() {
    try {
      final notifications =
          NotificationHistoryService.getNotificationsByType('meal');
      emit(NotificationHistoryLoaded(notifications: notifications));
    } catch (e) {
      emit(NotificationHistoryError(message: e.toString()));
    }
  }

  void deleteNotification(String id) {
    try {
      NotificationHistoryService.deleteNotification(id);
      loadNotifications();
    } catch (e) {
      emit(NotificationHistoryError(message: e.toString()));
    }
  }

  void clearAll() {
    try {
      NotificationHistoryService.clearAll();
      emit(const NotificationHistoryLoaded(notifications: []));
    } catch (e) {
      emit(NotificationHistoryError(message: e.toString()));
    }
  }

  int getNotificationCount() {
    return NotificationHistoryService.getNotificationCount();
  }
}
