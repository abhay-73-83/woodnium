import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/product.dart';
import '../../services/api_service.dart';
import '../../services/connectivity_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../no_internet_screen.dart';

class EnquiryScreen extends StatefulWidget {
  final Product? product;

  const EnquiryScreen({super.key, this.product});

  @override
  State<EnquiryScreen> createState() => EnquiryScreenState();
}

class EnquiryScreenState extends State<EnquiryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();

  String _userId = "";
  bool _isLoading = false;
  bool _isListLoading = false;
  List<dynamic> _enquiries = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("id") ?? "";
    if (!mounted) return;

    setState(() {
      _userId = userId;
      _nameController.text = prefs.getString("name") ?? "";
      _emailController.text = prefs.getString("email") ?? "";
      _phoneController.text = prefs.getString("phone") ?? "";
      _messageController.text = widget.product == null
          ? ""
          : "I am interested in ${widget.product!.name}. Please share more details.";
    });

    if (widget.product == null) {
      await _loadMyEnquiries(userId);
    }
  }

  Future<void> _loadMyEnquiries(String userId) async {
    if (userId.isEmpty) return;

    setState(() => _isListLoading = true);
    final data = await ApiService().getUserEnquiries(userId);

    if (!mounted) return;
    setState(() {
      _enquiries = data;
      _isListLoading = false;
    });
  }

  Future<void> loadMyEnquiries() async {
    if (widget.product != null) return;
    await _loadMyEnquiries(_userId);
  }

  Future<void> _submitEnquiry() async {
    final product = widget.product;
    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select product for enquiry"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (_userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please login before enquiry"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final hasInternet = await ConnectivityService().checkConnection();
    if (!mounted) return;

    if (!hasInternet) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NoInternetScreen(
            onRetry: () {
              Navigator.pop(context);
              _submitEnquiry();
            },
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final res = await ApiService().addEnquiryNow(
      userId: _userId,
      productId: product.id,
      message: _messageController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res == "1") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enquiry sent successfully"),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_enquiryErrorMessage(res)),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _enquiryErrorMessage(String response) {
    if (response == "Please Fill All Fields") {
      return "Please fill all enquiry details";
    }
    if (response == "Invalid Product") {
      return "Invalid product selected";
    }
    if (response.length > 80 || response.contains("<")) {
      return "Enquiry API not found or server error";
    }
    if (response == "0" || response.isEmpty) {
      return "Enquiry failed";
    }
    return response;
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(product == null ? "My Enquiries" : "Enquiry Now"),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: product == null
            ? _MyEnquiryList(
                enquiries: _enquiries,
                isLoading: _isListLoading,
                onRefresh: () => _loadMyEnquiries(_userId),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProductSummary(product: product),
                      const SizedBox(height: 24),
                      CustomTextField(
                        controller: _nameController,
                        hintText: "Full Name",
                        prefixIcon: Icons.person_outline,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? "Enter name"
                            : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _emailController,
                        hintText: "Email",
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: (value) {
                          final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );
                          if (value == null || value.trim().isEmpty) {
                            return "Enter email";
                          }
                          if (!emailRegex.hasMatch(value.trim())) {
                            return "Enter valid email";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _phoneController,
                        hintText: "Phone",
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                        validator: (value) {
                          final phoneRegex = RegExp(
                            r'^(\+91[\-\s]?)?[0]?(91)?[6789]\d{9}$',
                          );
                          if (value == null || value.trim().isEmpty) {
                            return "Enter phone";
                          }
                          if (!phoneRegex.hasMatch(value.trim())) {
                            return "Enter valid phone";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _MessageField(controller: _messageController),
                      const SizedBox(height: 28),
                      CustomButton(
                        text: "SEND ENQUIRY",
                        onPressed: _submitEnquiry,
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _MyEnquiryList extends StatelessWidget {
  final List<dynamic> enquiries;
  final bool isLoading;
  final Future<void> Function() onRefresh;

  const _MyEnquiryList({
    required this.enquiries,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (enquiries.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: const [
            SizedBox(height: 140),
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.primary,
            ),
            SizedBox(height: 16),
            Text(
              "No enquiries yet",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Open any product and tap Enquiry Now to see it here.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: enquiries.length,
        itemBuilder: (context, index) {
          final item = enquiries[index] as Map<String, dynamic>;
          return _EnquiryCard(item: item);
        },
      ),
    );
  }
}

class _EnquiryCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _EnquiryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final image = _firstImage(item["image"]);
    final statusText = item["status_text"]?.toString() ?? "Pending";
    final statusColor = _statusColor(item["status"]?.toString());

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: AppColors.aluminiumGradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.walnut.withValues(alpha: 0.08),
            offset: const Offset(0, 12),
            blurRadius: 22,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: image.isEmpty
                ? Container(
                    width: 78,
                    height: 78,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  )
                : Image.network(
                    image,
                    width: 78,
                    height: 78,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 78,
                      height: 78,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item["product_name"]?.toString() ?? "Product",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "₹ ${item["price"] ?? ""}",
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item["message"]?.toString() ?? "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item["created_at"]?.toString() ?? "",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _firstImage(dynamic value) {
    if (value == null) return "";
    if (value is List && value.isNotEmpty) return value.first.toString();

    final text = value.toString();
    if (text.isEmpty) return "";

    try {
      final decoded = json.decode(text);
      if (decoded is List && decoded.isNotEmpty) {
        return decoded.first.toString();
      }
    } catch (_) {}

    return text;
  }

  static Color _statusColor(String? status) {
    if (status == "yes") return AppColors.success;
    if (status == "cancel") return AppColors.error;
    return AppColors.primary;
  }
}

class _ProductSummary extends StatelessWidget {
  final Product product;

  const _ProductSummary({required this.product});

  @override
  Widget build(BuildContext context) {
    final image = product.images.isNotEmpty ? product.images.first : "";

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: AppColors.studioGradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.walnut.withValues(alpha: 0.08),
            offset: const Offset(0, 12),
            blurRadius: 22,
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: image.isEmpty
                ? Container(
                    width: 72,
                    height: 72,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  )
                : Image.network(
                    image,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 72,
                      height: 72,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "₹ ${product.price}",
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageField extends StatelessWidget {
  final TextEditingController controller;

  const _MessageField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.aluminiumGradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.walnut.withValues(alpha: 0.08),
            offset: const Offset(0, 12),
            blurRadius: 22,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        minLines: 4,
        maxLines: 6,
        validator: (value) =>
            value == null || value.trim().isEmpty ? "Enter message" : null,
        decoration: InputDecoration(
          hintText: "Message",
          prefixIcon: const Padding(
            padding: EdgeInsets.only(bottom: 72),
            child: Icon(Icons.message_outlined, color: AppColors.accent),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }
}
