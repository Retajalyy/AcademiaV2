import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:academia/Core/utilities/colors.dart';
import 'package:academia/Core/utilities/text_style.dart';
import 'package:academia/Features/Home/models/schedule_item_model.dart';
import 'package:academia/Features/Schedule/model/class_model.dart';
import 'package:academia/Features/schedule/controllers/schedule_controller.dart';
import '../widgets/calendar.dart';
import '../widgets/class_card.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late final ScheduleController _controller;
  DateTime _selectedDate = DateTime.now();

  static const _accentColors = [
    AppColors.accentProgramming1,
    AppColors.accentAI,
    AppColors.accentDataStructures,
    AppColors.accentStatistics,
  ];

  @override
  void initState() {
    super.initState();
    _controller = Get.put(ScheduleController());
  }

  ClassModel _toClassModel(ScheduleItem item, int index) {
    final parts = item.time.split(' - ');
    return ClassModel(
      title: item.title,
      room: item.location,
      instructor: item.instructor,
      startTime: parts[0],
      endTime: parts.length > 1 ? parts[1] : '',
      type: item.type,
      accentColor: _accentColors[index % _accentColors.length],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CalendarWidget(
              selectedDate: _selectedDate,
              onDateSelected: (date) {
                setState(() => _selectedDate = date);
                _controller.loadSchedule(date);
              },
            ),

            const SizedBox(height: 24),

            Text('Classes', style: TextStyles.header2),

            const SizedBox(height: 16),

            Obx(() {
              if (_controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_controller.classes.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      'No classes on this day',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }
              return Column(
                children: _controller.classes
                    .asMap()
                    .entries
                    .map((e) => ClassCardWidget(
                          classModel: _toClassModel(e.value, e.key),
                        ))
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}
