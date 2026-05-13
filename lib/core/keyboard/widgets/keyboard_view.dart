import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/keyboard_cubit.dart';
import '../models/cafe_keyboard_type.dart';
import 'layouts/arabic_layout.dart';
import 'layouts/english_layout.dart';
import 'layouts/numeric_layout.dart';

class KeyboardView extends StatelessWidget {
  const KeyboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<KeyboardCubit>().state;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    const darkBrown = Color(0xFF3E2723);
    const coffeeBrown = Color(0xFF5D4037);
    const accentGold = Color(0xFFD4AF37);
    const cream = Color(0xFFF5F5DC);

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          decoration: BoxDecoration(
            color: isDark 
                ? darkBrown.withValues(alpha: 0.85) 
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            border: Border.all(
              color: accentGold.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Premium Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: accentGold.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                _buildPremiumHeader(context, state, isDark),
                const SizedBox(height: 12),
                _buildLayout(state),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(BuildContext context, KeyboardState state, bool isDark) {
    const accentGold = Color(0xFFD4AF37);
    const cream = Color(0xFFF5F5DC);
    const darkBrown = Color(0xFF3E2723);

    return Row(
      children: [
        // Type Indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: accentGold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentGold.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(
                _getTypeIcon(state.type),
                size: 16,
                color: accentGold,
              ),
              const SizedBox(width: 8),
              Text(
                _getTypeLabel(state.type),
                style: const TextStyle(
                  color: accentGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Language Switcher Toggle
        _buildLanguageToggle(context, state, isDark),
        const SizedBox(width: 12),
        // Close Button
        GestureDetector(
          onTap: () => context.read<KeyboardCubit>().hide(),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close_rounded, color: Colors.red, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageToggle(BuildContext context, KeyboardState state, bool isDark) {
    const accentGold = Color(0xFFD4AF37);
    const darkBrown = Color(0xFF3E2723);
    const cream = Color(0xFFF5F5DC);

    final isAr = state.language == KeyboardLanguage.ar;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.grey[200],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _buildToggleItem("AR", isAr, () {
            if (!isAr) context.read<KeyboardCubit>().toggleLanguage();
          }),
          _buildToggleItem("EN", !isAr, () {
            if (isAr) context.read<KeyboardCubit>().toggleLanguage();
          }),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, bool active, VoidCallback onTap) {
    const accentGold = Color(0xFFD4AF37);
    const darkBrown = Color(0xFF3E2723);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: active ? accentGold : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: active ? [
            BoxShadow(
              color: accentGold.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(CafeKeyboardType type) {
    switch (type) {
      case CafeKeyboardType.numeric:
      case CafeKeyboardType.amount:
      case CafeKeyboardType.quantity:
        return Icons.calculate_rounded;
      default:
        return Icons.keyboard_rounded;
    }
  }

  String _getTypeLabel(CafeKeyboardType type) {
    switch (type) {
      case CafeKeyboardType.numeric:
        return "Numeric";
      case CafeKeyboardType.amount:
        return "Amount";
      case CafeKeyboardType.quantity:
        return "Quantity";
      default:
        return "Text Input";
    }
  }

  Widget _buildLayout(KeyboardState state) {
    if (state.type == CafeKeyboardType.numeric || 
        state.type == CafeKeyboardType.amount || 
        state.type == CafeKeyboardType.quantity) {
      return const NumericLayout();
    }

    if (state.language == KeyboardLanguage.ar) {
      return const ArabicLayout();
    }

    return const EnglishLayout();
  }
}
