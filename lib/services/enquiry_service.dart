import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnquiryService {
  static const String _key = 'enquiries_objects_v1';
  static final ValueNotifier<List<Map<String, dynamic>>> enquiryNotifier = ValueNotifier([]);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(_key) ?? [];
    try {
      enquiryNotifier.value = items.map((e) => json.decode(e) as Map<String, dynamic>).toList();
    } catch (_) {
      enquiryNotifier.value = [];
    }
  }

  static Future<void> addEnquiry(Map<String, dynamic> product) async {
    final prefs = await SharedPreferences.getInstance();
    final currentList = List<Map<String, dynamic>>.from(enquiryNotifier.value);
    
    final String dateStr = _formatDate(DateTime.now());
    
    final newEnquiry = {
      ...product,
      'status': 'Pending',
      'date': dateStr,
      'enquiryId': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    currentList.insert(0, newEnquiry);
    enquiryNotifier.value = currentList;
    
    final encoded = currentList.map((e) => json.encode(e)).toList();
    await prefs.setStringList(_key, encoded);
  }

  static Future<void> removeEnquiry(String enquiryId) async {
    final prefs = await SharedPreferences.getInstance();
    final currentList = List<Map<String, dynamic>>.from(enquiryNotifier.value);
    
    currentList.removeWhere((p) => p['enquiryId'] == enquiryId);
    enquiryNotifier.value = currentList;
    
    final encoded = currentList.map((e) => json.encode(e)).toList();
    await prefs.setStringList(_key, encoded);
  }

  static String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }
}
