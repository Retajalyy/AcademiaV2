import 'package:flutter/material.dart';
import 'package:academia/Features/plan_admin3/widgets/planAdminHeader3.dart';
import 'package:academia/Features/plan_admin3/widgets/group_card.dart';
import '../../../Core/utilities/colors.dart';

class Planadminscreen3 extends StatefulWidget {
  const Planadminscreen3({super.key});

  @override
  State<Planadminscreen3> createState() => _Planadminscreen3State();
}

class _Planadminscreen3State extends State<Planadminscreen3> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,

      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            const PlanHeader3(currentStep: 3),

            /// BODY
            Expanded(
              child: Container(
                width: double.infinity,

                decoration: const BoxDecoration(
                  color: AppColors.babyblue,


                  /// ONLY TOP BORDER
                  border: Border(
                    top: BorderSide(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),

                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      /// GROUP CARD
                      const GroupSE1Card(
                        groupName: "SE1",
                        department: "Software Engineering",
                        level: "Level 4",
                        courseCount: 6,
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}