import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  // ====================
  // KEYS
  // ====================
  static const String _tokenKey = "token";
  static const String _roleKey = "role";
  static const String _userIdKey = "userID";
  static const String _usernameKey = "username";
  static const String _locCodeKey = "Loc_Code";
  // ====================
  // TOKEN
  // ====================
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // ====================
  // ROLE
  // ====================
  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role.toLowerCase().trim());
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  // ====================
  // USER ID
  // ====================
 static Future<void> saveUserID(String id) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_userIdKey, id);
}


  static Future<String?> getUserID() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_userIdKey);
}

  

  // ====================
  // USERNAME
  // ====================
  static Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }


// SAVE
static Future<void> saveLocationCode(String Loc_Code) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_locCodeKey, Loc_Code);
}

// GET
static Future<String?> getLocationCode() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_locCodeKey);
}
  // =================================================
  // 🔥 PROFILE IMAGE (ROLE + USERID BASED)
  // =================================================
  // Example keys:
  // profile_driver_12
  // profile_manager_5
  // profile_admin_1
  // profile_finance_9

  

  // ====================
  // LOGOUT (SAFE)
  // ====================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_userIdKey);
  }

  // ====================
  // FULL CLEAR (DANGEROUS)
  // ====================
  /// ⚠️ Clears EVERYTHING (including profile images)
  /// Use only for debugging or reset
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
