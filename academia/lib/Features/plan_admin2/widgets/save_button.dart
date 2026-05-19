import 'package:flutter/material.dart';
import '../../../Core/utilities/colors.dart';
import 'package:academia/Features/plan_admin3/screens/PlanAdmin3Screen .dart';
class SaveButton extends StatelessWidget {
  const SaveButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const Planadminscreen3(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(
              color: Color(0x12000000), // black 7%
            ),
          ),
        ),
        child: const Text(
          "Save & Continue",
          style: TextStyle(
            color: AppColors.accentProgramming1,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}