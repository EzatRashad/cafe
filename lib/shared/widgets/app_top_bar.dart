import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/constants/app_constants.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';

class AppTopBar extends StatelessWidget {
  final bool showMenuButton;
  const AppTopBar({super.key, this.showMenuButton = false});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        final isDark = settings.isDark;
        return Container(
          height: AppSizes.appBarHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (showMenuButton)
                IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              const Spacer(),
              // Language switcher
              _LanguageButton(locale: context.locale.languageCode),
              const SizedBox(width: 8),
              // Theme toggle
              IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    key: ValueKey(isDark),
                    color: isDark ? AppColors.accent : AppColors.primary,
                  ),
                ),
                onPressed: () => context.read<SettingsCubit>().toggleTheme(),
                tooltip: isDark ? 'lightMode'.tr() : 'darkMode'.tr(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String locale;
  const _LanguageButton({required this.locale});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (lang) {
        context.read<SettingsCubit>().setLanguage(lang);
        context.setLocale(Locale(lang));
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'en', child: Text('🇬🇧 English')),
        const PopupMenuItem(value: 'ar', child: Text('🇸🇦 العربية')),
        const PopupMenuItem(value: 'bn', child: Text('🇧🇩 বাংলা')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_flag(locale), style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(_label(locale),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
      ),
    );
  }

  String _flag(String code) {
    switch (code) {
      case 'ar': return '🇸🇦';
      case 'bn': return '🇧🇩';
      default: return '🇬🇧';
    }
  }

  String _label(String code) {
    switch (code) {
      case 'ar': return 'عربي';
      case 'bn': return 'বাংলা';
      default: return 'EN';
    }
  }
}
