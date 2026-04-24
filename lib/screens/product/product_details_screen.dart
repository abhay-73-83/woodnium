import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Map product;
  final bool initialWishlisted;

  const ProductDetailsScreen({super.key, required this.product, this.initialWishlisted = false});

  @override
  Widget build(BuildContext context) {
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
