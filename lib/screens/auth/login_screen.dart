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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 200,
                  height: 200,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withAlpha(10),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset("assets/logo.png"),
                ),

                const SizedBox(height: 32),

                const Text(
                  'Welcome Back',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 40),

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
                    }
                    else if(!emailRegex.hasMatch(value))
                    {
                      return 'Enter a valid email address';
                    }
                    return null; // Input is valid
                  },
                ),

                const SizedBox(height: 20),

                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  prefixIcon: Icons.lock,
                  isPassword: true,
                  validator: (v) => v!.isEmpty ? 'Enter password' : null,
                ),

                const SizedBox(height: 30),

                CustomButton(
                  text: 'LOGIN',
                  onPressed: checkdata,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),

                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignupScreen(),
                          ),
                        );
                      },
                      child: const Text("Create Account"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
