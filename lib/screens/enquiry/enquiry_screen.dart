import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../services/enquiry_service.dart';

class EnquiryScreen extends StatelessWidget {
  const EnquiryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: EnquiryService.enquiryNotifier,
      builder: (context, enquiries, child) {
        if (enquiries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 80, color: AppColors.primary.withValues(alpha: 0.2)),
                const SizedBox(height: 16),
                const Text(
                  'No enquiries yet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap \'Enquiry Now\' on products',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: enquiries.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = enquiries[index];
            final isCompleted = item['status'] == 'Completed';

            String finalImageUrl = "";
            var imgObj = item["image"] ?? item["icon"];
            if (imgObj != null && imgObj.toString().isNotEmpty) {
              String img = imgObj.toString();
              if (img.startsWith('["') && img.endsWith('"]')) {
                img = img.substring(2, img.length - 2).replaceAll('\\/', '/');
              }
              finalImageUrl = img.startsWith('http') ? img : "https://www.prakrutitech.xyz/abhay/uploads/" + img;
            }

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                    child: (finalImageUrl.isEmpty)
                        ? const Icon(Icons.image, size: 100)
                        : Image.network(
                            finalImageUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.broken_image, size: 100);
                            },
                          ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  item['name'] ?? item['title'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  EnquiryService.removeEnquiry(item['enquiryId']);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Enquiry Removed', style: TextStyle(color: Colors.white)), backgroundColor: AppColors.error),
                                  );
                                },
                                child: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['price'] ?? '',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                isCompleted ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                                size: 16,
                                color: isCompleted ? AppColors.success : AppColors.accent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item['status'] ?? 'Pending',
                                style: TextStyle(
                                  color: isCompleted ? AppColors.success : AppColors.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Requested on: ${item['date']}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

