import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utilities/colors.dart';
import '../controller/exam_results_controller.dart';
import '../model/exam_result_model.dart';

class ExamResultTile extends StatelessWidget {
  final ExamResultModel result;

  const ExamResultTile({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Semester
          Text(
            result.semester.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
              letterSpacing: 0.3,
            ),
          ),

          const SizedBox(height: 4),

          /// Title
          Text(
            result.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBlue,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 2),

          /// Academic year
          Text(
            'Academic year ${result.academicYear}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),

          const SizedBox(height: 14),

          /// Stats Boxes
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  value: result.studentsCount.toString(),
                  label: 'Students',
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _StatBox(
                  value: '${result.passRate.toInt()}%',
                  label: 'Pass rate',
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _StatBox(
                  value: result.avgGpa.toStringAsFixed(1),
                  label: 'Avg GPA',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// Divider
          Container(
            height: 1,
            color: Colors.grey.shade200,
          ),

          const SizedBox(height: 10),

          /// File Row
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: 15,
                color: Colors.grey.shade400,
              ),

              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  result.fileName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              GestureDetector(
                onTap: () =>
                    Get.find<ExamResultsController>().viewResult(result),
                child: const Icon(Icons.visibility_outlined,
                    size: 20, color: AppColors.primaryBlue),
              ),

              const SizedBox(width: 14),

              GestureDetector(
                onTap: () =>
                    Get.find<ExamResultsController>().downloadResult(result),
                child: const Icon(Icons.download_outlined,
                    size: 20, color: AppColors.primaryBlue),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;

  const _StatBox({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xffF7F9FC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBlue,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}