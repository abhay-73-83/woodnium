import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../utils/app_colors.dart';
import 'home/home_screen.dart';
import 'category/category_screen.dart';
import 'wishlist/wishlist_screen.dart';
import 'enquiry/enquiry_screen.dart';
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
  final GlobalKey<EnquiryScreenState> enquiryKey = GlobalKey();

  late final List<Widget> _tabs = [
    const HomeScreen(),
    const CategoryScreen(),
    WishlistScreen(key: wishlistKey),
    EnquiryScreen(key: enquiryKey),
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
    if (BottomNavScreen.tabNotifier.value == 3) {
      enquiryKey.currentState?.loadMyEnquiries();
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
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _currentIndex == 0
          ? null
          : AppBar(
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
        child: IndexedStack(index: _currentIndex, children: _tabs),
      ),
      bottomNavigationBar: ClipRect(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          height: _isVisible ? 98 + bottomInset : 0,
          padding: _isVisible
              ? EdgeInsets.only(left: 14, right: 14, bottom: bottomInset + 10)
              : EdgeInsets.zero,
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(),
          child: Align(
            alignment: Alignment.topCenter,
            child: _WoodniumNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                BottomNavScreen.tabNotifier.value = index;
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _WoodniumNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _WoodniumNavBar({required this.currentIndex, required this.onTap});

  static const List<_NavItemData> _items = [
    _NavItemData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavItemData(
      icon: Icons.category_outlined,
      activeIcon: Icons.category_rounded,
      label: 'Categories',
    ),
    _NavItemData(
      icon: Icons.favorite_border_rounded,
      activeIcon: Icons.favorite_rounded,
      label: 'Wishlist',
    ),
    _NavItemData(
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2_rounded,
      label: 'Enquiries',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / _items.length;
          final activeCenter = itemWidth * currentIndex + itemWidth / 2;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 66,
                child: CustomPaint(
                  painter: _NavBarShapePainter(activeCenter: activeCenter),
                  child: Row(
                    children: List.generate(_items.length, (index) {
                      final item = _items[index];
                      final selected = index == currentIndex;

                      return Expanded(
                        child: _NavBarButton(
                          item: item,
                          selected: selected,
                          onTap: () => onTap(index),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutBack,
                left: activeCenter - 35,
                top: 0,
                child: _ActiveNavBubble(icon: _items[currentIndex].activeIcon),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NavBarButton extends StatelessWidget {
  final _NavItemData item;
  final bool selected;
  final VoidCallback onTap;

  const _NavBarButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: selected ? 0 : 1,
            child: Icon(item.icon, color: AppColors.aluminiumDark, size: 28),
          ),
        ),
      ),
    );
  }
}

class _ActiveNavBubble extends StatelessWidget {
  final IconData icon;

  const _ActiveNavBubble({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.secondary, width: 5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        width: 50,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: AppColors.aluminiumGradient,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.2),
        ),
        child: Icon(icon, color: AppColors.primary, size: 28),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _NavBarShapePainter extends CustomPainter {
  final double activeCenter;

  const _NavBarShapePainter({required this.activeCenter});

  @override
  void paint(Canvas canvas, Size size) {
    final shapePaint = Paint()
      ..shader = AppColors.aluminiumGradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white;
    final shadowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    final path = _buildPath(size);

    canvas.drawPath(path.shift(const Offset(0, 6)), shadowPaint);
    canvas.drawPath(path, shapePaint);
    canvas.drawPath(path, borderPaint);
  }

  Path _buildPath(Size size) {
    const radius = 28.0;
    const notchRadius = 42.0;
    final notchCenter = activeCenter.clamp(
      notchRadius + 10,
      size.width - notchRadius - 10,
    );
    final notchStart = notchCenter - notchRadius;
    final notchEnd = notchCenter + notchRadius;

    return Path()
      ..moveTo(radius, 0)
      ..lineTo(notchStart, 0)
      ..cubicTo(notchStart + 12, 0, notchStart + 10, 30, notchCenter, 30)
      ..cubicTo(notchEnd - 10, 30, notchEnd - 12, 0, notchEnd, 0)
      ..lineTo(size.width - radius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, radius)
      ..lineTo(size.width, size.height - radius)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width - radius,
        size.height,
      )
      ..lineTo(radius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - radius)
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _NavBarShapePainter oldDelegate) {
    return oldDelegate.activeCenter != activeCenter;
  }
}
