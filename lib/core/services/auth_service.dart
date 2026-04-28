import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  static bool _isGoogleSignInInitialized = false;

  static Future<void> _initGoogleSignIn() async {
    if (!_isGoogleSignInInitialized) {
      await GoogleSignIn.instance.initialize(
        serverClientId: '652784232227-qht9r3d3ns3hd608rv1lgpjbbj9om84f.apps.googleusercontent.com',
      );
      _isGoogleSignInInitialized = true;
    }
  }

  static Future<User?> loginWithGoogle() async {
    try {
      await _initGoogleSignIn();
      
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();

      final String email = googleUser.email;
      final String name = googleUser.displayName ?? 'Google User';

      // Check if user already exists in SQLite
      User? localUser = await DatabaseHelper.instance.getUserByEmail(email);

      if (localUser == null) {
        // User doesn't exist, register them with a dummy password
        localUser = await register(name, email, 'google_login_dummy_password');
      } else {
        // User exists, just save session
        await saveUserSession(localUser);
      }

      return localUser;
    } catch (e) {
      print('Error logging in with Google: $e');
      return null;
    }
  }
}
