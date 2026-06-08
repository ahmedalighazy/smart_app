import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubits/settings_cubit.dart';

class DirectionHelper {
  /// Get the current text direction based on the app's locale
  static TextDirection getTextDirection(BuildContext context) {
    final settingsState = context.watch<SettingsCubit>().state;
    return settingsState.locale.languageCode == 'ar'
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  /// Get the current text direction without watching (for one-time use)
  static TextDirection getTextDirectionStatic(BuildContext context) {
    final settingsState = context.read<SettingsCubit>().state;
    return settingsState.locale.languageCode == 'ar'
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  /// Check if current language is Arabic
  static bool isArabic(BuildContext context) {
    final settingsState = context.watch<SettingsCubit>().state;
    return settingsState.locale.languageCode == 'ar';
  }

  /// Check if current language is Arabic (static version)
  static bool isArabicStatic(BuildContext context) {
    final settingsState = context.read<SettingsCubit>().state;
    return settingsState.locale.languageCode == 'ar';
  }

  /// Get text align based on language
  static TextAlign getTextAlign(BuildContext context) {
    return isArabic(context) ? TextAlign.right : TextAlign.left;
  }

  /// Get text align based on language (static version)
  static TextAlign getTextAlignStatic(BuildContext context) {
    return isArabicStatic(context) ? TextAlign.right : TextAlign.left;
  }
}

/// Extension to make it easier to use
extension DirectionExtension on BuildContext {
  TextDirection get textDirection => DirectionHelper.getTextDirection(this);
  TextDirection get textDirectionStatic =>
      DirectionHelper.getTextDirectionStatic(this);
  bool get isArabic => DirectionHelper.isArabic(this);
  bool get isArabicStatic => DirectionHelper.isArabicStatic(this);
  TextAlign get textAlign => DirectionHelper.getTextAlign(this);
  TextAlign get textAlignStatic => DirectionHelper.getTextAlignStatic(this);
}
