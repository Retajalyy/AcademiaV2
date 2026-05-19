import 'package:academia/Core/widgets/custom_header.dart';
import 'package:academia/Features/Home/widgets/section_header.dart';
import 'package:flutter/material.dart';
import '../controllers/services_controller.dart';
import '../models/service_item_model.dart';
import '../widgets/academic_service_card.dart';
import '../widgets/admin_service_tile.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  late final ServicesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ServicesController();
    _controller.addListener(() => setState(() {}));
    _controller.loadServices();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isGridSection(ServiceSectionModel section) =>
      section.title.toUpperCase() == 'ACADEMIC';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(
              title: 'Services',
              description: 'Access your academic services quickly',
              showBackButton: false,
            ),
            Expanded(
              child: _controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _controller.errorMessage != null
                      ? _buildError()
                      : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      children: _controller.sections.map((section) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: section.title, actionText: '', onTap: () {  },),
            _isGridSection(section)
                ? _buildGrid(section)
                : _buildList(section),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildGrid(ServiceSectionModel section) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: section.items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final item = section.items[index];
        return AcademicServiceCard(
          item: item,
          onTap: () => _controller.onServiceTapped(item, context),
        );
      },
    );
  }

  Widget _buildList(ServiceSectionModel section) {
    return Column(
      children: section.items
          .map((item) => AdminServiceTile(
                item: item,
                onTap: () => _controller.onServiceTapped(item, context),
              ))
          .toList(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          Text(
            _controller.errorMessage!,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _controller.loadServices,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}