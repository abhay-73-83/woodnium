import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_colors.dart';
import '../../services/api_service.dart';
import '../enquiry/enquiry_screen.dart';
import '../../models/product.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  final bool initialWishlisted;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    this.initialWishlisted = false,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool isWishlisted = false;
  int currentIndex = 0;
  int selectedRating = 0;
  bool isRatingSubmitting = false;
  bool isRatingsLoading = false;
  List<dynamic> ratings = [];
  final TextEditingController feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isWishlisted = widget.initialWishlisted;
    checkWishlist();
    loadRatings();
  }

  @override
  void dispose() {
    feedbackController.dispose();
    super.dispose();
  }

  Future<void> checkWishlist() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String userId = sp.getString("id") ?? "";
    var wishlist = await ApiService().getWishlist(userId);
    if (mounted) {
      setState(() {
        isWishlisted = wishlist.any(
          (item) => item["id"].toString() == widget.product.id,
        );
      });
    }
  }

  Future<void> loadRatings() async {
    setState(() => isRatingsLoading = true);
    final data = await ApiService().getProductRatings(widget.product.id);

    if (!mounted) return;
    setState(() {
      ratings = data;
      isRatingsLoading = false;
    });
  }

  Future<void> submitRating() async {
    if (selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select rating"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter feedback"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    SharedPreferences sp = await SharedPreferences.getInstance();
    String userId = sp.getString("id") ?? "";

    if (!mounted) return;
    setState(() => isRatingSubmitting = true);

    final res = await ApiService().addProductRating(
      userId: userId,
      productId: widget.product.id,
      rating: selectedRating.toString(),
      feedback: feedbackController.text.trim(),
    );

    if (!mounted) return;
    setState(() => isRatingSubmitting = false);

    if (res == "1") {
      feedbackController.clear();
      setState(() => selectedRating = 0);
      await loadRatings();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Rating added successfully"),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res == "Already Rated" ? "Already rated" : "Rating failed",
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    List<String> images = product.images;

    double topHeight = MediaQuery.of(context).size.height * 0.45;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. IMAGE SLIDER (TOP)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topHeight + 30, // Extra height for curve overlap
            child: images.isNotEmpty
                ? Stack(
                    children: [
                      PageView.builder(
                        itemCount: images.length,
                        onPageChanged: (index) {
                          setState(() {
                            currentIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Hero(
                            tag: product.id + index.toString(),
                            child: Image.network(
                              images[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                print("IMAGE LOAD FAILED => ${images[index]}");
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: Icon(Icons.broken_image, size: 40),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                      if (images.length > 1)
                        Positioned(
                          bottom: 40,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(images.length, (index) {
                              return Container(
                                margin: const EdgeInsets.all(4),
                                width: currentIndex == index ? 10 : 6,
                                height: currentIndex == index ? 10 : 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: currentIndex == index
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              );
                            }),
                          ),
                        ),
                    ],
                  )
                : Container(
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.image, size: 50)),
                  ),
          ),

          // 2. TOP OVERLAY (BACK + WISHLIST)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // BACK BUTTON
                CircleAvatar(
                  backgroundColor: AppColors.surface.withValues(alpha: 0.94),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // ❤️ WISHLIST
                CircleAvatar(
                  backgroundColor: AppColors.surface.withValues(alpha: 0.94),
                  child: IconButton(
                    icon: Icon(
                      isWishlisted ? Icons.favorite : Icons.favorite_border,
                      color: isWishlisted
                          ? AppColors.copper
                          : AppColors.graphite,
                    ),
                    onPressed: () async {
                      SharedPreferences sp =
                          await SharedPreferences.getInstance();
                      String userId = sp.getString("id") ?? "";
                      if (userId.isEmpty) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please login before wishlist"),
                          ),
                        );
                        return;
                      }

                      var res = await ApiService().toggleWishlist(
                        userId,
                        product.id,
                      );
                      if (!context.mounted) return;
                      if (res == "add" || res == "delete") {
                        setState(() {
                          isWishlisted = res == "add";
                        });
                      }
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
                    },
                  ),
                ),
              ],
            ),
          ),

          // 3. DETAILS CONTAINER (BOTTOM CURVE)
          Positioned(
            top: topHeight,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 30, left: 24, right: 24),
              decoration: BoxDecoration(
                gradient: AppColors.aluminiumGradient,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(34),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 24,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 5. TITLE + PRICE
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          "₹ ${product.price}",
                          style: const TextStyle(
                            fontSize: 22,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 6. CATEGORY TAG
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.softWoodGradient,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Text(
                        product.categoryName,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 7. DESCRIPTION
                    const Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.5,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 8. FEATURES (PREMIUM STYLE)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _feature(Icons.chair, "Comfort"),
                        _feature(Icons.verified, "Quality"),
                        _feature(Icons.security, "Warranty"),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // 9. EXTRA INFO SECTION
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppColors.studioGradient,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white, width: 1.2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Available Colors",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Row(
                            children: [
                              _colorDot(AppColors.primary),
                              _colorDot(AppColors.aluminiumDark),
                              _colorDot(AppColors.secondary),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    _ratingSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // 10. STICKY ENQUIRY BUTTON
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.emberGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.copper.withValues(alpha: 0.2),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Bulk Orders & Customization",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Get tailored solutions",
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.graphite,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
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
                  "Inquiry Now",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _feature(IconData icon, String text) {
    return Column(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: AppColors.aluminium.withValues(alpha: 0.35),
          child: Icon(icon, color: AppColors.walnut),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _colorDot(Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
    );
  }

  Widget _ratingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Ratings & Reviews",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.studioGradient,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: List.generate(5, (index) {
                  final ratingValue = index + 1;
                  return IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    onPressed: () {
                      setState(() => selectedRating = ratingValue);
                    },
                    icon: Icon(
                      ratingValue <= selectedRating
                          ? Icons.star
                          : Icons.star_border,
                      color: AppColors.copper,
                      size: 30,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: feedbackController,
                minLines: 3,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Write your feedback",
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isRatingSubmitting ? null : submitRating,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: isRatingSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "SUBMIT REVIEW",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (isRatingsLoading)
          const Center(child: CircularProgressIndicator())
        else if (ratings.isEmpty)
          const Text(
            "No reviews yet",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          )
        else
          Column(
            children: ratings.map((item) {
              return _reviewCard(item as Map<String, dynamic>);
            }).toList(),
          ),
      ],
    );
  }

  Widget _reviewCard(Map<String, dynamic> item) {
    final rating = int.tryParse(item["rating"]?.toString() ?? "0") ?? 0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: AppColors.aluminiumGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.secondary.withValues(alpha: 0.25),
                child: const Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item["user_name"]?.toString() ?? "User",
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: AppColors.copper,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item["feedback"]?.toString() ?? "",
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item["created_at"]?.toString() ?? "",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
