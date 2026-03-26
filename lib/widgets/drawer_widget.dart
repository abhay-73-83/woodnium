import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/storage_service.dart';
import '../screens/placeholder_screen.dart';
import '../screens/login_screen.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  String _name = 'Guest User';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await StorageService.getUserData();
    if (mounted) {
      setState(() {
        _name = data['name'] ?? 'Guest User';
        _email = data['email'] ?? '';
      });
    }
  }

  void _navigateTo(BuildContext context, String title) {
    Navigator.pop(context); // close drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlaceholderScreen(title: title)),
    );
  }

  void _logout(BuildContext context) async {
    await StorageService.setLoggedIn(false);
    await StorageService.setUserData('', '');
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 24, left: 24, right: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                Text(
                  _name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _email,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Menu List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuItem(Icons.home_rounded, 'Home', () => Navigator.pop(context)),
                _buildMenuItem(Icons.person_outline, 'My Profile', () => _navigateTo(context, 'My Profile')),
                _buildMenuItem(Icons.favorite_outline, 'Wishlist', () => _navigateTo(context, 'Wishlist')),
                _buildMenuItem(Icons.category_outlined, 'Categories', () => _navigateTo(context, 'Categories')),
                const Divider(),
                _buildMenuItem(Icons.settings_outlined, 'Settings', () => _navigateTo(context, 'Settings')),
                _buildMenuItem(Icons.help_outline, 'Help & Support', () => _navigateTo(context, 'Help & Support')),
                const Divider(),
                _buildMenuItem(Icons.logout_rounded, 'Logout', () => _logout(context), isDestructive: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;
    return ListTile(
      leading: Icon(icon, color: isDestructive ? AppColors.error : AppColors.primary),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
      onTap: onTap,
      splashColor: AppColors.primary.withValues(alpha: 0.1),
    );
  }
}
