part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final Locale locale;

  const SettingsState({
    this.themeMode = ThemeMode.light,
    this.locale = const Locale('en'),
  });

  SettingsState copyWith({ThemeMode? themeMode, Locale? locale}) =>
      SettingsState(
        themeMode: themeMode ?? this.themeMode,
        locale: locale ?? this.locale,
      );

  bool get isDark => themeMode == ThemeMode.dark;
  String get fontFamily {
    switch (locale.languageCode) {
      case 'ar': return 'Cairo';
      case 'bn': return 'NotoSansBengali';
      default: return 'Inter';
    }
  }

  @override
  List<Object?> get props => [themeMode, locale];
}
