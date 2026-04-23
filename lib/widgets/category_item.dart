import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String name;
  final VoidCallback onTap;
  final String? image;

  const CategoryItem({
    super.key,
    required this.icon,
    required this.name,
    required this.onTap,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    String baseImageUrl = "https://www.prakrutitech.xyz/abhay/uploads/";
    if (image != null) {
      print("Image URL: " + baseImageUrl + (image ?? ""));
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
            child: (image == null || image == "")
              ? Icon(
                  Icons.image,
                  color: AppColors.primary,
                  size: 32,
                )
              : Image.network(
                  baseImageUrl + (image ?? ""),
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
