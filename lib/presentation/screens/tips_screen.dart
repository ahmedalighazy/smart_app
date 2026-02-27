import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../logic/cubits/tips_cubit.dart';
import '../../core/constants/colors.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/tips_service.dart';

class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  late Timer _tipsTimer;

  @override
  void initState() {
    super.initState();
    context.read<TipsCubit>().getRandomTip();
    _startAutoTips();
  }

  void _startAutoTips() {
    _tipsTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _showRandomTip();
    });
  }

  void _showRandomTip() {
    final tip = TipsService.getRandomTip();

    // إرسال إشعار نصيحة
    NotificationService().scheduleDailyTip(tip);

    // تحديث الـ UI
    context.read<TipsCubit>().getRandomTip();
  }

  @override
  void dispose() {
    _tipsTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نصائح يومية',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'نصيحة جديدة كل دقيقة',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ],
                ),
              ),

              // Main Tip Card
              Expanded(
                child: BlocBuilder<TipsCubit, TipsState>(
                  builder: (context, state) {
                    String tip = 'اضغط على "نصيحة جديدة" للحصول على نصيحة';
                    String type = 'random';
                    
                    if (state is TipsLoaded) {
                      tip = state.tip;
                      type = state.type;
                    }
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            // Large Tip Card
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Icon
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: _getColorForType(type)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      _getIconForType(type),
                                      size: 48,
                                      color: _getColorForType(type),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Title
                                  Text(
                                    _getTitleForType(type),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: _getColorForType(type),
                                        ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Tip Text
                                  Text(
                                    tip,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          height: 1.6,
                                          color: Colors.grey[800],
                                        ),
                                    textDirection: TextDirection.rtl,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Action Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildActionButton(
                                  icon: Icons.refresh,
                                  label: 'نصيحة جديدة',
                                  onTap: () =>
                                      context.read<TipsCubit>().getRandomTip(),
                                ),
                                _buildActionButton(
                                  icon: Icons.restaurant,
                                  label: 'تغذية',
                                  onTap: () => context
                                      .read<TipsCubit>()
                                      .getNutritionTip(),
                                ),
                                _buildActionButton(
                                  icon: Icons.fitness_center,
                                  label: 'رياضة',
                                  onTap: () =>
                                      context.read<TipsCubit>().getFitnessTip(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                  },
                ),
              ),

              // Bottom Info
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'ستتلقى إشعارات بنصائح جديدة تلقائياً',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'nutrition':
        return Icons.restaurant;
      case 'fitness':
        return Icons.fitness_center;
      case 'meal':
        return Icons.lunch_dining;
      default:
        return Icons.lightbulb;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'nutrition':
        return Colors.orange;
      case 'fitness':
        return Colors.purple;
      case 'meal':
        return Colors.blue;
      default:
        return AppColors.primary;
    }
  }

  String _getTitleForType(String type) {
    switch (type) {
      case 'nutrition':
        return 'نصيحة تغذية';
      case 'fitness':
        return 'نصيحة رياضية';
      case 'meal':
        return 'نصيحة الوجبة';
      default:
        return 'نصيحة اليوم';
    }
  }
}
