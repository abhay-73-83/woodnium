import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../services/api_service.dart';
import '../../services/connectivity_service.dart';
import 'signup_screen.dart';
import '../no_internet_screen.dart';
import '../bottom_nav_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void checkdata() async {
    if (!_formKey.currentState!.validate()) return;

    final hasInternet = await ConnectivityService().checkConnection();
    if (!mounted) return;

    if (!hasInternet) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NoInternetScreen(
            onRetry: () {
              Navigator.pop(context);
              checkdata();
            },
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      var user = await ApiService().signinUser(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      setState(() => _isLoading = false);
      if (!mounted) return;

      if (user != null) {
        SharedPreferences sp = await SharedPreferences.getInstance();
        sp.setString("id", user["id"].toString());
        sp.setString("name", user["name"]);
        sp.setString("email", user["email"]);
        sp.setString("phone", user["phone"]);
        sp.setString("password", user["password"]);
        sp.setBool("isLoggedIn", true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login Success"),
            backgroundColor: AppColors.success,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BottomNavScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login Failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Server Error or Timeout'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 12),
            Container(
              height: 210,
              decoration: BoxDecoration(
                gradient: AppColors.studioGradient,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.walnut.withValues(alpha: 0.12),
                    blurRadius: 28,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 22,
                    top: 24,
                    child: Container(
                      width: 96,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white, width: 1.2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Image.asset("assets/logo.png"),
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 22,
                    bottom: 24,
                    right: 132,
                    child: Text(
                      "Welcome to your wooden comfort studio.",
                      style: TextStyle(
                        color: AppColors.graphite,
                        fontSize: 30,
                        height: 1.02,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.aluminiumGradient,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.07),
                    blurRadius: 24,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.graphite,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email,
                      validator: (value) {
                        final RegExp emailRegex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );
                        if (value == null) {
                          return 'Enter a email address';
                        } else if (!emailRegex.hasMatch(value)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      prefixIcon: Icons.lock,
                      isPassword: true,
                      validator: (v) => v!.isEmpty ? 'Enter password' : null,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'LOGIN',
                      onPressed: checkdata,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 14),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignupScreen(),
                          ),
                        );
                      },
                      child: const Text("Create new account"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
