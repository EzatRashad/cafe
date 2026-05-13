import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/keyboard/widgets/cafe_text_field.dart';
import '../../core/keyboard/models/cafe_keyboard_type.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isOutlined;
  final bool isLoading;
  final Color? color;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isOutlined = false,
    this.isLoading = false,
    this.color,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
        : Row(
             children: [
              if (icon != null) ...[Icon(icon, size: 15), const SizedBox(width: 3)],
              Text(label),
            ],
          );

    if (isOutlined) {
      return SizedBox(
        width: width,
        child: OutlinedButton(onPressed: isLoading ? null : onPressed, child: child),
      );
    }
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: color != null
            ? ElevatedButton.styleFrom(backgroundColor: color)
            : null,
        child: child,
      ),
    );
  }
}

class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
 
  final Widget? suffixIcon;
  final int maxLines;

  final bool readOnly;
  final VoidCallback? onTap;
  final void Function(String)? onChanged;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return CafeTextField(
      controller: widget.controller,
      obscureText: widget.obscureText ? _obscure : false,
      keyboardType: _mapKeyboardType(widget.keyboardType),
      validator: widget.validator,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : widget.suffixIcon,
      ),
    );
  }

  CafeKeyboardType _mapKeyboardType(TextInputType type) {
    if (type == TextInputType.number) return CafeKeyboardType.numeric;
    if (type == TextInputType.emailAddress) return CafeKeyboardType.email;
    if (type == TextInputType.phone) return CafeKeyboardType.phone;
    if (type == const TextInputType.numberWithOptions(decimal: true)) return CafeKeyboardType.amount;
    return CafeKeyboardType.text;
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? color;
  final double? width;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        color: color,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          onTap: onTap,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppSizes.paddingMedium),
            child: child,
          ),
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(value,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                if (subtitle != null)
                  Text(subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
