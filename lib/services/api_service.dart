import 'dart:convert';
import 'package:woodnium/services/storage_service.dart';
import 'package:http/http.dart' as http;

class ApiService {

  // ---------------- SIGNUP ----------------
  Future<int> signupUser( String name, String email, String phone, String password) async {
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
        body: {
          'email': email,
          'password': password,
        },
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
      String id, String name, String email, String phone, String password) async {
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
        body: {
          'id': id,
        },
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
        body: {
          "user_id": userId,
          "product_id": productId,
        },
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
        Uri.parse('https://www.prakrutitech.xyz/abhay/c_wishlist_product_view.php?user_id=$userId'),
      );

      print("Wishlist View Response: ${resp.body}");

      if (resp.statusCode == 200) {
        return json.decode(resp.body);
      } else {
        return [];
      }
    } catch (e) {
      print("Wishlist View Error: $e");
      return [];
    }
  }
}