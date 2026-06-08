import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/notification_service.dart';

class SettingsState {
  final ThemeMode themeMode;
  final Locale locale;
  final bool notificationsMuted;
  final bool periodicNotificationsEnabled;

  const SettingsState({
    this.themeMode = ThemeMode.light,
    this.locale = const Locale('ar'),
    this.notificationsMuted = false,
    this.periodicNotificationsEnabled = false,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? notificationsMuted,
    bool? periodicNotificationsEnabled,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      notificationsMuted: notificationsMuted ?? this.notificationsMuted,
      periodicNotificationsEnabled:
          periodicNotificationsEnabled ?? this.periodicNotificationsEnabled,
    );
  }

  bool get isDarkMode => themeMode == ThemeMode.dark;
  bool get isArabic => locale.languageCode == 'ar';
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    final langCode = prefs.getString('languageCode') ?? 'ar';
    final muted = prefs.getBool('notificationsMuted') ?? false;
    final periodicEnabled =
        prefs.getBool('periodicNotificationsEnabled') ?? false;

    emit(
      SettingsState(
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        locale: Locale(langCode),
        notificationsMuted: muted,
        periodicNotificationsEnabled: periodicEnabled,
      ),
    );
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final newMode = state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    await prefs.setBool('isDarkMode', newMode == ThemeMode.dark);
    emit(state.copyWith(themeMode: newMode));
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    debugPrint('🌐 Setting locale to: ${locale.languageCode}');
    emit(state.copyWith(locale: locale));
  }

  Future<void> toggleLanguage() async {
    final newLocale = state.locale.languageCode == 'ar'
        ? const Locale('en')
        : const Locale('ar');
    debugPrint(
      '🔄 Toggling language from ${state.locale.languageCode} to ${newLocale.languageCode}',
    );
    await setLocale(newLocale);
  }

  Future<void> toggleNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !state.notificationsMuted;
    await prefs.setBool('notificationsMuted', newValue);

    // إيقاف الإشعارات الدورية إذا تم كتم الإشعارات
    if (newValue && state.periodicNotificationsEnabled) {
      NotificationService().stopPeriodicNotifications();
      await prefs.setBool('periodicNotificationsEnabled', false);
      emit(
        state.copyWith(
          notificationsMuted: newValue,
          periodicNotificationsEnabled: false,
        ),
      );
    } else {
      emit(state.copyWith(notificationsMuted: newValue));
    }
  }

  Future<void> togglePeriodicNotifications() async {
    final newValue = !state.periodicNotificationsEnabled;

    if (newValue) {
      // تفعيل الإشعارات الدورية
      await NotificationService().startPeriodicNotifications();
    } else {
      // إيقاف الإشعارات الدورية
      NotificationService().stopPeriodicNotifications();
    }

    emit(state.copyWith(periodicNotificationsEnabled: newValue));
  }
}
