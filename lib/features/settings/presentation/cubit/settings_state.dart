part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final Locale locale;
  final bool isTaxEnabled;
  final double taxPercent;

  const SettingsState({
    this.themeMode = ThemeMode.light,
    this.locale = const Locale('en'),
    this.isTaxEnabled = false,
    this.taxPercent = 15.0,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? isTaxEnabled,
    double? taxPercent,
  }) =>
      SettingsState(
        themeMode: themeMode ?? this.themeMode,
        locale: locale ?? this.locale,
        isTaxEnabled: isTaxEnabled ?? this.isTaxEnabled,
        taxPercent: taxPercent ?? this.taxPercent,
      );

  bool get isDark => themeMode == ThemeMode.dark;
  String get fontFamily {
    switch (locale.languageCode) {
      case 'ar':
        return 'Cairo';
      case 'bn':
        return 'NotoSansBengali';
      default:
        return 'Inter';
    }
  }

  @override
  List<Object?> get props => [themeMode, locale, isTaxEnabled, taxPercent];
}
