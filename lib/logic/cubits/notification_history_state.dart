part of 'notification_history_cubit.dart';

abstract class NotificationHistoryState extends Equatable {
  const NotificationHistoryState();

  @override
  List<Object?> get props => [];
}

class NotificationHistoryInitial extends NotificationHistoryState {
  const NotificationHistoryInitial();
}

class NotificationHistoryLoaded extends NotificationHistoryState {
  final List<NotificationHistory> notifications;

  const NotificationHistoryLoaded({required this.notifications});

  @override
  List<Object?> get props => [notifications];
}

class NotificationHistoryError extends NotificationHistoryState {
  final String message;

  const NotificationHistoryError({required this.message});

  @override
  List<Object?> get props => [message];
}
