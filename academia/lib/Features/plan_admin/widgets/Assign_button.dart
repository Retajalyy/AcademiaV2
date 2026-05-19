import 'package:flutter/material.dart';
import '../../../Core/utilities/colors.dart';
import 'package:academia/Features/plan_admin/screens/PlanAdmin2Screen .dart';

class AddNewPlan extends StatelessWidget {
  const AddNewPlan({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 38),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              onPressed: () {
                // ✅ Button click action
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const Planadminscreen2(),
                    ),
                    );
              },
              child: const Text(
                "Assign Group",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}