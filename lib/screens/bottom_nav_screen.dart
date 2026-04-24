import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../utils/app_colors.dart';
import 'product/product_screen.dart';
import 'category/category_screen.dart';
import 'wishlist/wishlist_screen.dart';
import 'enquiry/enquiry_screen.dart';
import 'profile/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/wishlist_service.dart';
import '../services/enquiry_service.dart';

class BottomNavScreen extends StatefulWidget {
  static final ValueNotifier<int> tabNotifier = ValueNotifier(0);

  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _currentIndex = 0;
  bool _isVisible = true;

  final GlobalKey<WishlistScreenState> wishlistKey = GlobalKey();

  late final List<Widget> _tabs = [
    const ProductScreen(),
    const CategoryScreen(),
    WishlistScreen(key: wishlistKey),
    const EnquiryScreen(),
    const ProfileScreen(),
  ];

  String _appBarTitle = 'WoodNium';

  @override
  void initState() {
    super.initState();
    BottomNavScreen.tabNotifier.addListener(_onTabToggled);
    _loadData();
  }

  void _onTabToggled() {
    if (mounted && _currentIndex != BottomNavScreen.tabNotifier.value) {
      setState(() => _currentIndex = BottomNavScreen.tabNotifier.value);
    }
    if (BottomNavScreen.tabNotifier.value == 2) {
      wishlistKey.currentState?.loadWishlist();
    }
  }

  @override
  void dispose() {
    BottomNavScreen.tabNotifier.removeListener(_onTabToggled);
    super.dispose();
  }

  Future<void> _loadData() async {
    await WishlistService.init();
    await EnquiryService.init();
    
    SharedPreferences sp = await SharedPreferences.getInstance();
    String username = sp.getString("name") ?? "WoodNium";

    if (mounted) {
      setState(() {
        if (username != 'WoodNium' && username.isNotEmpty) {
          _appBarTitle = 'Hello, $username...';
        } else {
          _appBarTitle = 'WoodNium';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_appBarTitle),
        centerTitle: false,
        elevation: 0,
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
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction == ScrollDirection.forward) {
            if (!_isVisible) setState(() => _isVisible = true);
          } else if (notification.direction == ScrollDirection.reverse) {
            if (_isVisible) setState(() => _isVisible = false);
          }
          return true;
        },
        child: IndexedStack(
          index: _currentIndex,
          children: _tabs,
        ),
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _isVisible ? kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom : 0,
        child: Wrap(
          children: [
            BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: Colors.grey,
              onTap: (index) {
                BottomNavScreen.tabNotifier.value = index;
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.category_outlined),
                  activeIcon: Icon(Icons.category_rounded),
                  label: 'Categories',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_border_rounded),
                  activeIcon: Icon(Icons.favorite_rounded),
                  label: 'Wishlist',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_2_outlined),
                  activeIcon: Icon(Icons.inventory_2_rounded),
                  label: 'My Enquiries',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
