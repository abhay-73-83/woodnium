import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_colors.dart';
import '../../widgets/product_card.dart';
import '../../services/api_service.dart';
import '../../models/product.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => WishlistScreenState();
}

class WishlistScreenState extends State<WishlistScreen> {
  List<Product> wishlist = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadWishlist();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadWishlist(); // reload every time screen comes
  }

  Future<void> loadWishlist() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    SharedPreferences sp = await SharedPreferences.getInstance();
    String userId = sp.getString("id") ?? "";

    var data = await ApiService().getWishlist(userId);

    if (mounted) {
      setState(() {
        wishlist = data.map((e) => Product.fromJson(e)).toList();
        isLoading = false;
      });
    }
    print("Wishlist Reloaded");
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
              'No Wishlist Items ❤️',
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

    return RefreshIndicator(
      onRefresh: loadWishlist,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: wishlist.length,
        itemBuilder: (context, index) {
          Product item = wishlist[index];

        return ProductCard(
          product: item,
          isWishlisted: true, // Always true in wishlist
          onWishlistTap: () {
            setState(() {
              wishlist.removeWhere((p) => p.id == item.id);
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Removed from Wishlist")),
              );
            }
          },
          onCardTap: () {
            loadWishlist(); // refresh if changed inside details
          },
        );
      },
    ));
  }
}
