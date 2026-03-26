import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/product_card.dart';
import '../../services/wishlist_service.dart';
import '../../services/enquiry_service.dart';
import '../bottom_nav_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        _buildBannerCarousel(),
        const SizedBox(height: 24),
        _buildSearchBar(),
        const SizedBox(height: 24),
        _buildSectionTitle('Featured Products'),
        const SizedBox(height: 16),
        _buildFeaturedProducts(context),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const TextField(
          decoration: InputDecoration(
            hintText: 'Search furniture...',
            hintStyle: TextStyle(color: Colors.grey),
            prefixIcon: Icon(Icons.search, color: AppColors.accent),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildBannerCarousel() {
    final List<String> bannerImages = [
      'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1592078615290-033ee584e267?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=800&q=80',
    ];

    return CarouselSlider(
      options: CarouselOptions(
        height: 180,
        enlargeCenterPage: true,
        autoPlay: true,
        aspectRatio: 16 / 9,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        viewportFraction: 0.85,
      ),
      items: bannerImages.map((imageUrl) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

  Widget _buildFeaturedProducts(BuildContext context) {
    final products = [
      {
        'id': 'featured_1',
        'name': 'Modern Oak Chair',
        'price': '₹120',
        'image': 'https://images.unsplash.com/photo-1592078615290-033ee584e267?auto=format&fit=crop&w=400&q=80',
      },
      {
        'id': 'featured_2',
        'name': 'Classic Wood Table',
        'price': '₹350',
        'image': 'https://images.unsplash.com/photo-1533090481720-856c6e3c1fdc?auto=format&fit=crop&w=400&q=80',
      },
      {
        'id': 'featured_3',
        'name': 'Leather Sofa set',
        'price': '₹890',
        'image': 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?auto=format&fit=crop&w=400&q=80',
      },
      {
        'id': 'featured_4',
        'name': 'King Size Bed',
        'price': '₹550',
        'image': 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=400&q=80',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: WishlistService.wishlistNotifier,
        builder: (context, wishlist, _) {
          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.65,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final isWishlisted = WishlistService.isInWishlist(product['id']!);
              return ProductCard(
                image: product['image']!,
                title: product['name']!,
                price: product['price']!,
                isWishlisted: isWishlisted,
                onWishlistTap: () {
                  if (isWishlisted) {
                    WishlistService.removeFromWishlist(product['id']!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Removed from Wishlist')),
                    );
                  } else {
                    WishlistService.addToWishlist(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added to Wishlist')),
                    );
                  }
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
          );
        },
      ),
    );
  }