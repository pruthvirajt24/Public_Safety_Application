import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

class MySharedPrefernces {
  static SharedPreferences? _preferences;
  static const String key = 'userType';

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future<void> userSaveType(String userType) async {
    await _preferences!.setString(key, userType);
  }

  static Future<String?> getUserType() async {
    return _preferences!.getString(key);
  }

  // To handle user data coming from firebase
  // starts-
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userData.forEach((key, value) async {
      await prefs.setString(key, value);
    });
    log("User data saved");
  }

  Future<Map<String, dynamic>> getUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get all keys in SharedPreferences
    final Set<String> keys = prefs.getKeys();

    // Initialize an empty map to store retrieved data
    Map<String, String> userData = {};

    // Iterate through keys and retrieve their corresponding values
    for (String key in keys) {
      String? value = prefs.getString(key);
      if (value != null) {
        userData[key] = value;
      }
    }

    log("User data retrieved");
    return userData;
  }

  // Delete User Data
  Future<void> deleteUserData(Map<String, dynamic> userData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userData.forEach((key, value) async {
      await prefs.remove(key);
    });
    log("User data deleted");
  }

  //ends^
}
