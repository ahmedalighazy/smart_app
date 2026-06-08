import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/colors.dart';
import 'core/constants/dio/dio_helper.dart';
import 'core/localization/app_localizations.dart';
import 'logic/cubits/user_cubit.dart';
import 'logic/cubits/food_scanner_cubit.dart';
import 'logic/cubits/settings_cubit.dart';
import 'logic/cubits/social_media_cubit.dart';
import 'logic/cubits/tips_cubit.dart';
import 'logic/cubits/notification_history_cubit.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/main_navigation_screen.dart';
import 'presentation/screens/input_screen.dart';
import 'presentation/screens/results_screen.dart';
import 'presentation/screens/food_scanner_screen.dart';
import 'presentation/screens/ai_recommendations_screen.dart';
import 'presentation/screens/tips_screen.dart';
import 'presentation/screens/notifications_screen.dart';
import 'data/services/hive_service.dart';
import 'data/services/auth_service.dart';
import 'data/services/notification_service.dart';
import 'data/services/notification_history_service.dart';
import 'data/services/background_tips_service.dart';
import 'data/services/composite_meal_service.dart';
import 'data/models/composite_meal_model.dart';
import 'presentation/screens/composite_meals_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    DioHelper.init();
    await HiveService.init();

    // تسجيل Hive Adapters للوجبات المركبة
    Hive.registerAdapter(CompositeMealModelAdapter());
    Hive.registerAdapter(CompositeMealItemAdapter());
    await CompositeMealService.init();

    await NotificationHistoryService.init();

    try {
      await NotificationService().initialize();
      await NotificationService().requestPermissions();

      // استعادة الإشعارات الدورية إذا كانت مفعلة
      await NotificationService().restorePeriodicNotifications();
    } catch (e) {
      debugPrint('Notification service error: $e');
      // نستمر حتى لو فشلت الإشعارات
    }

    // بدء خدمة النصائح التلقائية
    try {
      BackgroundTipsService.start();
    } catch (e) {
      debugPrint('Background tips service error: $e');
      // نستمر حتى لو فشلت الخدمة
    }

    // استعادة التوكين المحفوظ عند بدء التطبيق
    try {
      final token = await AuthService.getToken();
      if (token != null && token.isNotEmpty) {
        DioHelper.setToken(token);
      }
    } catch (e) {
      debugPrint('Token restoration error: $e');
      // نستمر حتى لو فشلت استعادة التوكين
    }
  } catch (e) {
    debugPrint('Initialization error: $e');
    // نستمر حتى لو حدث خطأ في التهيئة
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => UserCubit()),
        BlocProvider(create: (context) => FoodScannerCubit()),
        BlocProvider(create: (context) => SettingsCubit()),
        BlocProvider(create: (context) => SocialMediaCubit()),
        BlocProvider(create: (context) => TipsCubit()),
        BlocProvider(create: (context) => NotificationHistoryCubit()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          // إضافة key لإجبار إعادة البناء عند تغيير اللغة
          final appKey = ValueKey('app_${state.locale.languageCode}');

          return MaterialApp(
            key: appKey,
            title: 'Smart Nutrition',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                brightness: Brightness.light,
              ),
              textTheme: GoogleFonts.cairoTextTheme(),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                brightness: Brightness.dark,
              ),
              textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
            ),
            themeMode: state.themeMode,
            locale: state.locale,
            // إضافة textDirection بناءً على اللغة مع إعادة البناء
            builder: (context, child) {
              // التأكد من إعادة البناء عند تغيير اللغة
              final isArabic = state.locale.languageCode == 'ar';
              debugPrint(
                '🌐 Language changed to: ${state.locale.languageCode}',
              );
              debugPrint('📱 Text direction: ${isArabic ? 'RTL' : 'LTR'}');

              return Directionality(
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                child: child!,
              );
            },
            supportedLocales: const [Locale('ar'), Locale('en')],
            localeResolutionCallback: (locale, supportedLocales) {
              // إذا كانت اللغة المحفوظة عربي، استخدمها
              if (state.locale.languageCode == 'ar') {
                return const Locale('ar');
              }
              // وإلا استخدم الإنجليزية
              return const Locale('en');
            },
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const AuthCheckScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/splash': (context) => const SplashScreen(),
              '/home': (context) => const MainNavigationScreen(),
              '/input': (context) => const InputScreen(),
              '/results': (context) => const ResultsScreen(),
              '/food_scanner': (context) => const FoodScannerScreen(),
              '/ai_recommendations': (context) =>
                  const AIRecommendationsScreen(),
              '/tips': (context) => const TipsScreen(),
              '/notifications': (context) => const NotificationsScreen(),
              '/composite_meals': (context) => const CompositeMealsScreen(),
            },
          );
        },
      ),
    );
  }
}

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      // محاولة استعادة الجلسة من التوكين المحفوظ
      final isLoggedIn = await AuthService.isLoggedIn();

      if (mounted) {
        if (isLoggedIn) {
          // استعادة الـ token والانتقال للصفحة الرئيسية
          try {
            await context.read<UserCubit>().checkAuth();
          } catch (e) {
            // في حالة فشل checkAuth، نستمر للصفحة الرئيسية
            debugPrint('Error in checkAuth: $e');
          }
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else {
          // لا يوجد توكين، الانتقال لصفحة تسجيل الدخول
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        }
      }
    } catch (e) {
      // في حالة حدوث أي خطأ، نذهب لصفحة تسجيل الدخول
      debugPrint('Error in _checkAuth: $e');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.restaurant_menu,
                size: 50,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Smart Nutrition',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
