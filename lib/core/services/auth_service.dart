import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyUserAge = 'user_age';
  static const String _keyUserDOB = 'user_dob';
  static const String _keyUserGender = 'user_gender';
  static const String _keyUserAddress = 'user_address';
  static const String _keyUserProfileImage = 'user_profile_image';

  static final ValueNotifier<User?> userNotifier = ValueNotifier<User?>(null);

  static Future<bool> saveUserSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, user.id!);
    await prefs.setString(_keyUserName, user.name);
    await prefs.setString(_keyUserEmail, user.email);
    await prefs.setString(_keyUserRole, user.role);
    if (user.phoneNumber != null)
      await prefs.setString(_keyUserPhone, user.phoneNumber!);
    if (user.age != null) await prefs.setInt(_keyUserAge, user.age!);
    if (user.dateOfBirth != null)
      await prefs.setString(_keyUserDOB, user.dateOfBirth!);
    if (user.gender != null)
      await prefs.setString(_keyUserGender, user.gender!);
    if (user.address != null)
      await prefs.setString(_keyUserAddress, user.address!);
    if (user.profileImageUrl != null)
      await prefs.setString(_keyUserProfileImage, user.profileImageUrl!);

    userNotifier.value = user;
    return true;
  }

  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_keyUserId);
    if (id == null) return null;

    final user = User(
      id: id,
      name: prefs.getString(_keyUserName) ?? '',
      email: prefs.getString(_keyUserEmail) ?? '',
      password: '',
      role: prefs.getString(_keyUserRole) ?? 'user',
      phoneNumber: prefs.getString(_keyUserPhone),
      age: prefs.getInt(_keyUserAge),
      dateOfBirth: prefs.getString(_keyUserDOB),
      gender: prefs.getString(_keyUserGender),
      address: prefs.getString(_keyUserAddress),
      profileImageUrl: prefs.getString(_keyUserProfileImage),
    );
    userNotifier.value = user;
    return user;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserRole);
    await prefs.remove(_keyUserPhone);
    await prefs.remove(_keyUserAge);
    await prefs.remove(_keyUserDOB);
    await prefs.remove(_keyUserGender);
    await prefs.remove(_keyUserAddress);
    await prefs.remove(_keyUserProfileImage);
    userNotifier.value = null;
  }

  static Future<User?> login(String email, String password) async {
    final user = await FirestoreService.instance.login(email, password);
    if (user != null) {
      await saveUserSession(user);
    }
    return user;
  }

  static Future<User?> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
    int? age,
    String? dateOfBirth,
    String? gender,
    String? address,
  }) async {
    final user = User(
      name: name,
      email: email,
      password: password,
      role: 'user',
      phoneNumber: phoneNumber,
      age: age,
      dateOfBirth: dateOfBirth,
      gender: gender,
      address: address,
    );
    final registeredUser = await FirestoreService.instance.register(user);
    if (registeredUser != null) {
      await saveUserSession(registeredUser);
    }
    return registeredUser;
  }

  static Future<void> updateProfile(User user) async {
    await FirestoreService.instance.updateUser(user);
    await saveUserSession(user);
  }

  static bool isProfileComplete(User user) {
    return user.phoneNumber != null &&
        user.dateOfBirth != null &&
        user.gender != null &&
        user.address != null;
  }

  static Future<void> changePassword(String userId, String newPassword) async {
    await FirestoreService.instance.updatePassword(userId, newPassword);
  }

  static bool _isGoogleSignInInitialized = false;

  static Future<void> _initGoogleSignIn() async {
    if (!_isGoogleSignInInitialized) {
      await GoogleSignIn.instance.initialize(
        serverClientId:
            '652784232227-qht9r3d3ns3hd608rv1lgpjbbj9om84f.apps.googleusercontent.com',
      );
      _isGoogleSignInInitialized = true;
    }
  }

  static Future<User?> loginWithGoogle() async {
    try {
      await _initGoogleSignIn();

      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance
          .authenticate();

      if (googleUser == null) return null;

      final String email = googleUser.email;
      final String name = googleUser.displayName ?? 'Google User';

      // Check if user already exists in Firestore
      User? existingUser = await FirestoreService.instance.getUserByEmail(
        email,
      );

      if (existingUser == null) {
        // User doesn't exist, register them with a dummy password
        existingUser = await register(
          name: name,
          email: email,
          password: 'google_login_dummy_password',
        );
      } else {
        // User exists, just save session
        await saveUserSession(existingUser);
      }

      return existingUser;
    } catch (e) {
      debugPrint('Error logging in with Google: $e');
      return null;
    }
  }
}
