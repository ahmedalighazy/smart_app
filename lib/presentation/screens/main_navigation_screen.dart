import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import '../../core/constants/colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../logic/cubits/settings_cubit.dart';
import '../../logic/cubits/notification_history_cubit.dart';
import 'home_screen/home_content_screen.dart';
import 'food_scanner_screen.dart';
import 'home_screen/widgets/my_meals_screen.dart';
import 'settings_screen.dart';
import 'tips_screen.dart';
import 'notifications_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late PageController _pageController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _navigateToTab(int index) {
    _onItemTapped(index);
  }

  List<Widget> get _screens => [
    HomeContentScreen(onNavigateToTab: _navigateToTab),
    const FoodScannerScreen(),
    const MyMealsScreen(),
    const TipsScreen(),
    const NotificationsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final isDark = state.isDarkMode;

        return Scaffold(
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: _screens,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SnakeNavigationBar.color(
              behaviour: SnakeBarBehaviour.floating,
              snakeShape: SnakeShape.circle,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              height: 70,
              backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
              snakeViewColor: AppColors.primary,
              selectedItemColor: Colors.white,
              unselectedItemColor: isDark ? Colors.grey[500] : Colors.grey[600],
              showUnselectedLabels: true,
              showSelectedLabels: true,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_rounded, size: 26),
                  label: context.tr('home'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.camera_alt_rounded, size: 26),
                  label: context.tr('scanner'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.restaurant_menu_rounded, size: 26),
                  label: context.tr('meals'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.lightbulb_rounded, size: 26),
                  label: 'نصائح',
                ),
                BottomNavigationBarItem(
                  icon: BlocBuilder<NotificationHistoryCubit,
                      NotificationHistoryState>(
                    builder: (context, notificationState) {
                      final count = context
                          .read<NotificationHistoryCubit>()
                          .getNotificationCount();
                      return Stack(
                        children: [
                          const Icon(Icons.notifications_rounded, size: 26),
                          if (count > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  count.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  label: 'إشعارات',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.settings_rounded, size: 26),
                  label: context.tr('settings'),
                ),
              ],
              selectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 11,
              ),
            ),
          ),
        );
      },
    );
  }
}
