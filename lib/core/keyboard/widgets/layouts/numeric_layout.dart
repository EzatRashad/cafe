import 'package:cafe/core/keyboard/cubit/keyboard_cubit.dart';
import 'package:cafe/core/keyboard/models/cafe_keyboard_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../key_button.dart';

class NumericLayout extends StatelessWidget {
  const NumericLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<KeyboardCubit>();
    final state = context.watch<KeyboardCubit>().state;

    return Column(
      children: [
        _buildRow(["1", "2", "3"], cubit, height: 52),
        _buildRow(["4", "5", "6"], cubit, height: 52),
        _buildRow(["7", "8", "9"], cubit, height: 52),
        Row(
          children: [
            if (state.type == CafeKeyboardType.amount ||
                state.type == CafeKeyboardType.numeric)
              KeyButton(
                label: ".",
                height: 52,
                onTap: () => cubit.onKeyPressed("."),
              )
            else
              const Spacer(),
            KeyButton(
              label: "0",
              height: 52,
              onTap: () => cubit.onKeyPressed("0"),
            ),
            KeyButton(
              icon: const Icon(Icons.backspace_outlined),
              isSpecial: true,
              height: 52,
              onTap: () => cubit.onBackspace(),
            ),
          ],
        ),
        Row(
          children: [
            KeyButton(
              label: "ABC",
              isSpecial: true,
              height: 52,
              onTap: () => cubit.show(CafeKeyboardType.text),
            ),
            KeyButton(
              label: "Clear",
              isSpecial: true,
              height: 52,
              color: Colors.red.withOpacity(0.1),
              textColor: Colors.red,
              onTap: () => cubit.onClear(),
            ),
            KeyButton(
              label: "Done",
              flex: 2,
              isSpecial: true,
              height: 52,
              color: const Color(0xFFD4AF37),
              textColor: Colors.white,
              onTap: () => cubit.onDone(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(List<String> keys, KeyboardCubit cubit, {double? height}) {
    return Row(
      children: keys
          .map((key) => KeyButton(
                label: key,
                height: height,
                onTap: () => cubit.onKeyPressed(key),
              ))
          .toList(),
    );
  }
}
