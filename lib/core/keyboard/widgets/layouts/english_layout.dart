import 'package:cafe/core/keyboard/cubit/keyboard_cubit.dart';
import 'package:cafe/core/keyboard/models/cafe_keyboard_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../key_button.dart';

class EnglishLayout extends StatelessWidget {
  const EnglishLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<KeyboardCubit>();
    final state = context.watch<KeyboardCubit>().state;

    return Column(
      children: [
        // Row 1
        _buildRow(["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"], cubit),
        // Row 2
        _buildRow(["A", "S", "D", "F", "G", "H", "J", "K", "L"], cubit),
        // Row 3
        Row(
          children: [
            KeyButton(
              icon: Icon(state.isCapsLockEnabled
                  ? Icons.keyboard_capslock
                  : Icons.arrow_upward),
              isSpecial: true,
              color: state.isShiftEnabled || state.isCapsLockEnabled
                  ? Colors.blue
                  : null,
              onTap: () => cubit.toggleShift(),
            ),
            ...["Z", "X", "C", "V", "B", "N", "M"].map((char) => KeyButton(
                  label: state.isShiftEnabled || state.isCapsLockEnabled
                      ? char
                      : char.toLowerCase(),
                  onTap: () => cubit.onKeyPressed(char),
                )),
            KeyButton(
              icon: const Icon(Icons.backspace_outlined),
              isSpecial: true,
              onTap: () => cubit.onBackspace(),
            ),
          ],
        ),
        // Row 4
        Row(
          children: [
            KeyButton(
              label: "AR",
              isSpecial: true,
              onTap: () => cubit.toggleLanguage(),
            ),
            KeyButton(
              label: "123",
              isSpecial: true,
              onTap: () => cubit.show(CafeKeyboardType.numeric),
            ),
            KeyButton(
              label: "Space",
              flex: 4,
              onTap: () => cubit.onKeyPressed(" "),
            ),
            KeyButton(
              label: "Clear",
              isSpecial: true,
              color: Colors.red.withOpacity(0.1),
              textColor: Colors.red,
              onTap: () => cubit.onClear(),
            ),
            KeyButton(
              label: "Done",
              isSpecial: true,
              color: const Color(0xFFD4AF37),
              textColor: Colors.white,
              onTap: () => cubit.onDone(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(List<String> keys, KeyboardCubit cubit) {
    return Row(
      children: keys
          .map((key) => KeyButton(
                label: key,
                onTap: () => cubit.onKeyPressed(key),
              ))
          .toList(),
    );
  }
}
