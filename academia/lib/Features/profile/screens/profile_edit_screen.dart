import 'package:academia/Core/utilities/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileEditScreen extends StatelessWidget {
  const ProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color:AppColors.primaryBlue));
        }

        final user = controller.student.value;
        if (user == null) return const Center(child: Text("Error loading data"));

        return SingleChildScrollView(
          child: Column(
            children: [
              // --- Blue Header Section ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 50, bottom: 30),
                decoration: const BoxDecoration(color:AppColors.primaryBlue),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Get.back(),
                          ),
                          const Text(
                            "Edit profile",
                            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          // Save Button with loading indicator
                          SizedBox(
                            height: 36,
                            child: ElevatedButton(
                              onPressed: controller.isSaving.value ? null : () => controller.updateProfile(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: controller.isSaving.value 
                                ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text("Save", style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Obx(() {
                      final pending = controller.pendingImageBytes.value;
                      final url    = controller.avatarUrl.value;

                      // Priority: local pending > saved URL > initials
                      ImageProvider? image;
                      if (pending != null) {
                        image = MemoryImage(pending);
                      } else if (url != null) {
                        image = NetworkImage(url);
                      }

                      return GestureDetector(
                        onTap: controller.isSaving.value ? null : controller.pickProfileImage,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 54,
                              backgroundColor: const Color(0xFFFFD700),
                              child: CircleAvatar(
                                radius: 51,
                                backgroundColor: const Color(0xFF1A337E),
                                backgroundImage: image,
                                child: image == null
                                    ? Text(
                                        user.name.substring(0, 2).toUpperCase(),
                                        style: const TextStyle(
                                            fontSize: 32,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      )
                                    : null,
                              ),
                            ),
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white,
                              child: controller.isSaving.value
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.camera_alt,
                                      color: Color(0xFF1A337E), size: 18),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    const Text("Tap to change photo", style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),

              // --- Info Alert ---
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF1A337E), size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Name, student ID, major and level are set by the university and cannot be edited.",
                        style: TextStyle(fontSize: 12, color: Color(0xFF1A337E)),
                      ),
                    ),
                  ],
                ),
              ),

              // --- University Info (Read Only) ---
              _buildLabel("UNIVERSITY INFO"),
              _buildDataCard([
                _buildInfoTile(Icons.person_outline, "Full name", user.name),
                _buildInfoTile(Icons.credit_card_outlined, "Student ID", user.id),
                _buildInfoTile(Icons.account_balance_outlined, "Faculty", user.faculty),
                _buildInfoTile(Icons.school_outlined, "Major", user.faculty),
                _buildInfoTile(Icons.email_outlined, "University email", user.email),
              ]),

              // --- Personal Info (Editable) ---
              const SizedBox(height: 20),
              _buildLabel("PERSONAL INFO"),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.phone_outlined, color: Color(0xFF1A337E)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Phone number", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            TextField(
                              controller: controller.phoneController,
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.only(top: 4),
                              ),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(text, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  Widget _buildDataCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: Colors.grey[500], size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 14, color: Colors.grey[800])),
              ],
            ),
          ),
          const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}