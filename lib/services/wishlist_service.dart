import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WishlistService {
  static const String _wishlistKey = 'wishlist_objects_v1';
  
  // Broadcasts wishlist updates directly to UI using ValueListenableBuilder
  static final ValueNotifier<List<Map<String, dynamic>>> wishlistNotifier = ValueNotifier([]);

  // Initialize wishlist from storage when the app loads
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> items = prefs.getStringList(_wishlistKey) ?? [];
    try {
      wishlistNotifier.value = items.map((e) => json.decode(e) as Map<String, dynamic>).toList();
    } catch (e) {
      // If corruption occurs during parse, reset
      wishlistNotifier.value = [];
    }
  }

  static Future<void> addToWishlist(Map<String, dynamic> product) async {
    final prefs = await SharedPreferences.getInstance();
    final currentList = List<Map<String, dynamic>>.from(wishlistNotifier.value);
    
    if (!currentList.any((p) => p['id'] == product['id'])) {
      currentList.add(product);
      wishlistNotifier.value = currentList;
      final encodedList = currentList.map((e) => json.encode(e)).toList();
      await prefs.setStringList(_wishlistKey, encodedList);
    }
  }

  static Future<void> removeFromWishlist(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final currentList = List<Map<String, dynamic>>.from(wishlistNotifier.value);
    
    currentList.removeWhere((p) => p['id'] == productId);
    wishlistNotifier.value = currentList;
    final encodedList = currentList.map((e) => json.encode(e)).toList();
    await prefs.setStringList(_wishlistKey, encodedList);
  }

  static Future<List<Map<String, dynamic>>> getWishlist() async {
    return wishlistNotifier.value;
  }

  static bool isInWishlist(String productId) {
    return wishlistNotifier.value.any((p) => p['id'] == productId);
  }
}
