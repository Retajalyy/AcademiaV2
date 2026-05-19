import 'package:flutter/material.dart';
import 'package:academia/Features/plan_admin2/widgets/planAdminHeader2.dart';
import 'package:academia/Features/plan_admin2/widgets/group_widget.dart';
import 'package:academia/Features/plan_admin2/widgets/save_button.dart';

import '../../../Core/utilities/colors.dart';

class Planadminscreen2 extends StatefulWidget {
  const Planadminscreen2({super.key});

  @override
  State<Planadminscreen2> createState() =>
      _Planadminscreen2State();
}

class _Planadminscreen2State
    extends State<Planadminscreen2> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,

      body: SafeArea(
        child: Column(
          children: [

            /// HEADER
            const PlanHeader2(currentStep: 2),

            /// BODY
            Expanded(
              child: Container(
                width: double.infinity,

                decoration: const BoxDecoration(
                  color: AppColors.babyblue,

                 
                ),

                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      /// GROUP FORM
                      GroupFormWidget(
                        onAddAnotherGroup: () {},
                      ),

                      const SizedBox(height: 24),

                      /// SAVE BUTTON
                      Center(
                        child: SizedBox(
                          width: 190,

                          child: SaveButton(),
                        ),
                      ),
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