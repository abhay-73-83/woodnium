import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/connectivity_service.dart';
import 'login_screen.dart';
import 'no_internet_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final String initialPhone;
  final String initialPassword;

  const ProfileScreen({
    super.key,
    required this.initialName,
    required this.initialEmail,
    required this.initialPhone,
    required this.initialPassword,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  final TextEditingController _passCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isObscure = true;
  late String _currentName;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();

    _nameCtrl = TextEditingController(text: widget.initialName);
    _emailCtrl = TextEditingController(text: widget.initialEmail);
    _phoneCtrl = TextEditingController(text: widget.initialPhone);
    _passCtrl.text = widget.initialPassword;

    _currentName = widget.initialName;
    _loadName();
  }

  Future<void> _loadName() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String username = sp.getString("name") ?? "WoodNium";
    if (mounted) {
      setState(() {
        _currentName = username;
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ================= UPDATE USER =================
  Future<void> updateUser() async {
    if (!_formKey.currentState!.validate()) return;

    final hasInternet = await ConnectivityService().checkConnection();
    if (!mounted) return;

    if (!hasInternet) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('No Internet Connection'),
      //     backgroundColor: AppColors.error,
      //   ),
      // );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NoInternetScreen(
            onRetry: () {
              Navigator.pop(context);
              updateUser();
            },
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      SharedPreferences sp = await SharedPreferences.getInstance();

      String id = sp.getString("id") ?? "";

      if (id.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final res = await _apiService.updateUser(
        id,
        _nameCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _phoneCtrl.text.trim(),
        _passCtrl.text.trim(),
      );

      setState(() => _isLoading = false);
      if (!mounted) return;

      if (res == 1) {
        sp.setString("name", _nameCtrl.text.trim());
        sp.setString("email", _emailCtrl.text.trim());
        sp.setString("phone", _phoneCtrl.text.trim());
        sp.setString("password", _passCtrl.text.trim());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile Updated'),
            backgroundColor: AppColors.success,
          ),
        );

        Navigator.pop(context, {
          "name": _nameCtrl.text.trim(),
          "email": _emailCtrl.text.trim(),
          "phone": _phoneCtrl.text.trim(),
          "password": _passCtrl.text.trim(),
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Update Failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  // ================= DELETE USER =================
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
      String id = sp.getString("id") ?? "";

      if (id.isEmpty) {
        Navigator.pop(context);
        return;
      }

      final res = await ApiService().deleteUser(id);

      if (!mounted) return;
      Navigator.pop(context);

      if (res == 1) {
        sp.clear();

        // ✅ NAVIGATE LOGIN
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

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Hello, $_currentName...",
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shadowColor: AppColors.primary.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator: (v) => v!.isEmpty ? 'Enter your name' : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _emailCtrl,
                        // enabled: false,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (value) {
                          final RegExp emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );
                          if (value == null) {
                            return 'Enter a email address';
                          } else if (!emailRegex.hasMatch(value)) {
                            return 'Enter a valid email address';
                          }
                          return null; // Input is valid
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Phone'),
                        validator: (value) {
                          final RegExp phoneRegex = RegExp(
                            r'^(\+91[\-\s]?)?[0]?(91)?[6789]\d{9}$',
                          );
                          if (value == null) {
                            return 'Enter a phone number';
                          } else if (!phoneRegex.hasMatch(value)) {
                            return 'Enter a valid phone number';
                          }
                          return null; // Input is valid
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _isObscure,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            },
                          ),
                        ),
                        validator: (v) => v!.isEmpty ? 'Enter password' : null,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : updateUser,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Update Profile'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : deleteUser,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Delete Account'),
            ),
          ],
        ),
      ),
    );
  }
}
