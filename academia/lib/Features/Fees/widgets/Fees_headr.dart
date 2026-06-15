import 'package:flutter/material.dart';
import 'package:academia/Core/widgets/notification_bell.dart';
import 'package:academia/Core/utilities/colors.dart';
import '../controllers/fees_controller.dart';

class FeesHeader extends StatelessWidget {
  final FeesController ctrl;
  const FeesHeader({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final paidPct = (ctrl.progress * 100).round();
    final currency = ctrl.fees.isNotEmpty ? ctrl.fees.first.currency : 'EGP';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0C4D83), Color(0xFF223F7A)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// Top Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
              ),
              const NotificationBell(),
            ],
          ),

          const SizedBox(height: 12),

          /// Label
          const Text(
            "Outstanding balance",
            style: TextStyle(
              color: AppColors.greytext,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 4),

          /// Amount
          Text(
            ctrl.formattedOutstanding,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 10),

          /// Warning badge (only if there are unpaid fees)
          if (ctrl.dueFees.isNotEmpty && ctrl.nearestDueDate.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xCCFE5263).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD78181)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      color: Color(0xFFDEABAB), size: 14),
                  const SizedBox(width: 6),
                  Text(
                    "Pay before ${ctrl.nearestDueDate} to avoid delays",
                    style: const TextStyle(
                      color: Color(0xFFD9D9D9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 18),

          /// Inner stats card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(title: '0 $currency',          subtitle: 'Minimum due'),
                    const _VerticalDivider(),
                    _StatItem(title: '$paidPct% paid',       subtitle: 'Progress'),
                    const _VerticalDivider(),
                    _StatItem(title: ctrl.formattedTotal,    subtitle: 'Total Fees'),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: ctrl.progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.secondaryYellow),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${ctrl.formattedPaid} of ${ctrl.formattedTotal} paid",
                  style: const TextStyle(
                    color: Color(0xFFE5E7EB),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String subtitle;
  const _StatItem({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter')),
        const SizedBox(height: 2),
        Text(subtitle,
            style: const TextStyle(
                color: Color(0xFFE5E7EB),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter')),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) =>
      Container(height: 30, width: 1, color: Colors.white24);
}
