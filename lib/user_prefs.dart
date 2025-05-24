import 'package:shared_preferences/shared_preferences.dart';

class UserPrefs {
  static Future<void> saveUserNim(String nim) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_nim', nim);
  }

  static Future<String?> getUserNim() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_nim');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_nim');
  }
}
