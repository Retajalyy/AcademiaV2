import 'package:flutter/material.dart';
import '../../../Core/utilities/colors.dart';
import '../../../Core/utilities/text_style.dart';
import 'package:academia/Features/Payement/screens/PayementScreen.dart';

class PayementStatusHeader extends StatelessWidget {
  const PayementStatusHeader({super.key});

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
                      builder: (_) =>  PayementScreen(),
                    ),
                  );
                },
              ),
              const Icon(Icons.notifications, color: Colors.white,size: 28),
            ],
          ),

          const SizedBox(height: 16),

          /// 🔵 Title
       Center(
  child: Text(
    "Payment",
    style: TextStyles.header2.copyWith(
      color: Colors.white,
      fontSize: 30,
      fontFamily: 'Inter',
      fontWeight: FontWeight.bold,
    ),
  ),
),
          /// 🔵 Inner Card
          
        ],
      ),
    );
  }
}