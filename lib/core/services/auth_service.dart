import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../database/database_helper.dart';

class AuthService {
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserRole = 'user_role';

  static Future<bool> saveUserSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, user.id!);
    await prefs.setString(_keyUserName, user.name);
    await prefs.setString(_keyUserEmail, user.email);
    await prefs.setString(_keyUserRole, user.role);
    return true;
  }

  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_keyUserId);
    if (id == null) return null;

    return User(
      id: id,
      name: prefs.getString(_keyUserName) ?? '',
      email: prefs.getString(_keyUserEmail) ?? '',
      password: '', // Do not store password in plain text/shared prefs generally
      role: prefs.getString(_keyUserRole) ?? 'user',
    );
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserRole);
  }

  static Future<User?> login(String email, String password) async {
    final user = await DatabaseHelper.instance.login(email, password);
    if (user != null) {
      await saveUserSession(user);
    }
    return user;
  }

  static Future<User?> register(String name, String email, String password) async {
    final user = User(
      name: name,
      email: email,
      password: password,
      role: 'user', // Default role for new signups
    );
    final registeredUser = await DatabaseHelper.instance.register(user);
    if (registeredUser != null) {
      await saveUserSession(registeredUser);
    }
    return registeredUser;
  }
}
