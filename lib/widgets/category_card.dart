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
    String img = (image ?? "").replaceAll("\\/", "/");
    // print("CATEGORY IMAGE URL => " + img);

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
            child: img.isEmpty
              ? Container(
                  height: 80,
                  width: 80,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image_not_supported),
                )
              : Image.network(
                  img,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // print("FAILED CATEGORY IMAGE => $img");
                    return Container(
                      height: 80,
                      width: 80,
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image, size: 40),
                    );
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
