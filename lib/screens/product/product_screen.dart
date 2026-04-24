import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../utils/app_colors.dart';
import '../../services/api_service.dart';
import 'product_details_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List products = [];
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
        products = data;
        wishlistedIds = wData.map((e) => e["id"].toString()).toSet();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (products.isEmpty) {
      return const Center(child: Text("No Products Found"));
    }

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

  Widget _buildFeaturedProducts(BuildContext context) {
    String baseImageUrl = "https://www.prakrutitech.xyz/abhay/uploads/";
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: products.length,
      itemBuilder: (context, index) {
        var item = products[index];
        bool isWishlisted = wishlistedIds.contains(item["id"].toString());

        String finalImageUrl = "";
        var imgObj = item["image"] ?? item["icon"];
        if (imgObj != null && imgObj.toString().isNotEmpty) {
          String img = imgObj.toString();
          if (img.startsWith('["') && img.endsWith('"]')) {
            img = img.substring(2, img.length - 2).replaceAll('\\/', '/');
          }
          finalImageUrl = img.startsWith('http') ? img : baseImageUrl + img;
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(8),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: (finalImageUrl.isEmpty)
                ? const Icon(Icons.image, size: 80)
                : Image.network(
                    finalImageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image);
                    },
                  ),
            ),
            title: Text(
              item["name"]?.toString() ?? "",
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            subtitle: Text(
              "₹ ${item["price"]}",
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
            trailing: StatefulBuilder(
              builder: (context, setLocalState) {
                return IconButton(
                  icon: Icon(
                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                    color: isWishlisted ? AppColors.primary : Colors.grey,
                  ),
                  onPressed: () async {
                    SharedPreferences sp = await SharedPreferences.getInstance();
                    String userId = sp.getString("id") ?? "";

                    var res = await ApiService().toggleWishlist(userId, item["id"].toString());

                    if (context.mounted) {
                      if (res == "add") {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Added to Wishlist")));
                        wishlistedIds.add(item["id"].toString());
                      } else if (res == "delete") {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Removed from Wishlist")));
                        wishlistedIds.remove(item["id"].toString());
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error")));
                      }
                      setState(() {}); // refresh product UI
                    }
                  },
                );
              }
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailsScreen(product: item),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
