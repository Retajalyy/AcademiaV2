import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controller/registiration_controller.dart';

class RegistrationStatusCard extends StatelessWidget {
  const RegistrationStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RegistrationController>();

    return Obx(() {
      final reg      = controller.registrationStatus.value;
      final isOpen   = reg?.isOpen ?? false;
      final message  = reg?.message  ?? 'Loading…';
      final subtitle = (reg != null && reg.closingDate.isNotEmpty)
          ? '${reg.closingDate}${reg.daysRemaining.isNotEmpty ? " • ${reg.daysRemaining}" : ""}'
          : '';

      final bgColor     = isOpen ? const Color(0xFFE1F5EF) : const Color(0xFFF3F5F7);
      final borderColor = isOpen ? const Color(0xFFCFF2E7) : Colors.grey.shade300;
      final dotColor    = isOpen ? AppColors.darkGreen : AppColors.smalltext;
      final textColor   = isOpen ? AppColors.darkGreen : AppColors.smalltext;
      final badgeColor  = isOpen ? AppColors.darkGreen : AppColors.greytext;
      final badgeText   = isOpen ? 'Live' : 'Closed';

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: dotColor.withValues(alpha: 0.15),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.smalltext,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badgeText,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
