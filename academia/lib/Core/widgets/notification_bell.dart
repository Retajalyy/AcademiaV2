import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utilities/colors.dart';

// ── Controller ────────────────────────────────────────────────────────────────

class NotificationController extends GetxController {
  final _db = Supabase.instance.client;
  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUnread();
  }

  Future<void> fetchUnread() async {
    try {
      final uid = _db.auth.currentUser?.id;
      if (uid == null) return;

      final all = await _db.from('announcements').select('id');
      final reads = await _db
          .from('announcement_reads')
          .select('announcement_id')
          .eq('user_id', uid);

      final allIds   = (all   as List).map((a) => a['id']               as int).toSet();
      final readIds  = (reads as List).map((r) => r['announcement_id']  as int).toSet();

      unreadCount.value = allIds.difference(readIds).length;
    } catch (_) {
      unreadCount.value = 0;
    }
  }
}

// ── Widget ────────────────────────────────────────────────────────────────────

class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  static NotificationController get _c =>
      Get.put(NotificationController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    final c = _c;
    return GestureDetector(
      onTap: () async {
        await Get.toNamed('/announcements');
        c.fetchUnread();
      },
      child: Obx(() => Stack(
            clipBehavior: Clip.none,
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              if (c.unreadCount.value > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryYellow,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          )),
    );
  }
}
