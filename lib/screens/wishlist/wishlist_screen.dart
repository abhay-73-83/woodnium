import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_colors.dart';
import '../../services/api_service.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => WishlistScreenState();
}

class WishlistScreenState extends State<WishlistScreen> {
  List wishlist = [];
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
        wishlist = data;
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
              'No Wishlist Items',
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
          var item = wishlist[index];

        String finalImageUrl = "";
        var imgObj = item["image"] ?? item["icon"];
        if (imgObj != null && imgObj.toString().isNotEmpty) {
          String img = imgObj.toString();
          if (img.startsWith('["') && img.endsWith('"]')) {
            img = img.substring(2, img.length - 2).replaceAll('\\/', '/');
          }
          finalImageUrl = img.startsWith('http') ? img : "https://www.prakrutitech.xyz/abhay/uploads/" + img;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(8),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: finalImageUrl.isEmpty 
                  ? const Icon(Icons.image, size: 60)
                  : Image.network(
                      finalImageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 60),
                    ),
            ),
            title: Text(item["name"]?.toString() ?? ""),
            subtitle: Text("₹ ${item["price"]}"),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () async {
                SharedPreferences sp = await SharedPreferences.getInstance();
                String userId = sp.getString("id") ?? "";
                
                var res = await ApiService().toggleWishlist(userId, item["id"].toString());
                
                if (res == "delete") {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Removed from Wishlist")),
                    );
                    loadWishlist(); // reload after delete
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Error removing item")),
                    );
                  }
                }
              },
            ),
          ),
        );
      },
    ));
  }
}
