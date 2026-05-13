import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/keyboard_cubit.dart';
import 'widgets/keyboard_view.dart';

class KeyboardOverlay extends StatelessWidget {
  final Widget child;

  const KeyboardOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KeyboardCubit, KeyboardState>(
      builder: (context, state) {
        return Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  Expanded(child: child),
                  // Reserve space for the keyboard on Desktop to avoid overlapping
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: state.isVisible ? (MediaQuery.of(context).size.width > 900 ? 300 : 0) : 0,
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSlide(
                offset: state.isVisible ? Offset.zero : const Offset(0, 1),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: AnimatedOpacity(
                  opacity: state.isVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: const KeyboardView(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
