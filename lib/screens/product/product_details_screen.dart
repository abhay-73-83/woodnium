import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_colors.dart';
import '../../services/api_service.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Map product;
  final bool initialWishlisted;

  const ProductDetailsScreen({super.key, required this.product, this.initialWishlisted = false});

  @override
  Widget build(BuildContext context) {
    bool isWishlisted = initialWishlisted;
    String baseImageUrl = "https://www.prakrutitech.xyz/abhay/uploads/";
    
    String finalImageUrl = "";
    var imgObj = product["image"] ?? product["icon"];
    if (imgObj != null && imgObj.toString().isNotEmpty) {
      String img = imgObj.toString();
      if (img.startsWith('["') && img.endsWith('"]')) {
        img = img.substring(2, img.length - 2).replaceAll('\\\/', '/');
      }
      finalImageUrl = img.startsWith('http') ? img : baseImageUrl + img;
    }

    if (finalImageUrl.isNotEmpty) {
      print("Image URL: " + finalImageUrl);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(product["name"]?.toString() ?? "Product Details"),
        actions: [
          StatefulBuilder(
            builder: (context, setState) {
              return IconButton(
                icon: Icon(
                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                  color: isWishlisted ? AppColors.primary : Colors.grey,
                ),
                onPressed: () async {
                  SharedPreferences sp = await SharedPreferences.getInstance();
                  String userId = sp.getString("id") ?? "";

                  var res = await ApiService().toggleWishlist(userId, product["id"].toString());

                  if (context.mounted) {
                    if (res == "add") {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Added to Wishlist")));
                      setState(() => isWishlisted = true);
                    } else if (res == "delete") {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Removed from Wishlist")));
                      setState(() => isWishlisted = false);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error")));
                    }
                  }
                },
              );
            }
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (finalImageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  finalImageUrl,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => const SizedBox(
                    height: 250,
                    child: Center(child: Icon(Icons.broken_image, size: 50)),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              product["name"]?.toString() ?? "",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Price: ₹ ${product["price"]}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Category: ${product["category_name"] ?? ""}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.accent,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Description",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product["description"]?.toString() ?? "",
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
