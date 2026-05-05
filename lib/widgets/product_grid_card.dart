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
    
    print("IMAGES => ${product.images}");
    print("DISPLAY IMAGE => $displayImage");

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
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
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: displayImage.isEmpty
                          ? Container(
                        height: 140,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      )
                          : Image.network(
                        displayImage,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,

                        /// loading
                        loadingBuilder:
                            (context, child, progress) {
                          if (progress == null) return child;

                          return Container(
                            height: 140,
                            alignment: Alignment.center,
                            child:
                            const CircularProgressIndicator(),
                          );
                        },

                        /// error
                        errorBuilder:
                            (context, error, stackTrace) {
                          print("IMAGE LOAD FAILED => $displayImage");
                          return Container(
                            height: 140,
                            color: Colors.grey.shade200,
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image, size: 40),
                          );
                        },
                      ),
                    ),
                  ),

                  /// gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                        const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              /// DETAILS
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "₹ ${product.price}",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// enquiry button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF8B5E3C),
                            Color(0xFFB98050),
                          ],
                        ),
                      ),
                      child: ElevatedButton(
                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                          Colors.transparent,
                          shadowColor:
                          Colors.transparent,
                          padding:
                          const EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize:
                          MaterialTapTargetSize
                              .shrinkWrap,
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                              20,
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const EnquiryScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Enquiry Now",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                            FontWeight.bold,
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