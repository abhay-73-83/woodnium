import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../services/wishlist_service.dart';
import '../../services/enquiry_service.dart';
import '../../widgets/product_card.dart';
import '../bottom_nav_screen.dart';

class WishlistTab extends StatelessWidget {
  const WishlistTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: WishlistService.wishlistNotifier,
      builder: (context, wishlist, child) {
        if (wishlist.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border_rounded,
                  size: 100,
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 24),
                const Text(
                  'No items in wishlist',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Start adding your favorite furniture',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(20),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.65,
            ),
            itemCount: wishlist.length,
            itemBuilder: (context, index) {
              final product = wishlist[index];
              return ProductCard(
                image: product['image']!,
                title: product['name']!,
                price: product['price']!,
                isWishlisted: true,
                onWishlistTap: () {
                  WishlistService.removeFromWishlist(product['id']!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Removed from Wishlist')),
                  );
                },
                onEnquiryTap: () async {
                  await Future.delayed(const Duration(milliseconds: 600));
                  await EnquiryService.addEnquiry(product);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enquiry Added Successfully', style: TextStyle(color: Colors.white)), backgroundColor: AppColors.success),
                  );
                  BottomNavScreen.tabNotifier.value = 3;
                },
              );
            },
          ),
        );
      },
    );
  }
}
