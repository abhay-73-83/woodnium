import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/connectivity_service.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'login_screen.dart';
import 'no_internet_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> Adddata() async {
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
              Adddata();
            },
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      var res = await ApiService().signupUser(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _phoneController.text.trim(),
        _passwordController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (res == 1) {
        // Save user data
        // SharedPreferences sp = await SharedPreferences.getInstance();
        // await sp.setString("name", _nameController.text.trim());
        // await sp.setString("email", _emailController.text.trim());
        // await sp.setString("phone", _phoneController.text.trim());
        // await sp.setString("password", _passwordController.text.toString());
        // await sp.setBool("isLogin", false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signup Success'),
            backgroundColor: AppColors.success,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signup Failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (!mounted) return;

      print('Signup Error: $e');

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
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
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

                const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 40),

                CustomTextField(
                  controller: _nameController,
                  hintText: 'Full Name',
                  prefixIcon: Icons.person_outline,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter name' : null,
                ),

                const SizedBox(height: 20),

                CustomTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    final RegExp emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
                    if (value == null) {
                      return 'Enter a  email address';
                    } else if (!emailRegex.hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null; // Input is valid
                  },
                ),

                const SizedBox(height: 20),

                CustomTextField(
                  controller: _phoneController,
                  hintText: 'Phone',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
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

                const SizedBox(height: 20),

                CustomTextField(
                  controller: _passwordController,
                  // obscureText: _isObscure,
                  hintText: 'Password',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter password';
                    if (v.length < 6) return 'Min 6 chars';
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                CustomButton(
                  text: 'REGISTER',
                  onPressed: Adddata,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text("Login"),
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
