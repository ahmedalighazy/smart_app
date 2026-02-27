# 🧠 Logic Layer - State Management (Cubits)

## نظرة عامة
طبقة المنطق تستخدم BLoC/Cubit لإدارة حالة التطبيق.

---

## 1. User Cubit - `lib/logic/cubits/user_cubit.dart`

### الوصف
إدارة حالة المستخدم والحسابات الغذائية والمصادقة.

### States (الحالات)

```dart
abstract class UserState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserCalculated extends UserState {
  final UserModel user;
  final CalculationResult result;

  UserCalculated({required this.user, required this.result});

  @override
  List<Object?> get props => [user, result];
}

class UserError extends UserState {
  final String message;
  UserError(this.message);

  @override
  List<Object?> get props => [message];
}

class UserAuthenticated extends UserState {
  final Map<String, dynamic>? userData;
  UserAuthenticated([this.userData]);

  @override
  List<Object?> get props => [userData];
}
```

### Cubit

```dart
class UserCubit extends Cubit<UserState> {
  final CalculationService _calculationService = CalculationService();

  UserCubit() : super(UserInitial());

  // التحقق من المصادقة
  Future<bool> checkAuth() async {
    try {
      emit(UserLoading());
      final result = await AuthService.autoLogin();
      if (result['success'] == true) {
        emit(UserAuthenticated());
        return true;
      }
      emit(UserInitial());
      return false;
    } catch (e) {
      emit(UserInitial());
      return false;
    }
  }

  // حساب بيانات المستخدم
  void calculateUserData(UserModel user) {
    try {
      emit(UserLoading());
      final result = _calculationService.performCalculation(user);
      emit(UserCalculated(user: user, result: result));
    } catch (e) {
      emit(UserError('خطأ في الحساب: $e'));
    }
  }

  // تسجيل الدخول
  Future<void> login(String email, String password) async {
    try {
      emit(UserLoading());
      final result = await AuthService.login(email: email, password: password);

      if (result['success'] == true) {
        emit(UserAuthenticated(result['data']));
      } else {
        emit(UserError(result['message'] ?? 'فشل تسجيل الدخول'));
      }
    } catch (e) {
      emit(UserError('خطأ في تسجيل الدخول: $e'));
    }
  }

  // التسجيل
  Future<void> register(String name, String email, String password) async {
    try {
      emit(UserLoading());
      final result = await AuthService.register(
        username: email.split('@')[0],
        email: email,
        password: password,
        fullName: name,
      );

      if (result['success'] == true) {
        emit(UserAuthenticated(result['data']));
      } else {
        emit(UserError(result['message'] ?? 'فشل التسجيل'));
      }
    } catch (e) {
      emit(UserError('خطأ في التسجيل: $e'));
    }
  }

  // تسجيل الخروج
  Future<void> logout() async {
    await AuthService.logout();
    emit(UserInitial());
  }

  // إعادة تعيين
  void reset() {
    emit(UserInitial());
  }

  // Getters
  UserModel? get currentUser {
    if (state is UserCalculated) {
      return (state as UserCalculated).user;
    }
    return null;
  }

  CalculationResult? get currentResult {
    if (state is UserCalculated) {
      return (state as UserCalculated).result;
    }
    return null;
  }
}
```

### الاستخدام

```dart
// في BlocProvider
BlocProvider(
  create: (context) => UserCubit(),
  child: MyApp(),
)

// في Widget
BlocBuilder<UserCubit, UserState>(
  builder: (context, state) {
    if (state is UserLoading) {
      return CircularProgressIndicator();
    }
    
    if (state is UserCalculated) {
      return Text('BMI: ${state.result.bmi}');
    }
    
    if (state is UserError) {
      return Text(state.message);
    }
    
    return LoginButton();
  },
)

// استدعاء الوظائف
context.read<UserCubit>().login(email, password);
context.read<UserCubit>().calculateUserData(user);
context.read<UserCubit>().logout();
```

---

## 2. Settings Cubit - `lib/logic/cubits/settings_cubit.dart`

### الوصف
إدارة إعدادات التطبيق (الثيم واللغة).

### State

```dart
class SettingsState {
  final ThemeMode themeMode;
  final Locale locale;

  const SettingsState({
    this.themeMode = ThemeMode.light,
    this.locale = const Locale('ar'),
  });

  SettingsState copyWith({ThemeMode? themeMode, Locale? locale}) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }

  bool get isDarkMode => themeMode == ThemeMode.dark;
  bool get isArabic => locale.languageCode == 'ar';
}
```

### Cubit

```dart
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState()) {
    _loadSettings();
  }

  // تحميل الإعدادات المحفوظة
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    final langCode = prefs.getString('languageCode') ?? 'ar';

    emit(SettingsState(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(langCode),
    ));
  }

  // تبديل الثيم
  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final newMode = state.themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    await prefs.setBool('isDarkMode', newMode == ThemeMode.dark);
    emit(state.copyWith(themeMode: newMode));
  }

  // تغيير اللغة
  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    emit(state.copyWith(locale: locale));
  }

  // تبديل اللغة
  Future<void> toggleLanguage() async {
    final newLocale = state.locale.languageCode == 'ar' 
        ? const Locale('en') 
        : const Locale('ar');
    await setLocale(newLocale);
  }
}
```

### الاستخدام

```dart
// في MaterialApp
BlocBuilder<SettingsCubit, SettingsState>(
  builder: (context, state) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: state.themeMode,
      locale: state.locale,
      home: HomeScreen(),
    );
  },
)

// تبديل الثيم
IconButton(
  icon: Icon(Icons.dark_mode),
  onPressed: () => context.read<SettingsCubit>().toggleTheme(),
)

// تغيير اللغة
ElevatedButton(
  onPressed: () => context.read<SettingsCubit>().setLocale(Locale('en')),
  child: Text('English'),
)
```

---

## 3. Food Scanner Cubit - `lib/logic/cubits/food_scanner_cubit.dart`

### الوصف
إدارة حالة مسح الطعام بالكاميرا.

### States

```dart
abstract class FoodScannerState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FoodScannerInitial extends FoodScannerState {}

class FoodScannerImageSelected extends FoodScannerState {
  final File imageFile;
  FoodScannerImageSelected(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}

class FoodScannerAnalyzing extends FoodScannerState {}

class FoodScannerAnalyzed extends FoodScannerState {
  final File imageFile;
  final FoodAnalysisResult result;

  FoodScannerAnalyzed({required this.imageFile, required this.result});

  @override
  List<Object?> get props => [imageFile, result];
}

class FoodScannerError extends FoodScannerState {
  final String message;
  FoodScannerError(this.message);

  @override
  List<Object?> get props => [message];
}
```

### Cubit

```dart
class FoodScannerCubit extends Cubit<FoodScannerState> {
  final FoodVisionService _visionService = FoodVisionService();

  FoodScannerCubit() : super(FoodScannerInitial());

  // اختيار صورة
  void selectImage(File imageFile) {
    emit(FoodScannerImageSelected(imageFile));
  }

  // تحليل الطعام
  Future<void> analyzeFood(File imageFile) async {
    try {
      emit(FoodScannerAnalyzing());
      final result = await _visionService.analyzeFood(imageFile);
      emit(FoodScannerAnalyzed(imageFile: imageFile, result: result));
    } catch (e) {
      emit(FoodScannerError('فشل تحليل الصورة: $e'));
    }
  }

  // إعادة تعيين
  void reset() {
    emit(FoodScannerInitial());
  }
}
```

### الاستخدام

```dart
// التقاط صورة وتحليلها
Future<void> _takePhoto() async {
  final XFile? photo = await ImagePicker().pickImage(
    source: ImageSource.camera,
  );

  if (photo != null) {
    final file = File(photo.path);
    context.read<FoodScannerCubit>().analyzeFood(file);
  }
}

// عرض النتائج
BlocBuilder<FoodScannerCubit, FoodScannerState>(
  builder: (context, state) {
    if (state is FoodScannerAnalyzing) {
      return CircularProgressIndicator();
    }
    
    if (state is FoodScannerAnalyzed) {
      return Column(
        children: [
          Image.file(state.imageFile),
          Text('Food: ${state.result.foodName}'),
          Text('Calories: ${state.result.calories}'),
        ],
      );
    }
    
    if (state is FoodScannerError) {
      return Text(state.message);
    }
    
    return CameraButton();
  },
)
```

---

## 4. Tips Cubit - `lib/logic/cubits/tips_cubit.dart`

### الوصف
إدارة النصائح الغذائية والرياضية.

### States

```dart
abstract class TipsState extends Equatable {
  const TipsState();

  @override
  List<Object?> get props => [];
}

class TipsInitial extends TipsState {
  const TipsInitial();
}

class TipsLoaded extends TipsState {
  final String tip;
  final String type; // 'nutrition', 'fitness', 'meal', 'random'

  const TipsLoaded({
    required this.tip,
    this.type = 'random',
  });

  @override
  List<Object?> get props => [tip, type];
}
```

### Cubit

```dart
class TipsCubit extends Cubit<TipsState> {
  TipsCubit() : super(const TipsInitial());

  // نصيحة عشوائية
  void getRandomTip() {
    final tip = TipsService.getRandomTip();
    emit(TipsLoaded(tip: tip));
  }

  // نصيحة غذائية
  void getNutritionTip() {
    final tip = TipsService.getRandomNutritionTip();
    emit(TipsLoaded(tip: tip, type: 'nutrition'));
  }

  // نصيحة رياضية
  void getFitnessTip() {
    final tip = TipsService.getRandomFitnessTip();
    emit(TipsLoaded(tip: tip, type: 'fitness'));
  }

  // نصائح حسب نوع الوجبة
  void getTipsForMeal(String mealType) {
    final tips = TipsService.getTipsForMealType(mealType);
    emit(TipsLoaded(tip: tips.first, type: 'meal'));
  }
}
```

### الاستخدام

```dart
// الحصول على نصيحة
context.read<TipsCubit>().getRandomTip();
context.read<TipsCubit>().getNutritionTip();

// عرض النصيحة
BlocBuilder<TipsCubit, TipsState>(
  builder: (context, state) {
    if (state is TipsLoaded) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            state.tip,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }
    return SizedBox();
  },
)
```

---

## 5. Notification History Cubit

### الوصف
إدارة سجل الإشعارات.

### States

```dart
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
```

### Cubit

```dart
class NotificationHistoryCubit extends Cubit<NotificationHistoryState> {
  NotificationHistoryCubit() : super(const NotificationHistoryInitial());

  // تحميل الإشعارات
  void loadNotifications() {
    try {
      final notifications = NotificationHistoryService.getAllNotifications();
      emit(NotificationHistoryLoaded(notifications: notifications));
    } catch (e) {
      emit(NotificationHistoryError(message: e.toString()));
    }
  }

  // تحميل إشعارات الوجبات فقط
  void loadMealNotifications() {
    try {
      final notifications = NotificationHistoryService.getNotificationsByType('meal');
      emit(NotificationHistoryLoaded(notifications: notifications));
    } catch (e) {
      emit(NotificationHistoryError(message: e.toString()));
    }
  }

  // حذف إشعار
  void deleteNotification(String id) {
    try {
      NotificationHistoryService.deleteNotification(id);
      loadNotifications();
    } catch (e) {
      emit(NotificationHistoryError(message: e.toString()));
    }
  }

  // مسح الكل
  void clearAll() {
    try {
      NotificationHistoryService.clearAll();
      emit(const NotificationHistoryLoaded(notifications: []));
    } catch (e) {
      emit(NotificationHistoryError(message: e.toString()));
    }
  }

  // عدد الإشعارات
  int getNotificationCount() {
    return NotificationHistoryService.getNotificationCount();
  }
}
```

---

## 6. Social Media Cubit

### الوصف
إدارة حالة السوشيال ميديا والمصادقة المتقدمة.

### States

```dart
abstract class SocialMediaState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SocialMediaInitial extends SocialMediaState {}

class SocialMediaLoading extends SocialMediaState {}

class SocialMediaAuthenticated extends SocialMediaState {
  final SocialMediaUser? user;
  final String? accessToken;

  SocialMediaAuthenticated({this.user, this.accessToken});

  @override
  List<Object?> get props => [user, accessToken];
}

class SocialMediaError extends SocialMediaState {
  final String message;
  SocialMediaError(this.message);

  @override
  List<Object?> get props => [message];
}

class SocialMediaSuccess extends SocialMediaState {
  final String message;
  SocialMediaSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
```

### Cubit (مختصر)

```dart
class SocialMediaCubit extends Cubit<SocialMediaState> {
  SocialMediaCubit() : super(SocialMediaInitial());

  // تسجيل الدخول
  Future<void> login({required String email, required String password}) async {
    try {
      emit(SocialMediaLoading());
      final response = await SocialMediaService.login(email: email, password: password);

      if (response.success && response.accessToken != null) {
        await _saveTokens(response.accessToken!, response.refreshToken);
        DioHelper.setToken(response.accessToken!);
        emit(SocialMediaAuthenticated(
          user: response.user,
          accessToken: response.accessToken,
        ));
      } else {
        emit(SocialMediaError(response.message ?? 'فشل تسجيل الدخول'));
      }
    } catch (e) {
      emit(SocialMediaError(e.toString()));
    }
  }

  // تسجيل الخروج
  Future<void> logout() async {
    try {
      emit(SocialMediaLoading());
      await SocialMediaService.logout();
      await _clearTokens();
      DioHelper.removeToken();
      emit(SocialMediaInitial());
    } catch (e) {
      await _clearTokens();
      emit(SocialMediaInitial());
    }
  }

  // Google Login
  Future<void> googleLogin() async {
    try {
      emit(SocialMediaLoading());
      final response = await SocialMediaService.googleLogin();
      
      if (response.success && response.accessToken != null) {
        await _saveTokens(response.accessToken!, response.refreshToken);
        emit(SocialMediaAuthenticated(
          user: response.user,
          accessToken: response.accessToken,
        ));
      }
    } catch (e) {
      emit(SocialMediaError(e.toString()));
    }
  }
}
```

---

## ملخص Cubits

### الـ Cubits المتوفرة:
1. ✅ **UserCubit**: المستخدم والحسابات
2. ✅ **SettingsCubit**: الإعدادات (ثيم/لغة)
3. ✅ **FoodScannerCubit**: مسح الطعام
4. ✅ **FoodSearchCubit**: البحث عن الطعام
5. ✅ **TipsCubit**: النصائح
6. ✅ **NotificationHistoryCubit**: سجل الإشعارات
7. ✅ **SocialMediaCubit**: السوشيال ميديا

### الإعداد في main.dart

```dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (context) => UserCubit()),
    BlocProvider(create: (context) => FoodScannerCubit()),
    BlocProvider(create: (context) => SettingsCubit()),
    BlocProvider(create: (context) => SocialMediaCubit()),
    BlocProvider(create: (context) => TipsCubit()),
    BlocProvider(create: (context) => NotificationHistoryCubit()),
  ],
  child: MyApp(),
)
```

### الاستخدام العام

```dart
// قراءة الحالة
final state = context.watch<UserCubit>().state;

// استدعاء وظيفة
context.read<UserCubit>().login(email, password);

// BlocBuilder
BlocBuilder<UserCubit, UserState>(
  builder: (context, state) {
    if (state is UserLoading) return CircularProgressIndicator();
    if (state is UserCalculated) return ResultsWidget(state.result);
    return LoginWidget();
  },
)

// BlocListener
BlocListener<UserCubit, UserState>(
  listener: (context, state) {
    if (state is UserError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: MyWidget(),
)
```
