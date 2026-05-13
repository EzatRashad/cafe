import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeStr = prefs.getString(AppStrings.prefThemeKey) ?? 'light';
    final langCode = prefs.getString(AppStrings.prefLangKey) ?? 'en';
    emit(SettingsState(
      themeMode: themeStr == 'dark' ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(langCode),
    ));
  }

  Future<void> toggleTheme() async {
    final isDark = state.themeMode == ThemeMode.dark;
    final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppStrings.prefThemeKey, isDark ? 'light' : 'dark');
    emit(state.copyWith(themeMode: newMode));
  }

  Future<void> setLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppStrings.prefLangKey, langCode);
    emit(state.copyWith(locale: Locale(langCode)));
  }
}
