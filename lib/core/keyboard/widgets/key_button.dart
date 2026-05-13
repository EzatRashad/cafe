import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyButton extends StatefulWidget {
  final String? label;
  final Widget? icon;
  final VoidCallback onTap;
  final int flex;
  final Color? color;
  final Color? textColor;
  final bool isSpecial;
  final double? height;

  const KeyButton({
    super.key,
    this.label,
    this.icon,
    required this.onTap,
    this.flex = 1,
    this.color,
    this.textColor,
    this.isSpecial = false,
    this.height,
  });

  @override
  State<KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<KeyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Coffee Theme Colors
    const darkBrown = Color(0xFF3E2723);
    const coffeeBrown = Color(0xFF5D4037);
    const cream = Color(0xFFF5F5DC);
    const accentGold = Color(0xFFD4AF37);

    final defaultColor = widget.isSpecial
        ? (isDark ? coffeeBrown.withValues(alpha: 0.8) : Colors.grey[300])
        : (isDark ? darkBrown : Colors.white);

    final finalColor = widget.color ?? defaultColor;
    final finalTextColor = widget.textColor ?? (isDark ? cream : darkBrown);

    return Expanded(
      flex: widget.flex,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: widget.height ?? 60,
              decoration: BoxDecoration(
                color: _isHovered
                    ? finalColor!.withValues(alpha: 0.9)
                    : finalColor,
                borderRadius: BorderRadius.circular(12),
                border: widget.isSpecial
                    ? Border.all(
                        color: accentGold.withValues(alpha: 0.3), width: 1.5)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withValues(alpha: _isHovered ? 0.3 : 0.1),
                    blurRadius: _isHovered ? 8 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTapDown: (_) => _controller.forward(),
                  onTapUp: (_) => _controller.reverse(),
                  onTapCancel: () => _controller.reverse(),
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    widget.onTap();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Center(
                    child: widget.label != null
                        ? Text(
                            widget.label!,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: finalTextColor,
                              fontFamily: 'Cairo',
                            ),
                          )
                        : IconTheme(
                            data:
                                IconThemeData(color: finalTextColor, size: 24),
                            child: widget.icon!,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
