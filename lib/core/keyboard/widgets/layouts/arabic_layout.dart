import 'package:cafe/core/keyboard/cubit/keyboard_cubit.dart';
import 'package:cafe/core/keyboard/models/cafe_keyboard_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../key_button.dart';

class ArabicLayout extends StatelessWidget {
  const ArabicLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<KeyboardCubit>();
    const accentGold = Color(0xFFD4AF37);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          _buildRow(
              ["ض", "ص", "ث", "ق", "ف", "غ", "ع", "ه", "خ", "ح", "ج", "د"],
              cubit),
          _buildRow(
              ["ش", "س", "ي", "ب", "ل", "ا", "ت", "ن", "م", "ك", "ط"], cubit),
          Row(
            children: [
              KeyButton(
                label: "ء",
                onTap: () => cubit.onKeyPressed("ء"),
              ),
              ...["ئ", "ء", "ؤ", "ر", "لا", "ى", "ة", "و", "ز", "ظ"]
                  .map((char) => KeyButton(
                        label: char,
                        onTap: () => cubit.onKeyPressed(char),
                      )),
              KeyButton(
                icon: const Icon(Icons.backspace_outlined),
                isSpecial: true,
                onTap: () => cubit.onBackspace(),
              ),
            ],
          ),
          Row(
            children: [
              KeyButton(
                label: "EN",
                isSpecial: true,
                onTap: () => cubit.toggleLanguage(),
              ),
              KeyButton(
                label: "123",
                isSpecial: true,
                onTap: () => cubit.show(CafeKeyboardType.numeric),
              ),
              KeyButton(
                label: "مسافة",
                flex: 4,
                onTap: () => cubit.onKeyPressed(" "),
              ),
              KeyButton(
                label: "مسح",
                isSpecial: true,
                color: Colors.red.withOpacity(0.1),
                textColor: Colors.red,
                onTap: () => cubit.onClear(),
              ),
              KeyButton(
                label: "تم",
                isSpecial: true,
                color: accentGold,
                textColor: Colors.white,
                onTap: () => cubit.onDone(),
              ),
            ],
          ),
        ],
      ),
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
