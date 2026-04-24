import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class ProductCard extends StatelessWidget {
  final String image;
  final String title;
  final String price;
  final bool isWishlisted;
  final VoidCallback onWishlistTap;
  final Future<void> Function() onEnquiryTap;

  const ProductCard({
    super.key,
    required this.image,
    required this.title,
    required this.price,
    required this.isWishlisted,
    required this.onWishlistTap,
    required this.onEnquiryTap,
  });

  @override
  Widget build(BuildContext context) {
    String finalImageUrl = "";
    if (image.isNotEmpty) {
      String img = image;
      if (img.startsWith('["') && img.endsWith('"]')) {
        img = img.substring(2, img.length - 2).replaceAll('\\/', '/');
      }
      finalImageUrl = img.startsWith('http') ? img : "https://www.prakrutitech.xyz/abhay/uploads/" + img;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image and Wishlist Icon
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: (finalImageUrl.isEmpty)
                        ? const Icon(Icons.image, size: 80)
                        : Image.network(
                            finalImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.broken_image);
                            },
                          ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onWishlistTap,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                        child: Icon(
                          isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          key: ValueKey<bool>(isWishlisted),
                          size: 20,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: _EnquiryButton(onTap: onEnquiryTap),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EnquiryButton extends StatefulWidget {
  final Future<void> Function() onTap;

  const _EnquiryButton({required this.onTap});

  @override
  State<_EnquiryButton> createState() => _EnquiryButtonState();
}

class _EnquiryButtonState extends State<_EnquiryButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : () async {
        setState(() => _isLoading = true);
        await widget.onTap();
        if (mounted) setState(() => _isLoading = false);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: _isLoading
          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
          : const Text('Enquiry Now'),
    );
  }
}
