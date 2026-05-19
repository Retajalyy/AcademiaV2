import 'package:flutter/material.dart';
import '../../../Core/utilities/colors.dart';
import '../../../Core/utilities/text_style.dart';
import 'package:academia/Features/Fees/screens/FeesScreen.dart';

class PayementHeader extends StatelessWidget {
  const PayementHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      color: AppColors.primaryBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔵 Top Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white,size: 28),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FeesScreen(),
                    ),
                  );
                },
              ),
              const Icon(Icons.notifications, color: Colors.white,size: 28),
            ],
          ),

          const SizedBox(height: 16),

          /// 🔵 Title
          Text(
            "Payment",
            style: TextStyles.header2.copyWith(
              color: Colors.white,
              fontSize: 30,
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),

              // Subtitle
              Text(
                "All transactions are secure and encrypted",
                style: TextStyles.caption.copyWith(
                  color: Color(0xFFDEDEDE),
                ),
              ),

          /// 🔵 Inner Card
          
        ],
      ),
    );
  }
}