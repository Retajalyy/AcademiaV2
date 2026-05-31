import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String   title;
  final String   value;
  final String   subtitle;
  final double   height;

  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(w * 0.033),
      decoration: BoxDecoration(
        color:        Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(w * 0.038),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:  MainAxisAlignment.spaceBetween,
        children: [
          // ── Icon + Title row ─────────────────────────────────────────
          Row(
            children: [
              Container(
                width:  w * 0.08,
                height: w * 0.08,
                decoration: BoxDecoration(
                  color:        Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(w * 0.02),
                ),
                child: Icon(icon, color: Colors.white, size: w * 0.048),
              ),
              SizedBox(width: w * 0.018),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color:      Colors.white.withValues(alpha: 0.85),
                    fontSize:   w * 0.046,
                    fontWeight: FontWeight.w500,
                    height:     1.2,
                  ),
                ),
              ),
            ],
          ),

          // ── Value + Subtitle ─────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit:       BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(
                    color:      Colors.white,
                    fontSize:   w * 0.056,
                    fontWeight: FontWeight.w700,
                    height:     1,
                  ),
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color:      Colors.white.withValues(alpha: 0.75),
                  fontSize:   w * 0.039,
                  fontWeight: FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
