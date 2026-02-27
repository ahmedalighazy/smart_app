import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;
import '../../core/constants/colors.dart';
import '../../data/services/notification_history_service.dart';
import '../../logic/cubits/notification_history_cubit.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'all'; // all, meal, tip

  @override
  void initState() {
    super.initState();
    context.read<NotificationHistoryCubit>().loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        elevation: 0,
        backgroundColor: AppColors.primary,
        actions: [
          BlocBuilder<NotificationHistoryCubit, NotificationHistoryState>(
            builder: (context, state) {
              if (state is NotificationHistoryLoaded &&
                  state.notifications.isNotEmpty) {
                return PopupMenuButton(
                  onSelected: (value) {
                    if (value == 'clear') {
                      _showClearDialog(context);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: 'clear',
                      child: Text('حذف الكل'),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationHistoryCubit, NotificationHistoryState>(
        builder: (context, state) {
          if (state is NotificationHistoryInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is NotificationHistoryError) {
            return Center(
              child: Text('خطأ: ${state.message}'),
            );
          }

          if (state is NotificationHistoryLoaded) {
            final notifications = _filterNotifications(state.notifications);

            if (notifications.isEmpty) {
              return _buildEmptyState();
            }

            return Column(
              children: [
                _buildFilterTabs(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(
                        context,
                        notifications[index],
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildFilterButton('الكل', 'all'),
          const SizedBox(width: 8),
          _buildFilterButton('الوجبات', 'meal'),
          const SizedBox(width: 8),
          _buildFilterButton('النصائح', 'tip'),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  List<NotificationHistory> _filterNotifications(
    List<NotificationHistory> notifications,
  ) {
    if (_selectedFilter == 'all') {
      return notifications;
    }
    return notifications.where((n) => n.type == _selectedFilter).toList();
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationHistory notification,
  ) {
    final icon = _getIconForType(notification.type);
    final color = _getColorForType(notification.type);
    final timeAgo = _getTimeAgo(notification.timestamp);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        context
            .read<NotificationHistoryCubit>()
            .deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الإشعار'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              notification.body,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              textDirection: TextDirection.rtl,
            ),
            if (notification.data != null) ...[
              const SizedBox(height: 12),
              _buildNotificationDetails(notification.data!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationDetails(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data['mealName'] != null)
            _buildDetailRow('الوجبة', data['mealName']),
          if (data['calories'] != null)
            _buildDetailRow('السعرات', '${data['calories']} سعرة'),
          if (data['protein'] != null)
            _buildDetailRow('البروتين', '${data['protein']} جرام'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد إشعارات',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ستظهر الإشعارات هنا عند إضافة وجبات',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'meal':
        return Icons.restaurant;
      case 'tip':
        return Icons.lightbulb;
      case 'reminder':
        return Icons.alarm;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'meal':
        return Colors.orange;
      case 'tip':
        return Colors.blue;
      case 'reminder':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'قبل ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'قبل ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'قبل ${difference.inDays} يوم';
    } else {
      return intl.DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف جميع الإشعارات'),
        content: const Text('هل أنت متأكد من حذف جميع الإشعارات؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<NotificationHistoryCubit>().clearAll();
              Navigator.pop(context);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
