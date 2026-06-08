import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_colors.dart';
import '../../widgets/product_card.dart';
import '../../services/api_service.dart';
import '../../models/product.dart';

class ProductScreen extends StatefulWidget {
  final String? categoryName;

  const ProductScreen({super.key, this.categoryName});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<Product> products = [];
  Set<String> wishlistedIds = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String userId = sp.getString("id") ?? "";

    var data = await ApiService().getProducts();
    var wData = await ApiService().getWishlist(userId);

    if (mounted) {
      setState(() {
        if (widget.categoryName != null && widget.categoryName!.isNotEmpty) {
          products = data
              .where((p) {
                print("Selected Category: ${widget.categoryName}");
                print("Product Category: ${p["category_name"]}");
                return (p["category_name"] ?? "")
                        .toString()
                        .toLowerCase()
                        .trim() ==
                    widget.categoryName!.toLowerCase().trim();
              })
              .map((e) => Product.fromJson(e))
              .toList();
        } else {
          products = data.map((e) => Product.fromJson(e)).toList();
        }
        wishlistedIds = wData.map((e) => e["id"].toString()).toSet();
        isLoading = false;
      });
    }
  }

  Future<void> _toggleWishlist(Product item) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String userId = sp.getString("id") ?? "";

    if (userId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login before wishlist")),
      );
      return;
    }

    final res = await ApiService().toggleWishlist(userId, item.id);
    final wData = await ApiService().getWishlist(userId);

    if (!mounted) return;
    setState(() {
      wishlistedIds = wData.map((e) => e["id"].toString()).toSet();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          res == "add"
              ? "Added to Wishlist"
              : res == "delete"
              ? "Removed from Wishlist"
              : "Wishlist update failed",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (products.isEmpty) {
      content = const Center(child: Text("No Products in this Category"));
    } else {
      content = ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _buildSectionTitle(
            widget.categoryName != null && widget.categoryName!.isNotEmpty
                ? widget.categoryName!
                : 'Featured Products',
          ),
          if (widget.categoryName != null && widget.categoryName!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text(
                "Total: ${products.length} items",
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(height: 16),
          _buildFeaturedProducts(context),
          const SizedBox(height: 32),
        ],
      );
    }

    if (widget.categoryName != null && widget.categoryName!.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.categoryName ?? "All Products")),
        body: content,
      );
    }

    return content;
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: AppColors.studioGradient,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.white, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppColors.walnut.withValues(alpha: 0.09),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: AppColors.woodGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.grid_view_rounded, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedProducts(BuildContext context) {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: Text("No products found")),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: products.length,
      itemBuilder: (context, index) {
        Product item = products[index];
        bool isWishlisted = wishlistedIds.contains(item.id);

        return ProductCard(
          product: item,
          isWishlisted: isWishlisted,
          onWishlistTap: () => _toggleWishlist(item),
          onCardTap: () async {
            // refresh wishlist
            SharedPreferences sp = await SharedPreferences.getInstance();
            String userId = sp.getString("id") ?? "";
            var wData = await ApiService().getWishlist(userId);
            if (mounted) {
              setState(() {
                wishlistedIds = wData.map((e) => e["id"].toString()).toSet();
              });
            }
          },
        );
      },
    );
  }
}
