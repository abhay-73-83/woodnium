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
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.studioGradient,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppColors.walnut.withValues(alpha: 0.09),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        gradient: AppColors.woodGradient,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: AppColors.linen,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 1.2),
                      ),
                      child: img.isEmpty
                          ? const Icon(
                              Icons.image_not_supported,
                              color: AppColors.aluminiumDark,
                            )
                          : Image.network(
                              img,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 34,
                                    color: AppColors.aluminiumDark,
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
