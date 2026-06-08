import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../screens/product/product_details_screen.dart';
import '../screens/enquiry/enquiry_screen.dart';
import '../models/product.dart';

class ProductGridCard extends StatelessWidget {
  final Product product;
  final bool isWishlisted;
  final VoidCallback onWishlistTap;
  final VoidCallback onCardTap;

  const ProductGridCard({
    super.key,
    required this.product,
    required this.isWishlisted,
    required this.onWishlistTap,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    String displayImage = "";
    if (product.images.isNotEmpty) {
      displayImage = product.images[0];
    }

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.aluminiumGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.walnut.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailsScreen(
                  product: product,
                  initialWishlisted: isWishlisted,
                ),
              ),
            );
            onCardTap();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// IMAGE SECTION
              Stack(
                children: [
                  Hero(
                    tag: product.id + "grid",
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      child: displayImage.isEmpty
                          ? Container(
                              height: 154,
                              width: double.infinity,
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            )
                          : Image.network(
                              displayImage,
                              height: 154,
                              width: double.infinity,
                              fit: BoxFit.cover,

                              /// loading
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;

                                return Container(
                                  height: 154,
                                  alignment: Alignment.center,
                                  child: const CircularProgressIndicator(),
                                );
                              },

                              /// error
                              errorBuilder: (context, error, stackTrace) {
                                print("IMAGE LOAD FAILED => $displayImage");
                                return Container(
                                  height: 154,
                                  color: Colors.grey.shade200,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 40,
                                  ),
                                );
                              },
                            ),
                    ),
                  ),

                  /// gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(34),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.primary.withValues(alpha: 0.28),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: AppColors.surface.withValues(alpha: 0.96),
                      shape: const CircleBorder(),
                      elevation: 2,
                      child: IconButton(
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(
                          minWidth: 34,
                          minHeight: 34,
                        ),
                        onPressed: onWishlistTap,
                        icon: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                          color: isWishlisted
                              ? AppColors.copper
                              : AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              /// DETAILS
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.categoryName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.walnut,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.copper,
                          size: 15,
                        ),
                        const SizedBox(width: 2),
                        const Text(
                          "4.8",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    Text(
                      "₹ ${product.price}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// enquiry button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: AppColors.woodGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.copper.withValues(alpha: 0.16),
                            blurRadius: 12,
                            offset: const Offset(0, 7),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EnquiryScreen(product: product),
                            ),
                          );
                        },
                        child: const Text(
                          "Enquiry Now",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
