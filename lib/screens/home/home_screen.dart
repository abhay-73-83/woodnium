import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/drawer_widget.dart';
import '../../services/api_service.dart';
import '../product/product_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    var data = await ApiService().getProducts();

    if (mounted) {
      setState(() {
        products = data;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('WoodNium'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
        ],
      ),
      drawer: const DrawerWidget(),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : (products.isEmpty 
            ? const Center(child: Text("No Products Found"))
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildBannerCarousel(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Categories'),
                    const SizedBox(height: 16),
                    _buildCategories(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Featured Products'),
                    const SizedBox(height: 16),
                    _buildFeaturedProducts(),
                    const SizedBox(height: 32),
                  ],
                ),
              )),
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
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(16),
                alignment: Alignment.bottomLeft,
                child: const Text(
                  'Premium Collection',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildCategories() {
    final categories = [
      {'icon': Icons.chair_alt, 'name': 'Chair'},
      {'icon': Icons.table_restaurant, 'name': 'Table'},
      {'icon': Icons.bed, 'name': 'Bed'},
      {'icon': Icons.weekend, 'name': 'Sofa'},
      {'icon': Icons.door_sliding, 'name': 'Cupboard'},
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 64,
                width: 64,
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
                child: Icon(
                  cat['icon'] as IconData,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                cat['name'] as String,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFeaturedProducts() {
    String baseImageUrl = "https://www.prakrutitech.xyz/abhay/uploads/";
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: products.length,
      itemBuilder: (context, index) {
        var item = products[index];
        bool isWishlisted = false;

        String finalImageUrl = "";
        var imgObj = item["image"] ?? item["icon"];
        if (imgObj != null && imgObj.toString().isNotEmpty) {
          String img = imgObj.toString();
          if (img.startsWith('["') && img.endsWith('"]')) {
            img = img.substring(2, img.length - 2).replaceAll('\\/', '/');
          }
          finalImageUrl = img.startsWith('http') ? img : baseImageUrl + img;
        }

        print("Image URL: " + finalImageUrl);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(8),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: (finalImageUrl.isEmpty)
                ? const Icon(Icons.image, size: 60)
                : Image.network(
                    finalImageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image, size: 60),
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
              builder: (context, setState) {
                return IconButton(
                  icon: Icon(
                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                    color: isWishlisted ? Colors.red : Colors.grey,
                  ),
                  onPressed: () async {
                    SharedPreferences sp = await SharedPreferences.getInstance();
                    String userId = sp.getString("id") ?? "";

                    var res = await ApiService().toggleWishlist(userId, item["id"].toString());

                    if (context.mounted) {
                      if (res == "add") {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Added to Wishlist")));
                        setState(() => isWishlisted = true);
                      } else if (res == "delete") {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Removed from Wishlist")));
                        setState(() => isWishlisted = false);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error")));
                      }
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