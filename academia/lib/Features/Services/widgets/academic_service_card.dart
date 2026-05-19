import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/service_item_model.dart';

class AcademicServiceCard extends StatelessWidget {
  final ServiceItemModel item;
  final VoidCallback onTap;

  const AcademicServiceCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            top: BorderSide(
              color: item.accentColor,
              width: 3.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        // Reduced padding slightly to help with the gap
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // Changed to start to control the gap manually instead of stretching
          mainAxisAlignment: MainAxisAlignment.start, 
          children: [
            // 1. Bigger Icon Container
            Container(
              width: 52, // Increased from 42
              height: 52, // Increased from 42
              decoration: BoxDecoration(
                color: item.accentBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12), // Adjusted padding for larger icon
              child: SvgPicture.asset(
                item.iconAsset,
                colorFilter: ColorFilter.mode(
                  item.accentColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
            
            // Adjusted Gap: Controlled spacing instead of Spacer()
            const SizedBox(height: 24), 

            // 2. Title and Chevron Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2B407D),
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 14,
                  color: const Color(0xFF2B407D).withValues(alpha: 0.7),
                ),
              ],
            ),

            const SizedBox(height: 2),

            // 3. Subtitle
            Text(
              item.subtitle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // 4. Status badge (only when not none)
            if (item.status != ServiceStatus.none) ...[
              const SizedBox(height: 8),
              _StatusBadge(status: item.status),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ServiceStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      ServiceStatus.opened  => ('Opened',  const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
      ServiceStatus.closed  => ('Closed',  const Color(0xFFFFEBEE), const Color(0xFFEF4444)),
      ServiceStatus.pending => ('Not Opened Yet', const Color(0xFFFFF8E1), const Color(0xFFF59E0B)),
      ServiceStatus.none    => ('',        Colors.transparent,       Colors.transparent),
    };

    if (label.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}