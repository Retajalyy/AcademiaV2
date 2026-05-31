import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../Core/utilities/colors.dart';
import '../../../Core/widgets/side_menu.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class AdminAnnouncement {
  final int    id;
  final String title;
  final String body;
  final String type;
  final String targetRole;
  final String timeAgo;
  final int    seenCount;

  const AdminAnnouncement({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.targetRole,
    required this.timeAgo,
    this.seenCount = 0,
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
      seenCount:  (m['seen_count'] as int?) ?? 0,
    );
  }
}

// ── Controller ────────────────────────────────────────────────────────────────

class AdminAnnouncementsController extends GetxController {
  final _db = Supabase.instance.client;

  final announcements = <AdminAnnouncement>[].obs;
  final isLoading     = true.obs;
  final activeTab     = 'All'.obs;
  final searchQuery   = ''.obs;

  final tabs = ['All', 'Urgent', 'Info', 'Warning', 'General'];

  List<AdminAnnouncement> get filtered {
    final tab = activeTab.value;
    final q   = searchQuery.value.toLowerCase();
    return announcements.where((a) {
      final matchTab    = tab == 'All' || a.type == tab.toLowerCase();
      final matchSearch = q.isEmpty ||
          a.title.toLowerCase().contains(q) ||
          a.body.toLowerCase().contains(q);
      return matchTab && matchSearch;
    }).toList();
  }

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
    } catch (e) {
      Get.snackbar('Error', 'Failed to load: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void setTab(String t) => activeTab.value = t;

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
      backgroundColor: const Color(0xFFF0F4FA),
      drawer: const SideMenu(activeItem: 'Announcements'),
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            Expanded(child: _Body(c: c)),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryBlue,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Menu + title row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Builder(
                builder: (ctx) => GestureDetector(
                  onTap: () => Scaffold.of(ctx).openDrawer(),
                  child: const Padding(
                    padding: EdgeInsets.only(top: 4, right: 14),
                    child: Icon(Icons.menu, color: Colors.white, size: 28),
                  ),
                ),
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Announcements',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Manage and broadcast university\nannouncements',
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Write Announcement card
          GestureDetector(
            onTap: () => Get.toNamed('/createAnnouncement'),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF0C4D83),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit_outlined,
                        color: Color(0xFFFFC258), size: 22),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Write an Announcement',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Compose and deliver to selected groups',
                          style: TextStyle(
                              color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white38, size: 15),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Body ─────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final AdminAnnouncementsController c;
  const _Body({required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: TextField(
            onChanged: (v) => c.searchQuery.value = v,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search announcements...',
              hintStyle:
                  const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
              prefixIcon: const Icon(Icons.search,
                  color: Color(0xFF9CA3AF), size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Filter chips
        Obx(() => SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: c.tabs.map((t) {
                  final active = c.activeTab.value == t;
                  return GestureDetector(
                    onTap: () => c.setTab(t),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primaryBlue
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: active
                              ? AppColors.primaryBlue
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Text(
                        t,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: active
                              ? Colors.white
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            )),

        const SizedBox(height: 4),

        // List
        Expanded(
          child: Obx(() {
            if (c.isLoading.value) {
              return const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primaryBlue));
            }
            final list = c.filtered;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text(
                    '${list.length} ANNOUNCEMENT${list.length == 1 ? '' : 'S'}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6B7280),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                Expanded(
                  child: list.isEmpty
                      ? Center(
                          child: Text(
                            'No announcements found',
                            style: TextStyle(
                                color: Colors.grey.shade400, fontSize: 14),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: c.refresh,
                          child: ListView.separated(
                            padding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            itemCount: list.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, i) =>
                                _AnnouncementCard(ann: list[i]),
                          ),
                        ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}

// ── Announcement Card ─────────────────────────────────────────────────────────

class _AnnouncementCard extends StatelessWidget {
  final AdminAnnouncement ann;
  const _AnnouncementCard({required this.ann});

  Color get _typeColor {
    switch (ann.type) {
      case 'urgent':  return const Color(0xFFEF4444);
      case 'warning': return const Color(0xFFF59E0B);
      case 'info':    return const Color(0xFF3B82F6);
      default:        return const Color(0xFF6B7280);
    }
  }

  IconData get _typeIcon {
    switch (ann.type) {
      case 'urgent':  return Icons.notification_important_outlined;
      case 'warning': return Icons.error_outline_rounded;
      case 'info':    return Icons.info_outline_rounded;
      default:        return Icons.notifications_outlined;
    }
  }

  String get _typeLabel =>
      ann.type[0].toUpperCase() + ann.type.substring(1);

  String get _audienceLabel =>
      ann.targetRole == 'all' ? 'All Students' : ann.targetRole;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_typeIcon, color: _typeColor, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        _typeLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _typeColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Title
                Text(
                  ann.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2B4A),
                  ),
                ),
                const SizedBox(height: 4),

                // Body
                Text(
                  ann.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade100),

          // Bottom row
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                if (ann.seenCount > 0) ...[
                  Icon(Icons.visibility_outlined,
                      size: 14, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text(
                    '${_fmt(ann.seenCount)} seen',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const SizedBox(width: 12),
                ],
                Icon(Icons.access_time_outlined,
                    size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(
                  ann.timeAgo,
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade500),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0FE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _audienceLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                    ),
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
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}
