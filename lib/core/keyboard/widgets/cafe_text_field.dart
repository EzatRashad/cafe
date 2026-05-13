import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/keyboard_cubit.dart';
import '../keyboard_manager.dart';
import '../models/cafe_keyboard_type.dart';

class CafeTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? initialValue;
  final Widget? prefixIcon;
  final CafeKeyboardType keyboardType;
  final bool autofocus;
  final InputDecoration? decoration;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final String? Function(String?)? validator;

  const CafeTextField({
    super.key,
    this.controller,
    this.hintText,
    this.initialValue,
    this.prefixIcon,
    this.keyboardType = CafeKeyboardType.text,
    this.autofocus = false,
    this.decoration,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.obscureText = false,
    this.validator,
  });

  @override
  State<CafeTextField> createState() => _CafeTextFieldState();
}

class _CafeTextFieldState extends State<CafeTextField> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    widget.onChanged?.call(_controller.text);
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _showKeyboard();
    }
  }

  void _showKeyboard() {
    KeyboardManager.instance.register(_controller, _focusNode);
    context.read<KeyboardCubit>().show(widget.keyboardType);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      readOnly: true,
      showCursor: true,
      autofocus: widget.autofocus,
      obscureText: widget.obscureText,
      validator: widget.validator,
      decoration: (widget.decoration ?? const InputDecoration()).copyWith(
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon,
      ),
      onTap: _showKeyboard,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      textInputAction: widget.textInputAction,
    );
  }
}
