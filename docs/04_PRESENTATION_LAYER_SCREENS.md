# 🎨 Presentation Layer - Screens (الشاشات)

## نظرة عامة
طبقة العرض تحتوي على جميع شاشات التطبيق والـ UI Components.

---

## 1. Main Entry Point - `lib/main.dart`

### الوصف
نقطة البداية للتطبيق مع إعداد BLoC والثيمات والتوجيه.

### الكود الرئيسي

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة الخدمات
  DioHelper.init();
  await HiveService.init();
  await NotificationHistoryService.init();
  await NotificationService().initialize();
  await NotificationService().requestPermissions();
  
  // بدء خدمة النصائح التلقائية
  BackgroundTipsService.start();
  
  // استعادة التوكين
  final token = await AuthService.getToken();
  if (token != null && token.isNotEmpty) {
    DioHelper.setToken(token);
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
          return MaterialApp(
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
              textTheme: GoogleFonts.cairoTextTheme(
                ThemeData.dark().textTheme,
              ),
            ),
            themeMode: state.themeMode,
            locale: state.locale,
            supportedLocales: const [Locale('ar'), Locale('en')],
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
              '/home': (context) => const MainNavigationScreen(),
              '/input': (context) => const InputScreen(),
              '/results': (context) => const ResultsScreen(),
              '/food_scanner': (context) => const FoodScannerScreen(),
              '/ai_recommendations': (context) => const AIRecommendationsScreen(),
              '/tips': (context) => const TipsScreen(),
              '/notifications': (context) => const NotificationsScreen(),
            },
          );
        },
      ),
    );
  }
}
```

### AuthCheckScreen

```dart
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
    final isLoggedIn = await AuthService.isLoggedIn();
    
    if (mounted) {
      if (isLoggedIn) {
        await context.read<UserCubit>().checkAuth();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
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
```

---

## 2. Authentication Screens

### Login Screen - `lib/presentation/screens/auth/login_screen.dart`

**الوصف**: شاشة تسجيل الدخول مع تصميم حديث وأنيميشن.

**المميزات**:
- ✅ تحقق من صحة البريد الإلكتروني
- ✅ إخفاء/إظهار كلمة المرور
- ✅ أنيميشن عند الدخول
- ✅ معالجة الأخطاء
- ✅ Top SnackBar للإشعارات

**الكود الرئيسي**:

```dart
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animationController.forward();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await context.read<UserCubit>().login(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserCubit, UserState>(
      listener: (context, state) {
        if (state is UserLoading) {
          setState(() => _isLoading = true);
        } else if (state is UserAuthenticated) {
          setState(() => _isLoading = false);
          
          showTopSnackBar(
            Overlay.of(context),
            CustomSnackBar.success(
              message: 'تم تسجيل الدخول بنجاح! 🎉',
              backgroundColor: AppColors.success,
            ),
          );

          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/home');
            }
          });
        } else if (state is UserError) {
          setState(() => _isLoading = false);
          
          showTopSnackBar(
            Overlay.of(context),
            CustomSnackBar.error(
              message: 'فشل تسجيل الدخول\n${state.message}',
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.8),
                AppColors.background,
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Logo والعنوان
                    _buildHeader(),
                    
                    // حقول الإدخال
                    _buildInputFields(),
                    
                    // زر تسجيل الدخول
                    _buildLoginButton(),
                    
                    // رابط التسجيل
                    _buildRegisterLink(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primary),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
```

**Validators**:

```dart
// Email Validator
validator: (value) {
  if (value == null || value.isEmpty) {
    return 'من فضلك أدخل البريد الإلكتروني';
  }
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
    return 'البريد الإلكتروني غير صحيح';
  }
  return null;
}

// Password Validator
validator: (value) {
  if (value == null || value.isEmpty) {
    return 'من فضلك أدخل كلمة المرور';
  }
  if (value.length < 6) {
    return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
  }
  return null;
}
```

---

### Register Screen - `lib/presentation/screens/auth/register_screen.dart`

**الوصف**: شاشة إنشاء حساب جديد.

**المميزات**:
- ✅ 4 حقول إدخال (الاسم، البريد، كلمة المرور، تأكيد كلمة المرور)
- ✅ تحقق من تطابق كلمات المرور
- ✅ تصميم responsive
- ✅ أنيميشن سلس

**الكود المختصر**:

```dart
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      await context.read<UserCubit>().register(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserCubit, UserState>(
      listener: (context, state) {
        if (state is UserAuthenticated) {
          showTopSnackBar(
            Overlay.of(context),
            CustomSnackBar.success(
              message: 'مرحباً بك! تم إنشاء حسابك بنجاح 🎉',
            ),
          );
          Navigator.pushReplacementNamed(context, '/home');
        } else if (state is UserError) {
          showTopSnackBar(
            Overlay.of(context),
            CustomSnackBar.error(message: state.message),
          );
        }
      },
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildInputField(
                  controller: _nameController,
                  label: 'الاسم الكامل',
                  icon: Icons.person_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'من فضلك أدخل الاسم';
                    }
                    if (value.length < 3) {
                      return 'الاسم يجب أن يكون 3 أحرف على الأقل';
                    }
                    return null;
                  },
                ),
                // باقي الحقول...
                _buildPrimaryButton(
                  onPressed: _handleRegister,
                  text: 'إنشاء حساب',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 3. Main Navigation - `lib/presentation/screens/main_navigation_screen.dart`

**الوصف**: الشاشة الرئيسية للتنقل بين الأقسام باستخدام Snake Navigation Bar.

**المميزات**:
- ✅ 6 تبويبات (الرئيسية، الماسح، الوجبات، النصائح، الإشعارات، الإعدادات)
- ✅ أنيميشن سلس بين الصفحات
- ✅ عداد الإشعارات
- ✅ دعم الوضع الداكن

**الكود**:

```dart
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  List<Widget> get _screens => [
    HomeContentScreen(onNavigateToTab: _onItemTapped),
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
          bottomNavigationBar: SnakeNavigationBar.color(
            behaviour: SnakeBarBehaviour.floating,
            snakeShape: SnakeShape.circle,
            backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
            snakeViewColor: AppColors.primary,
            selectedItemColor: Colors.white,
            unselectedItemColor: isDark ? Colors.grey[500] : Colors.grey[600],
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
          ),
        );
      },
    );
  }
}
```

---

## 4. Input Screen - `lib/presentation/screens/input_screen.dart`

**الوصف**: شاشة إدخال بيانات المستخدم لحساب الاحتياجات الغذائية.

**الحقول**:
- العمر (Age)
- الطول (Height in cm)
- الوزن (Weight in kg)
- الجنس (Gender: male/female)
- مستوى النشاط (Activity Level)
- الحالة الفسيولوجية (Physiological State - اختياري)

**الكود المختصر**:

```dart
class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String _gender = 'male';
  String _activityLevel = 'moderate';
  String? _physiologicalState;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final user = UserModel(
        age: int.parse(_ageController.text),
        gender: _gender,
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        activityLevel: _activityLevel,
        physiologicalState: _physiologicalState,
      );

      context.read<UserCubit>().calculateUserData(user);
      Navigator.pushNamed(context, '/results');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدخال البيانات'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _ageController,
                label: 'العمر (سنة)',
                icon: Icons.calendar_today,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال العمر';
                  }
                  int? age = int.tryParse(value);
                  if (age == null || age < 1 || age > 120) {
                    return 'أدخل عمراً صحيحاً';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              
              _buildTextField(
                controller: _heightController,
                label: 'الطول (سم)',
                icon: Icons.height,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الطول';
                  }
                  double? height = double.tryParse(value);
                  if (height == null || height < 50 || height > 250) {
                    return 'أدخل طولاً صحيحاً';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              
              _buildTextField(
                controller: _weightController,
                label: 'الوزن (كجم)',
                icon: Icons.monitor_weight,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الوزن';
                  }
                  double? weight = double.tryParse(value);
                  if (weight == null || weight < 20 || weight > 300) {
                    return 'أدخل وزناً صحيحاً';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // اختيار الجنس
              _buildGenderSelection(),
              
              // اختيار مستوى النشاط
              _buildActivityLevelDropdown(),
              
              // اختيار الحالة الفسيولوجية
              _buildPhysiologicalStateDropdown(),
              
              const SizedBox(height: 40),

              // زر الحساب
              _buildCalculateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalculateButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calculate, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'احسب الآن',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## ملخص الشاشات الرئيسية

### الشاشات المتوفرة:
1. ✅ **main.dart**: نقطة البداية
2. ✅ **LoginScreen**: تسجيل الدخول
3. ✅ **RegisterScreen**: إنشاء حساب
4. ✅ **MainNavigationScreen**: التنقل الرئيسي
5. ✅ **InputScreen**: إدخال البيانات
6. ✅ **ResultsScreen**: عرض النتائج
7. ✅ **FoodScannerScreen**: مسح الطعام
8. ✅ **AIRecommendationsScreen**: توصيات AI
9. ✅ **TipsScreen**: النصائح
10. ✅ **NotificationsScreen**: الإشعارات
11. ✅ **SettingsScreen**: الإعدادات

### التنقل بين الشاشات:

```dart
// Push
Navigator.pushNamed(context, '/home');

// Push Replacement
Navigator.pushReplacementNamed(context, '/login');

// Pop
Navigator.pop(context);

// Push and Remove Until
Navigator.pushNamedAndRemoveUntil(
  context,
  '/home',
  (route) => false,
);
```
