import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    final langCode = prefs.getString('languageCode') ?? 'ar';

    emit(SettingsState(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(langCode),
    ));
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final newMode =
        state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await prefs.setBool('isDarkMode', newMode == ThemeMode.dark);
    emit(state.copyWith(themeMode: newMode));
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    emit(state.copyWith(locale: locale));
  }

  Future<void> toggleLanguage() async {
    final newLocale =
        state.locale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    await setLocale(newLocale);
  }
}
