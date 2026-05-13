import 'package:flutter/material.dart';

class KeyboardManager {
  KeyboardManager._();
  static final KeyboardManager instance = KeyboardManager._();

  TextEditingController? _activeController;
  FocusNode? _activeFocusNode;

  TextEditingController? get activeController => _activeController;
  FocusNode? get activeFocusNode => _activeFocusNode;

  void register(TextEditingController controller, FocusNode focusNode) {
    _activeController = controller;
    _activeFocusNode = focusNode;
  }

  void clearFocus() {
    _activeFocusNode?.unfocus();
    _activeController = null;
    _activeFocusNode = null;
  }
}
