import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/cafe_keyboard_type.dart';
import '../keyboard_manager.dart';

part 'keyboard_state.dart';

class KeyboardCubit extends Cubit<KeyboardState> {
  KeyboardCubit() : super(KeyboardState());

  void show(CafeKeyboardType type) {
    emit(state.copyWith(isVisible: true, type: type));
  }

  void hide() {
    emit(state.copyWith(isVisible: false));
    KeyboardManager.instance.clearFocus();
  }

  void toggleLanguage() {
    final nextLang = state.language == KeyboardLanguage.ar ? KeyboardLanguage.en : KeyboardLanguage.ar;
    emit(state.copyWith(language: nextLang));
  }

  void toggleShift() {
    emit(state.copyWith(isShiftEnabled: !state.isShiftEnabled));
  }

  void toggleCapsLock() {
    emit(state.copyWith(isCapsLockEnabled: !state.isCapsLockEnabled));
  }

  void onKeyPressed(String char) {
    final controller = KeyboardManager.instance.activeController;
    if (controller == null) return;

    final text = controller.text;
    final selection = controller.selection;
    
    // Determine the character to insert based on shift/capslock if it's a letter
    String charToInsert = char;
    if (state.language == KeyboardLanguage.en) {
      if (state.isShiftEnabled || state.isCapsLockEnabled) {
        charToInsert = char.toUpperCase();
      } else {
        charToInsert = char.toLowerCase();
      }
    }

    final newText = text.replaceRange(
      selection.start,
      selection.end,
      charToInsert,
    );
    
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selection.start + charToInsert.length),
    );

    // If shift was enabled (one-time), disable it after one key press
    if (state.isShiftEnabled && !state.isCapsLockEnabled) {
      emit(state.copyWith(isShiftEnabled: false));
    }
  }

  void onBackspace() {
    final controller = KeyboardManager.instance.activeController;
    if (controller == null) return;

    final text = controller.text;
    final selection = controller.selection;

    if (selection.start != selection.end) {
      // Delete selection
      final newText = text.replaceRange(selection.start, selection.end, '');
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start),
      );
    } else if (selection.start > 0) {
      // Delete previous character
      final newText = text.replaceRange(selection.start - 1, selection.start, '');
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start - 1),
      );
    }
  }

  void onClear() {
    KeyboardManager.instance.activeController?.clear();
  }

  void onDone() {
    hide();
  }
}
