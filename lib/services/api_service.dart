import 'dart:convert';
import 'package:woodnium/services/storage_service.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://www.prakrutitech.xyz/abhay';

  // ---------------- SIGNUP ----------------
  Future<int> signupUser(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    try {
      var resp = await http.post(
        Uri.parse('https://www.prakrutitech.xyz/abhay/c_user_signup.php'),
        body: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        },
      );

      print("Signup Status Code: ${resp.statusCode}");
      print("Signup Response: ${resp.body}");

      if (resp.statusCode == 200) {
        // ✅ AUTO LOGIN AFTER SIGNUP
        await StorageService.setLoggedIn(true);
        await StorageService.setUserData(name, email);

        return 1;
      } else {
        return 0;
      }
    } catch (e) {
      print("Signup Error: $e");
      return 0;
    }
  }

  // ---------------- SIGNIN ----------------
  Future<dynamic> signinUser(String email, String password) async {
    try {
      var resp = await http.post(
        Uri.parse('https://www.prakrutitech.xyz/abhay/c_user_signin.php'),
        body: {'email': email, 'password': password},
      );

      print("Signin Status Code: ${resp.statusCode}");
      print("Signin Response: ${resp.body}");

      if (resp.statusCode == 200) {
        var data = json.decode(resp.body);

        if (data["status"] == 1) {
          return data["data"]; // full user data
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      print("Signin Error: $e");
      return null;
    }
  }

  // ---------------- UPDATE ----------------
  Future<int> updateUser(
    String id,
    String name,
    String email,
    String phone,
    String password,
  ) async {
    try {
      var resp = await http.post(
        Uri.parse('https://www.prakrutitech.xyz/abhay/c_user_update.php'),
        body: {
          'id': id,
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        },
      );

      print("Update Raw Response: ${resp.body}");

      if (resp.statusCode == 200) {
        if (resp.body.trim() == "1") {
          return 1;
        } else {
          print("Update Failed: ${resp.body}");
          return 0;
        }
      } else {
        return 0;
      }
    } catch (e) {
      print("Update Error: $e");
      return 0;
    }
  }

  // ---------------- DELETE ----------------
  Future<int> deleteUser(String id) async {
    try {
      print("Delete User ID: $id");

      var resp = await http.post(
        Uri.parse('https://www.prakrutitech.xyz/abhay/c_user_delete.php'),
        body: {'id': id},
      );

      print("Status Code: ${resp.statusCode}");
      print("Response Body: ${resp.body}");

      if (resp.statusCode == 200) {
        if (resp.body.trim() == "1") {
          return 1; // success
        } else {
          return 0; // failed
        }
      } else {
        return 0;
      }
    } catch (e) {
      print("Delete Error: $e");
      return 0;
    }
  }

  // ---------------- CATEGORIES ----------------
  Future<List<dynamic>> getCategories() async {
    try {
      var resp = await http.get(
        Uri.parse('https://www.prakrutitech.xyz/abhay/c_categories_view.php'),
      );

      print("Category Status Code: ${resp.statusCode}");
      print("Category Response: ${resp.body}");

      if (resp.statusCode == 200) {
        return json.decode(resp.body);
      } else {
        return [];
      }
    } catch (e) {
      print("Category Error: $e");
      return [];
    }
  }

  // ---------------- PRODUCTS ----------------
  Future<List<dynamic>> getProducts() async {
    try {
      var resp = await http.get(
        Uri.parse('https://www.prakrutitech.xyz/abhay/c_product_view.php'),
      );

      print("Product Status Code: ${resp.statusCode}");
      print("Product Response: ${resp.body}");

      if (resp.statusCode == 200) {
        return json.decode(resp.body);
      } else {
        return [];
      }
    } catch (e) {
      print("Product Error: $e");
      return [];
    }
  }

  // ---------------- WISHLIST ----------------
  Future<String> toggleWishlist(String userId, String productId) async {
    try {
      var resp = await http.post(
        Uri.parse('https://www.prakrutitech.xyz/abhay/c_wishlist_product.php'),
        body: {"user_id": userId, "product_id": productId},
      );

      print("Wishlist Response: ${resp.body}");

      if (resp.statusCode == 200) {
        return resp.body.trim(); // "add" or "delete"
      } else {
        return "error";
      }
    } catch (e) {
      print("Wishlist Error: $e");
      return "error";
    }
  }

  Future<List<dynamic>> getWishlist(String userId) async {
    try {
      var resp = await http.get(
        Uri.parse(
          'https://www.prakrutitech.xyz/abhay/c_wishlist_product_view.php?user_id=$userId',
        ),
      );

      print("Wishlist View Response: ${resp.body}");

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        return data is List ? data : [];
      } else {
        return [];
      }
    } catch (e) {
      print("Wishlist View Error: $e");
      return [];
    }
  }

  // ---------------- ENQUIRY NOW ----------------
  Future<String> addEnquiryNow({
    required String userId,
    required String productId,
    required String message,
  }) async {
    try {
      var resp = await http.post(
        Uri.parse('$_baseUrl/c_inquiry_create_user.php'),
        body: {'user_id': userId, 'product_id': productId, 'message': message},
      );

      print("Enquiry Status Code: ${resp.statusCode}");
      print("Enquiry Response: ${resp.body}");

      if (resp.statusCode != 200) {
        return "0";
      }

      final body = resp.body.trim();
      if (body == "1") {
        return "1";
      }

      try {
        final data = json.decode(body);
        if (data is Map && (data["status"] == 1 || data["success"] == true)) {
          return "1";
        }
      } catch (_) {}

      return body.isEmpty ? "0" : body;
    } catch (e) {
      print("Enquiry Error: $e");
      return "0";
    }
  }

  // ---------------- MY ENQUIRIES ----------------
  Future<List<dynamic>> getUserEnquiries(String userId) async {
    try {
      var resp = await http.get(
        Uri.parse('$_baseUrl/c_inquiry_view_user.php?user_id=$userId'),
      );

      print("My Enquiry Response: ${resp.body}");

      if (resp.statusCode == 200) {
        return json.decode(resp.body);
      } else {
        return [];
      }
    } catch (e) {
      print("My Enquiry Error: $e");
      return [];
    }
  }

  // ---------------- PRODUCT RATING ----------------
  Future<String> addProductRating({
    required String userId,
    required String productId,
    required String rating,
    required String feedback,
  }) async {
    try {
      var resp = await http.post(
        Uri.parse('$_baseUrl/c_rating_product_add.php'),
        body: {
          'user_id': userId,
          'product_id': productId,
          'rating': rating,
          'feedback': feedback,
        },
      );

      print("Rating Add Response: ${resp.body}");

      if (resp.statusCode == 200) {
        return resp.body.trim();
      } else {
        return "0";
      }
    } catch (e) {
      print("Rating Add Error: $e");
      return "0";
    }
  }

  Future<List<dynamic>> getProductRatings(String productId) async {
    try {
      var resp = await http.get(
        Uri.parse('$_baseUrl/c_rating_product_view.php?product_id=$productId'),
      );

      print("Rating View Response: ${resp.body}");

      if (resp.statusCode == 200) {
        return json.decode(resp.body);
      } else {
        return [];
      }
    } catch (e) {
      print("Rating View Error: $e");
      return [];
    }
  }
}
