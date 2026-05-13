import 'dart:convert';
import '../di/service_locator.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';

class LocalizationHelper {
  static String getLocalizedName(String rawName) {
    if (rawName.isEmpty) return rawName;
    try {
      final Map<String, dynamic> map = jsonDecode(rawName);
      final lang = sl<SettingsCubit>().state.locale.languageCode;
      return map[lang] ?? map['en'] ?? rawName;
    } catch (_) {
      // If it's not a valid JSON string, it's just a regular old DB entry (fallback)
      return rawName;
    }
  }

  static String encodeNames({required String en, required String ar, required String bn}) {
    return jsonEncode({
      'en': en.trim(),
      'ar': ar.trim(),
      'bn': bn.trim(),
    });
  }

  static Map<String, String> decodeNames(String rawName) {
    try {
      final Map<String, dynamic> map = jsonDecode(rawName);
      return {
        'en': map['en'] ?? '',
        'ar': map['ar'] ?? '',
        'bn': map['bn'] ?? '',
      };
    } catch (_) {
      return {
        'en': rawName,
        'ar': '',
        'bn': '',
      };
    }
  }
}
