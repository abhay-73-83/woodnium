import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userNameKey = 'userName';
  static const String _userEmailKey = 'userEmail';
  static const String _userIdKey = 'userId';

  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, value);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<void> setUserData(String name, String email, [String? id]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userEmailKey, email);
    if (id != null)
    {
      print(id);
      await prefs.setString(_userIdKey, id);
    }
  }

  static Future<Map<String, String>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_userNameKey) ?? 'Guest User',
      'email': prefs.getString(_userEmailKey) ?? '',
      'id': prefs.getString(_userIdKey) ?? '',
    };
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // ✅ everything delete
  }

  static const String _wishlistKey = 'wishlist';

  static Future<List<String>> getWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_wishlistKey) ?? [];
  }

  static Future<bool> toggleWishlist(String productName) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_wishlistKey) ?? [];
    bool isAdded = false;
    if (list.contains(productName)) {
      list.remove(productName);
    } else {
      list.add(productName);
      isAdded = true;
    }
    await prefs.setStringList(_wishlistKey, list);
    return isAdded;
  }
}
