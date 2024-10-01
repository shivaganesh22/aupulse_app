import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyToken = 'email';

  // Store login details
  static Future<void> storeLoginDetails(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_keyToken, token);
  }

  // Retrieve login details
  static Future<String> getLoginDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken) ?? '';
    return token;
  }

  static Future<bool> isLogged() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyToken);
  }

  // Clear login details
  static Future<void> clearLoginDetails() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_keyToken);
  }
}
