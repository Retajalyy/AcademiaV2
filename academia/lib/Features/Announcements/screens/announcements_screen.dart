import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../Core/utilities/colors.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class AnnouncementModel {
  final int    id;
  final String title;
  final String body;
  final String type;       // 'urgent' | 'info' | 'general' | 'warning'
  final String timeAgo;
  bool         isRead;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timeAgo,
    required this.isRead,
  });

  factory AnnouncementModel.fromMap(Map<String, dynamic> m, Set<int> readIds) {
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

    return AnnouncementModel(
      id:      m['id'] as int,
      title:   m['title']  as String? ?? '',
      body:    m['body']   as String? ?? '',
      type:    (m['type']  as String? ?? 'general').toLowerCase(),
      timeAgo: timeAgo,
      isRead:  readIds.contains(m['id'] as int),
    );
  }
}

// ── Controller ────────────────────────────────────────────────────────────────

class AnnouncementsController extends GetxController {
  final _db     = Supabase.instance.client;
  String get _uid => _db.auth.currentUser!.id;

  final all        = <AnnouncementModel>[].obs;
  final filtered   = <AnnouncementModel>[].obs;
  final isLoading  = true.obs;
  final activeTab  = 'All'.obs;
  final searchText = ''.obs;
  final unreadCount = 0.obs;

  final _tabs = ['All', 'Unread', 'Urgent', 'Warning', 'Info', 'General'];
  List<String> get tabs => _tabs;

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
          .select('id, title, body, type, created_at')
          .order('created_at', ascending: false);

      final reads = await _db
          .from('announcement_reads')
          .select('announcement_id')
          .eq('user_id', _uid);

      final readIds = (reads as List)
          .map((r) => r['announcement_id'] as int)
          .toSet();

      all.value = (data as List)
          .map((m) => AnnouncementModel.fromMap(m, readIds))
          .toList();

      unreadCount.value = all.where((a) => !a.isRead).length;
      _applyFilter();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load announcements: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void setTab(String tab) {
    activeTab.value = tab;
    _applyFilter();
  }

  void onSearch(String q) {
    searchText.value = q;
    _applyFilter();
  }

  void _applyFilter() {
    var list = all.toList();
    final tab = activeTab.value;
    if (tab == 'Unread') {
      list = list.where((a) => !a.isRead).toList();
    } else if (tab != 'All') {
      list = list.where((a) => a.type == tab.toLowerCase()).toList();
    }
    final q = searchText.value.toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((a) =>
          a.title.toLowerCase().contains(q) ||
          a.body.toLowerCase().contains(q)).toList();
    }
    filtered.value = list;
  }

  Future<void> markRead(AnnouncementModel ann) async {
    if (ann.isRead) return;
    try {
      await _db.from('announcement_reads').upsert({
        'announcement_id': ann.id,
        'user_id': _uid,
      });
      ann.isRead = true;
      unreadCount.value = all.where((a) => !a.isRead).length;
      all.refresh();
      _applyFilter();
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    final unread = all.where((a) => !a.isRead).toList();
    if (unread.isEmpty) return;
    try {
      await _db.from('announcement_reads').upsert(
        unread.map((a) => {'announcement_id': a.id, 'user_id': _uid}).toList(),
      );
      for (final a in unread) { a.isRead = true; }
      unreadCount.value = 0;
      all.refresh();
      _applyFilter();
    } catch (_) {}
  }

  @override
  Future<void> refresh() => _load();
}

// ── Screen ────────────────────────────────────────────────────────────────────

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  late final AnnouncementsController c;

  @override
  void initState() {
    super.initState();
    Get.delete<AnnouncementsController>(force: true);
    c = Get.put(AnnouncementsController());
  }

  @override
  void dispose() {
    Get.delete<AnnouncementsController>(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: SafeArea(
        child: Column(
          children: [
            _Header(c: c),
            _SearchBar(c: c),
            _TabBar(c: c),
            Expanded(child: _Body(c: c)),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final AnnouncementsController c;
  const _Header({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: Get.back,
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Announcements',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'View all updates from your university',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Search Bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final AnnouncementsController c;
  const _SearchBar({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryBlue,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: TextField(
        onChanged: c.onSearch,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search announcements...',
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
          prefixIcon: Icon(Icons.search,
              color: Colors.white.withValues(alpha: 0.6), size: 20),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.12),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// ── Tab Bar ───────────────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  final AnnouncementsController c;
  const _TabBar({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryBlue,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: Obx(() => Row(
              children: c.tabs.map((tab) {
                final active = c.activeTab.value == tab;
                return GestureDetector(
                  onTap: () => c.setTab(tab),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tab,
                      style: TextStyle(
                        color: active
                            ? AppColors.primaryBlue
                            : Colors.white,
                        fontSize: 12,
                        fontWeight: active
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final AnnouncementsController c;
  const _Body({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final list = c.filtered;

      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.notifications_off_outlined,
                  size: 52, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text('No announcements',
                  style: TextStyle(
                      fontSize: 15, color: Colors.grey.shade400)),
            ],
          ),
        );
      }

      return Column(
        children: [
          // Count row
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                GestureDetector(
                  onTap: c.markAllRead,
                  child: const Text(
                    'Mark all as read',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: c.refresh,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: list.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (_, i) =>
                    _AnnouncementCard(ann: list[i], c: c),
              ),
            ),
          ),
        ],
      );
    });
  }
}

// ── Announcement Card ─────────────────────────────────────────────────────────

class _AnnouncementCard extends StatelessWidget {
  final AnnouncementModel ann;
  final AnnouncementsController c;
  const _AnnouncementCard({required this.ann, required this.c});

  Color get _typeColor {
    switch (ann.type) {
      case 'urgent':  return const Color(0xFFEF4444);
      case 'warning': return const Color(0xFFF59E0B);
      case 'info':    return const Color(0xFF3B82F6);
      default:        return const Color(0xFF6B7280);
    }
  }

  String get _typeLabel => ann.type[0].toUpperCase() + ann.type.substring(1);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ann.isRead
              ? Colors.white
              : const Color(0xFFEEF3FF),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: ann.isRead
              ? null
              : Border.all(
                  color: AppColors.primaryBlue.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type badge + time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (!ann.isRead)
                      Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: _typeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            ann.type == 'urgent'
                                ? Icons.warning_amber_rounded
                                : ann.type == 'warning'
                                    ? Icons.error_outline_rounded
                                    : ann.type == 'info'
                                        ? Icons.info_outline_rounded
                                        : Icons.campaign_outlined,
                            color: _typeColor,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _typeLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _typeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  ann.timeAgo,
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              ann.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A2B4A),
              ),
            ),

            const SizedBox(height: 4),

            Text(
              ann.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    c.markRead(ann);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailSheet(ann: ann),
    );
  }
}

// ── Detail Bottom Sheet ───────────────────────────────────────────────────────

class _DetailSheet extends StatelessWidget {
  final AnnouncementModel ann;
  const _DetailSheet({required this.ann});

  Color get _typeColor {
    switch (ann.type) {
      case 'urgent':  return const Color(0xFFEF4444);
      case 'warning': return const Color(0xFFF59E0B);
      case 'info':    return const Color(0xFF3B82F6);
      default:        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _typeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    ann.type[0].toUpperCase() + ann.type.substring(1),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _typeColor,
                    ),
                  ),
                ),
                Text(ann.timeAgo,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade400)),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              ann.title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2B4A),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              ann.body,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
