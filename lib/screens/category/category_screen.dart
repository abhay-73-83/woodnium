import 'package:flutter/material.dart';
import '../../widgets/category_card.dart';
import '../product/product_screen.dart';
import '../../services/api_service.dart';

import '../../utils/app_colors.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    var data = await ApiService().getCategories();

    if (mounted) {
      setState(() {
        categories = data;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (categories.isEmpty) {
      return const Center(child: Text("No Categories Found"));
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: RefreshIndicator(
        onRefresh: fetchCategories,
        color: AppColors.primary,
        child: GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            childAspectRatio: 0.8,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            var item = categories[index];
            return CategoryCard(
              icon: Icons.category,
              name: item['name']?.toString() ?? "",
              image: item['image']?.toString() ?? item['icon']?.toString(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductScreen(
                      categoryName: item['name']?.toString() ?? "",
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
