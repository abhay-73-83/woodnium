import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CategoryCard extends StatelessWidget {
  final IconData icon;
  final String name;
  final VoidCallback onTap;
  final String? image;

  const CategoryCard({
    super.key,
    required this.icon,
    required this.name,
    required this.onTap,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    String baseImageUrl = "https://www.prakrutitech.xyz/abhay/uploads/";
    String finalImageUrl = "";
    if (image != null && image!.isNotEmpty) {
      String img = image!;
      if (img.startsWith('["') && img.endsWith('"]')) {
        img = img.substring(2, img.length - 2).replaceAll('\\/', '/');
      }
      finalImageUrl = img.startsWith('http') ? img : baseImageUrl + img;
    }

    if (finalImageUrl.isNotEmpty) {
      print("Image URL: " + finalImageUrl);
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 80,
            width: 80,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: (finalImageUrl.isEmpty)
              ? Icon(
                  Icons.image,
                  color: AppColors.primary,
                  size: 32,
                )
              : Image.network(
                  finalImageUrl,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported);
                  },
                ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
