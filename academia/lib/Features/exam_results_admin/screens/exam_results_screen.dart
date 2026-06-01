import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../../../Core/widgets/side_menu.dart';
import '../controller/exam_results_controller.dart';
import '../widgets/exam_result_title.dart';
import '../widgets/upload_bottom_sheet.dart';

class ExamResultsAdminScreen extends StatelessWidget {
  const ExamResultsAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),

      /// SIDE MENU
      drawer: const SideMenu(
        activeItem: "Exam Results",
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          _BlueHeader(),
          _UploadCtaCard(),
          _SearchBar(),
          _FilterChips(),
          _SectionLabel(),
          Expanded(
            child: _ResultsList(),
          ),
        ],
      ),
    );
  }
}

class _BlueHeader extends StatelessWidget {
  const _BlueHeader();

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ExamResultsController());
    final top = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(16, top + 14, 16, 20),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER ROW
          Row(
            children: [
              Builder(
                builder: (context) => InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Exam Results',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 2),

                  Text(
                    'Upload and browse academic results',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// STATS
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: _StatBox(
                    value: c.totalUploads.value.toString(),
                    label: 'Total uploads',
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: _StatBox(
                    value: c.thisSemester.value.toString(),
                    label: 'This semester',
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: _StatBox(
                    value: _fmt(c.totalStudents.value),
                    label: 'Students',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _fmt(int n) {
    return n >= 1000
        ? '${(n / 1000).toStringAsFixed(1).replaceAll('.0', '')}k'
        : '$n';
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// ════════════════════════════════════════════════════════════════════════
/// UPLOAD CARD
/// ════════════════════════════════════════════════════════════════════════

class _UploadCtaCard extends StatelessWidget {
  const _UploadCtaCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Material(
        color: const Color(0xFF0C4D83),
        borderRadius: BorderRadius.circular(14),
        elevation: 2,
        shadowColor: Colors.black12,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: UploadBottomSheet.show,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 20,
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.cloud_upload_outlined,
                    color: Color(0xFFFFC258),
                    size: 28,
                  ),
                ),

                const SizedBox(width: 16),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload new results',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(height: 4),

                      Text(
                        'Publish grades directly to students',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.chevron_right,
                  color: Colors.white70,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ════════════════════════════════════════════════════════════════════════
/// SEARCH BAR
/// ════════════════════════════════════════════════════════════════════════

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ExamResultsController>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        onChanged: c.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search results...',
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey.shade400,
            size: 20,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 4,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

/// ════════════════════════════════════════════════════════════════════════
/// FILTER CHIPS
/// ════════════════════════════════════════════════════════════════════════

class _FilterChips extends StatelessWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ExamResultsController>();

    return SizedBox(
      height: 46,
      child: Obx(() {
        final active = c.activeFilter.value;
        final tabs   = c.filterTabs;

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 7,
          ),
          itemCount: tabs.length,
          itemBuilder: (_, i) {
            final isSelected = active == tabs[i];

            return Padding(
              padding: EdgeInsets.only(
                right: i < tabs.length - 1 ? 8 : 0,
              ),
              child: GestureDetector(
                onTap: () => c.onFilterChanged(tabs[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Text(
                    tabs[i],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// ════════════════════════════════════════════════════════════════════════
/// SECTION LABEL
/// ════════════════════════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  const _SectionLabel();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Text(
        'UPLOADED RESULTS',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}

/// ════════════════════════════════════════════════════════════════════════
/// RESULTS LIST
/// ════════════════════════════════════════════════════════════════════════

class _ResultsList extends StatelessWidget {
  const _ResultsList();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ExamResultsController>();

    return Obx(() {
      final status = c.listStatus.value;
      final results = c.filteredResults.toList();

      if (status == ListStatus.loading) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (status == ListStatus.error) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 42,
                color: Colors.grey.shade400,
              ),

              const SizedBox(height: 10),

              Text(
                'Failed to load results',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 8),

              TextButton(
                onPressed: c.loadResults,
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      if (results.isEmpty) {
        return Center(
          child: Text(
            'No results found',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.only(
          top: 4,
          bottom: 24,
        ),
        itemCount: results.length,
        itemBuilder: (_, i) {
          return ExamResultTile(
            result: results[i],
          );
        },
      );
    });
  }
}