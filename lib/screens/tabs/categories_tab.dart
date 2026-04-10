import 'package:flutter/material.dart';
import '../../widgets/category_item.dart';
import '../placeholder_screen.dart';
import '../../services/api_service.dart';

class CategoriesTab extends StatefulWidget {
  const CategoriesTab({super.key});

  @override
  State<CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<CategoriesTab> {
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
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
          childAspectRatio: 0.8,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          var item = categories[index];
          return CategoryItem(
            icon: Icons.category,
            name: item['name']?.toString() ?? "",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlaceholderScreen(
                      title: item['name']?.toString() ?? ""),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
