import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:academia/Core/utilities/colors.dart';
import 'package:academia/Core/utilities/text_style.dart';
import 'package:academia/Features/Home/models/schedule_item_model.dart';
import 'package:academia/Features/Schedule/model/class_model.dart';
import 'package:academia/Features/Schedule/controllers/schedule_controller.dart';
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
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _controller.loadSchedule(_selectedDate),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                    return const _LoadingPlaceholder();
                  }

                  if (_controller.errorMessage.value != null) {
                    return _ErrorState(
                      message: _controller.errorMessage.value!,
                      onRetry: () => _controller.loadSchedule(_selectedDate),
                    );
                  }

                  if (_controller.classes.isEmpty) {
                    return const _EmptyState();
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
        ),
      ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.event_available_outlined,
                size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No classes today 🎉',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
                fontFamily: 'Instrument Sans',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontFamily: 'Instrument Sans',
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
