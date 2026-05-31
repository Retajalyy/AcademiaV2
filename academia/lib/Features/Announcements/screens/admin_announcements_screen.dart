import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../Core/utilities/colors.dart';
import '../../../Core/widgets/side_menu.dart';
import 'create_announcement_screen.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class AdminAnnouncement {
  final int    id;
  final String title;
  final String body;
  final String type;
  final String targetRole;
  final String timeAgo;

  final int seenCount;

  const AdminAnnouncement({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.targetRole,
    required this.timeAgo,
    required this.seenCount,
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
    final reads = m['announcement_reads'] as List? ?? [];
    int seenCount = 0;
    if (reads.isNotEmpty) {
      final countVal = reads[0]['count'];
      if (countVal is int) {
        seenCount = countVal;
      } else if (countVal is String) {
        seenCount = int.tryParse(countVal) ?? 0;
      }
    }

    return AdminAnnouncement(
      id:         m['id']          as int,
      title:      m['title']       as String? ?? '',
      body:       m['body']        as String? ?? '',
      type:       (m['type']       as String? ?? 'general').toLowerCase(),
      targetRole: m['target_role'] as String? ?? 'all',
      timeAgo:    timeAgo,
      seenCount:  seenCount,
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
          .select('id, title, body, type, target_role, created_at, announcement_reads(count)')
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
      drawer: const SideMenu(activeItem: 'Announcements'),
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            _WriteCard(),
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
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Row(
        children: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.white,size: 40,),
              padding: EdgeInsets.zero,
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Announcements',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold)),
                Text('Manage and broadcast university announcements.',
                    style: TextStyle(color: Color(0XFFCCCCCC), fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WriteCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: GestureDetector(
        onTap: () => CreateAnnouncementScreen.show(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(20),
            
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color:  Color(0xFFFFFFFF).withOpacity(0.20).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit_document,
                    color: AppColors.accentAI, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Write an Announcement',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    Text('Compose and deliver to selected groups',
                        style: TextStyle(
                            color: Color(0xFFDEDEDE), fontSize: 11.5)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Color(0xFFDEDEDE), size: 19),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchAndTabs extends StatelessWidget {
  final AdminAnnouncementsController c;
  const _SearchAndTabs({required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search announcements...',
              hintStyle: const TextStyle(color: Color(0xFFB3B3B3), fontSize: 16),
              prefixIcon: const Icon(Icons.search,
                  color: Color(0xFF9CA3AF), size: 25),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Obx(() => Row(
                children: c.tabs.map((t) {
                  final active = c.activeTab.value == t;
                  return GestureDetector(
                    onTap: () => c.setTab(t),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: active ? AppColors.primaryBlue : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: active
                              ? AppColors.primaryBlue
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Text(t,
                          style: TextStyle(
                            color: active
                                ? Colors.white
                                : AppColors.smalltext,
                            fontSize: 13,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w500,
                          )),
                    ),
                  );
                }).toList(),
              )),
        ),
      ],
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
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.smalltext,
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
      case 'urgent':  return AppColors.fail;
      case 'warning': return AppColors.accentAI;
      case 'info':    return AppColors.accentProgramming1;
      default:        return const Color(0xFF757272);
    }
  }

  IconData get _typeIcon {
    switch (ann.type) {
      case 'urgent':  return Icons.warning_amber_rounded;
      case 'warning': return Icons.error_outline_rounded;
      case 'info':    return Icons.info_outline_rounded;
      default:        return Icons.campaign_outlined;
    }
  }

  String get _typeLabel =>
      ann.type[0].toUpperCase() + ann.type.substring(1);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      
      ),
      child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type badge with icon
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: _typeColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_typeIcon, color: _typeColor, size: 16),
                          const SizedBox(width: 4),
                          Text(_typeLabel,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _typeColor)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Title
                    Text(ann.title,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black)),
                    const SizedBox(height: 4),
                    // Body
                    Text(ann.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14,
                            color: AppColors.smalltext,
                            height: 1.4)),
                    const SizedBox(height: 10),
                    // Divider
                    Divider(height: 1, color: Colors.grey.shade100),
                    const SizedBox(height: 8),
                    // Bottom row: seen · time · target
                    Row(
                      children: [
                        Icon(Icons.remove_red_eye_outlined,
                            size: 17, color: AppColors.smalltext),
                        const SizedBox(width: 4),
                        Text('${ann.seenCount} seen',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.smalltext)),
                        const SizedBox(width: 12),
                        Icon(Icons.access_time_rounded,
                            size: 17, color: AppColors.smalltext),
                        const SizedBox(width: 4),
                        Text(ann.timeAgo,
                            style: TextStyle(
                                fontSize: 13, color: AppColors.smalltext)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F0FE),
                            borderRadius: BorderRadius.circular(7),
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
                      ],
                    ),
                  ],
                ),
      ),
    );
  }
}
