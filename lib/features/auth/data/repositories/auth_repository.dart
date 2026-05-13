import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/database_helper.dart';

abstract class AuthRepository {
  Future<bool> hasPassword();
  Future<void> createPassword(String password);
  Future<bool> verifyPassword(String password);
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<void> setRememberMe(bool value);
  Future<bool> getRememberMe();
}

class AuthRepositoryImpl implements AuthRepository {
  final DatabaseHelper _db;

  AuthRepositoryImpl(this._db);

  String _hash(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  @override
  Future<bool> hasPassword() async {
    final auth = await _db.getAuth();
    return auth != null;
  }

  @override
  Future<void> createPassword(String password) async {
    await _db.upsertAuth(_hash(password));
  }

  @override
  Future<bool> verifyPassword(String password) async {
    final auth = await _db.getAuth();
    if (auth == null) return false;
    final matches = auth['password_hash'] == _hash(password);
    if (matches) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppStrings.prefLoggedInKey, true);
    }
    return matches;
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppStrings.prefLoggedInKey);
    await prefs.remove(AppStrings.prefRememberKey);
  }

  @override
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppStrings.prefLoggedInKey) ?? false;
  }

  @override
  Future<void> setRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppStrings.prefRememberKey, value);
  }

  @override
  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppStrings.prefRememberKey) ?? false;
  }
}
