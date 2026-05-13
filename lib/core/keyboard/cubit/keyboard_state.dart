part of 'keyboard_cubit.dart';

enum KeyboardLanguage { en, ar }

class KeyboardState {
  final bool isVisible;
  final CafeKeyboardType type;
  final KeyboardLanguage language;
  final bool isShiftEnabled;
  final bool isCapsLockEnabled;
  final double height;

  KeyboardState({
    this.isVisible = false,
    this.type = CafeKeyboardType.text,
    this.language = KeyboardLanguage.ar,
    this.isShiftEnabled = false,
    this.isCapsLockEnabled = false,
    this.height = 300,
  });

  KeyboardState copyWith({
    bool? isVisible,
    CafeKeyboardType? type,
    KeyboardLanguage? language,
    bool? isShiftEnabled,
    bool? isCapsLockEnabled,
    double? height,
  }) {
    return KeyboardState(
      isVisible: isVisible ?? this.isVisible,
      type: type ?? this.type,
      language: language ?? this.language,
      isShiftEnabled: isShiftEnabled ?? this.isShiftEnabled,
      isCapsLockEnabled: isCapsLockEnabled ?? this.isCapsLockEnabled,
      height: height ?? this.height,
    );
  }
}
