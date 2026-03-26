import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../services/connectivity_service.dart';
import '../no_internet_screen.dart';
import '../login_screen.dart';
import '../edit_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String _name = 'Guest User';
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
        _name = sp.getString('name') ?? 'Guest User';
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
  Future<void> deleteUser() async {
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
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
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
              deleteUser();
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
        Navigator.pop(context);
        return;
      }

      final res = await ApiService().deleteUser(id);

      if (!mounted) return;
      Navigator.pop(context);

      if (res == 1) {
        await sp.clear();

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
    if (!mounted) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          initialName: _name,
          initialEmail: _email,
          initialPhone: _phone,
          initialPassword: _password,

        ),
      ),
    );

    if (result != null && result is Map && mounted) {
      setState(() {
        _name = result['name'];
        _email = result['email'];
        _phone = result['phone'];
        _password = result['password'];
      });

      _loadUserData(); // refresh from local storage
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // PROFILE CARD
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.background,
                child:
                Icon(Icons.person, size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 16),

              Text(
                _name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              Text(_email,
                  style: const TextStyle(color: AppColors.textSecondary)),

              const SizedBox(height: 8),

              Text(_phone,
                  style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),

        const SizedBox(height: 30),

        _buildActionTile(
          icon: Icons.edit,
          title: "Edit Profile",
          onTap: _navigateToEditProfile,
        ),

        const SizedBox(height: 12),

        _buildActionTile(
          icon: Icons.delete,
          title: "Delete Account",
          isDestructive: true,
          onTap: deleteUser,
        ),

        const SizedBox(height: 12),

        _buildActionTile(
          icon: Icons.logout,
          title: "Logout",
          onTap: _logout,
        ),
      ],
    );
  }

  // ---------------- COMMON TILE ----------------
  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon,
          color: isDestructive ? AppColors.error : AppColors.primary),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}