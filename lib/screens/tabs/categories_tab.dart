import 'package:flutter/material.dart';
import '../../widgets/category_item.dart';
import '../placeholder_screen.dart';

class CategoriesTab extends StatelessWidget {
  const CategoriesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'icon': Icons.chair_alt, 'name': 'Chair'},
      {'icon': Icons.table_restaurant, 'name': 'Table'},
      {'icon': Icons.bed, 'name': 'Bed'},
      {'icon': Icons.weekend, 'name': 'Sofa'},
      {'icon': Icons.door_sliding, 'name': 'Cupboard'},
      {'icon': Icons.light, 'name': 'Lighting'},
      {'icon': Icons.deck, 'name': 'Outdoor'},
      {'icon': Icons.desk, 'name': 'Desk'},
      {'icon': Icons.crib, 'name': 'Kids'},
    ];

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
          final cat = categories[index];
          return CategoryItem(
            icon: cat['icon'] as IconData,
            name: cat['name'] as String,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlaceholderScreen(title: cat['name'] as String),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
