import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../utils/app_colors.dart';
import '../../widgets/drawer_widget.dart';
import '../../widgets/product_grid_card.dart';
import '../../services/api_service.dart';
import '../../models/product.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> products = [];
  Set<String> wishlistedIds = {};
  bool isLoading = true;
  String searchText = "";
  String appBarTitle = "WoodNium";

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    var data = await ApiService().getProducts();

    SharedPreferences sp = await SharedPreferences.getInstance();
    String userId = sp.getString("id") ?? "";
    String username = sp.getString("name") ?? "";
    var wData = await ApiService().getWishlist(userId);

    if (mounted) {
      setState(() {
        products = data.map((e) => Product.fromJson(e)).toList();
        wishlistedIds = wData.map((e) => e["id"].toString()).toSet();
        appBarTitle = username.isNotEmpty ? "Hello, $username..." : "WoodNium";
        isLoading = false;
      });
    }
  }

  Future<void> refreshWishlist() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String userId = sp.getString("id") ?? "";
    var wData = await ApiService().getWishlist(userId);
    if (mounted) {
      setState(() {
        wishlistedIds = wData.map((e) => e["id"].toString()).toSet();
      });
    }
  }

  Future<void> toggleWishlist(Product item) async {
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
    await refreshWishlist();

    if (!mounted) return;
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(appBarTitle),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              gradient: AppColors.studioGradient,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white, width: 1),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.primary,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No new notifications')),
                );
              },
            ),
          ),
        ],
      ),
      drawer: const DrawerWidget(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchProducts,
              color: AppColors.primary,
              child: products.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: const Center(child: Text("No Products Found")),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeroHeader(),
                          _buildSearchBar(),
                          const SizedBox(height: 14),
                          _buildBannerCarousel(),
                          const SizedBox(height: 22),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Featured Products',
                                  style: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.woodGradient,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    "${products.length} items",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildFeaturedProducts(),
                        ],
                      ),
                    ),
            ),
    );
  }

  Widget _buildHeroHeader() {
    return SizedBox(
      height: 240,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            decoration: BoxDecoration(
              gradient: AppColors.studioGradient,
              borderRadius: BorderRadius.circular(34),
              border: Border.all(color: Colors.white, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.walnut.withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.74),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white),
                          ),
                          child: const Text(
                            "WOODNIUM CRAFT",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const SizedBox(
                          width: 214,
                          child: Text(
                            "Warm wood pieces for calm homes.",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 27,
                              height: 1.03,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _heroChip(Icons.forest_rounded, "Natural finish"),
                            const SizedBox(width: 8),
                            _heroChip(Icons.handyman_rounded, "Custom work"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 100),
              ],
            ),
          ),
          Positioned(
            right: 16,
            top: 26,
            child: Container(
              width: 124,
              height: 168,
              decoration: BoxDecoration(
                color: AppColors.paper,
                borderRadius: BorderRadius.circular(34),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.edge.withValues(alpha: 0.18),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 42,
            top: 58,
            child: Transform.rotate(
              angle: -0.12,
              child: Container(
                width: 84,
                height: 104,
                decoration: BoxDecoration(
                  gradient: AppColors.emberGradient,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.weekend_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
          ),
          Positioned(
            right: 24,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.edge.withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: const Text(
                "Crafted finish",
                style: TextStyle(
                  color: AppColors.graphite,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        gradient: AppColors.woodGradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.aluminiumGradient,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white),
          boxShadow: [
            BoxShadow(
              color: AppColors.graphite.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: TextField(
          onChanged: (val) {
            setState(() {
              searchText = val.toLowerCase();
            });
          },
          decoration: const InputDecoration(
            hintText: "Search wood, aluminium, modular...",
            prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
            suffixIcon: Icon(Icons.tune_rounded, color: AppColors.copper),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: EdgeInsets.symmetric(vertical: 16),
            border: InputBorder.none,
          ),
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
        height: 205,
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
                borderRadius: BorderRadius.circular(24),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.82),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(18),
                alignment: Alignment.bottomLeft,
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium Collection',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Curated pieces for warm, modern homes',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildFeaturedProducts() {
    List<Product> filteredProducts = products.where((p) {
      return p.name.toLowerCase().contains(searchText);
    }).toList();

    if (filteredProducts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            "No products found",
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return MasonryGridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(12),
      itemCount: filteredProducts.length,
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      itemBuilder: (context, index) {
        Product item = filteredProducts[index];
        bool isWishlisted = wishlistedIds.contains(item.id);

        return TweenAnimationBuilder(
          duration: const Duration(milliseconds: 400),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: child,
              ),
            );
          },
          child: ProductGridCard(
            product: item,
            isWishlisted: isWishlisted,
            onWishlistTap: () => toggleWishlist(item),
            onCardTap: refreshWishlist,
          ),
        );
      },
    );
  }
}
