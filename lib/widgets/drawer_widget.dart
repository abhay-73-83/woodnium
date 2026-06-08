import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/connectivity_service.dart';
import '../screens/auth/login_screen.dart';
import '../screens/no_internet_screen.dart';
import '../screens/profile/edit_profile_screen.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  String _name = 'Guest';
  String _email = '';
  String _phone = '';
  String _password = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _name = sp.getString('name') ?? 'Guest';
        _email = sp.getString('email') ?? '';
        _phone = sp.getString('phone') ?? '';
        _password = sp.getString('password') ?? '';
      });
    }
  }

  // ---------------- LOGOUT ----------------
  void _logout() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.clear();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // ---------------- DELETE ACCOUNT ----------------
  Future<void> _deleteUser() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final hasInternet = await ConnectivityService().checkConnection();
    if (!mounted) return;

    if (!hasInternet) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NoInternetScreen(
            onRetry: () {
              Navigator.pop(context);
              _deleteUser();
            },
          ),
        ),
      );
      return;
    }

    // Loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String id = sp.getString('id') ?? "";

      if (id.isEmpty) {
        if (mounted) Navigator.pop(context);
        return;
      }

      final res = await ApiService().deleteUser(id);

      if (!mounted) return;
      Navigator.pop(context);

      if (res == 1) {
        await sp.clear();

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account Deleted Successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delete Failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Server Error'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ---------------- EDIT PROFILE ----------------
  Future<void> _navigateToEditProfile() async {
    Navigator.pop(context); // Close Drawer
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          initialName: _name,
          initialEmail: _email,
          initialPhone: _phone,
          initialPassword: _password,
        ),
      ),
    );

    if (result != null && result is Map && mounted) {
      _loadUserData(); // refresh from local storage
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppColors.studioGradient,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.walnut.withValues(alpha: 0.1),
                  blurRadius: 24,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        gradient: AppColors.woodGradient,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: Text(
                          _name.isNotEmpty ? _name[0].toUpperCase() : "S",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.design_services_rounded),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  _name,
                  style: const TextStyle(
                    color: AppColors.graphite,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (_email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _email,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
                if (_phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _phone,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          _drawerTile(
            Icons.person_rounded,
            "Edit Profile",
            _navigateToEditProfile,
          ),
          _drawerTile(
            Icons.delete_rounded,
            "Delete Account",
            _deleteUser,
            danger: true,
          ),
          _drawerTile(Icons.logout_rounded, "Logout", _logout),
        ],
      ),
    );
  }

  Widget _drawerTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool danger = false,
  }) {
    final color = danger ? AppColors.error : AppColors.graphite;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: AppColors.aluminiumGradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white, width: 1.2),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(color: color, fontWeight: FontWeight.w800),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
