import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../Core/utilities/colors.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class AdminAnnouncement {
  final int    id;
  final String title;
  final String body;
  final String type;
  final String targetRole;
  final String timeAgo;

  const AdminAnnouncement({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.targetRole,
    required this.timeAgo,
  });

  factory AdminAnnouncement.fromMap(Map<String, dynamic> m) {
    final raw = m['created_at'] as String? ?? '';
    String timeAgo = '';
    try {
      final dt   = DateTime.parse(raw).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) {
        timeAgo = '${diff.inMinutes} min ago';
      } else if (diff.inHours < 24) {
        timeAgo = '${diff.inHours} hours ago';
      } else if (diff.inDays == 1) {
        timeAgo = 'Yesterday';
      } else if (diff.inDays < 7) {
        timeAgo = '${diff.inDays} days ago';
      } else {
        timeAgo = '${diff.inDays ~/ 7} weeks ago';
      }
    } catch (_) {}
    return AdminAnnouncement(
      id:         m['id']          as int,
      title:      m['title']       as String? ?? '',
      body:       m['body']        as String? ?? '',
      type:       (m['type']       as String? ?? 'general').toLowerCase(),
      targetRole: m['target_role'] as String? ?? 'all',
      timeAgo:    timeAgo,
    );
  }
}

// ── Controller ────────────────────────────────────────────────────────────────

class AdminAnnouncementsController extends GetxController {
  final _db = Supabase.instance.client;

  final announcements = <AdminAnnouncement>[].obs;
  final filtered      = <AdminAnnouncement>[].obs;
  final isLoading     = true.obs;
  final activeTab     = 'All'.obs;

  final tabs = ['All', 'Urgent', 'Warning', 'Info', 'General'];

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      final data = await _db
          .from('announcements')
          .select('id, title, body, type, target_role, created_at')
          .order('created_at', ascending: false);
      announcements.value = (data as List)
          .map((m) => AdminAnnouncement.fromMap(m))
          .toList();
      _applyFilter();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void setTab(String t) {
    activeTab.value = t;
    _applyFilter();
  }

  void _applyFilter() {
    final tab = activeTab.value;
    filtered.value = tab == 'All'
        ? announcements.toList()
        : announcements
            .where((a) => a.type == tab.toLowerCase())
            .toList();
  }

  @override
  Future<void> refresh() => _load();
}

// ── Screen ────────────────────────────────────────────────────────────────────

class AdminAnnouncementsScreen extends StatefulWidget {
  const AdminAnnouncementsScreen({super.key});

  @override
  State<AdminAnnouncementsScreen> createState() =>
      _AdminAnnouncementsScreenState();
}

class _AdminAnnouncementsScreenState
    extends State<AdminAnnouncementsScreen> {
  late final AdminAnnouncementsController c;

  @override
  void initState() {
    super.initState();
    Get.delete<AdminAnnouncementsController>(force: true);
    c = Get.put(AdminAnnouncementsController());
  }

  @override
  void dispose() {
    Get.delete<AdminAnnouncementsController>(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            _SearchAndTabs(c: c),
            Expanded(child: _Body(c: c)),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryBlue,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: Get.back,
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Announcements',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    Text('Manage and broadcast university announcements.',
                        style:
                            TextStyle(color: Colors.white60, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Write Announcement card
          GestureDetector(
            onTap: () => Get.toNamed('/createAnnouncement'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFFF5A623).withValues(alpha: 0.6)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5A623).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit_outlined,
                        color: Color(0xFFF5A623), size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Write an Announcement',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                        Text('Compose and send to selecting groups',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white38, size: 14),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

class _SearchAndTabs extends StatelessWidget {
  final AdminAnnouncementsController c;
  const _SearchAndTabs({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryBlue,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        children: [
          // Search
          TextField(
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search announcements...',
              hintStyle:
                  TextStyle(color: Colors.white.withValues(alpha: 0.45)),
              prefixIcon: Icon(Icons.search,
                  color: Colors.white.withValues(alpha: 0.5), size: 20),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.1),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Tabs
          Obx(() => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: c.tabs.map((t) {
                    final active = c.activeTab.value == t;
                    return GestureDetector(
                      onTap: () => c.setTab(t),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: active
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(t,
                            style: TextStyle(
                              color: active
                                  ? AppColors.primaryBlue
                                  : Colors.white,
                              fontSize: 12,
                              fontWeight: active
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            )),
                      ),
                    );
                  }).toList(),
                ),
              )),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final AdminAnnouncementsController c;
  const _Body({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final list = c.filtered;
      if (list.isEmpty) {
        return const Center(
          child: Text('No announcements yet',
              style: TextStyle(color: Colors.grey)),
        );
      }
      return RefreshIndicator(
        onRefresh: c.refresh,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Text(
                    '${list.length} ANNOUNCEMENT${list.length == 1 ? '' : 'S'}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade500,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: list.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (_, i) => _AdminAnnouncementCard(ann: list[i]),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _AdminAnnouncementCard extends StatelessWidget {
  final AdminAnnouncement ann;
  const _AdminAnnouncementCard({required this.ann});

  Color get _typeColor {
    switch (ann.type) {
      case 'urgent':  return const Color(0xFFEF4444);
      case 'warning': return const Color(0xFFF59E0B);
      case 'info':    return const Color(0xFF3B82F6);
      default:        return const Color(0xFF6B7280);
    }
  }

  String get _typeLabel =>
      ann.type[0].toUpperCase() + ann.type.substring(1);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: _typeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_typeLabel,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _typeColor)),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      ann.targetRole == 'all'
                          ? 'All Students'
                          : ann.targetRole,
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(ann.timeAgo,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade400)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(ann.title,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A2B4A))),
          const SizedBox(height: 4),
          Text(ann.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
