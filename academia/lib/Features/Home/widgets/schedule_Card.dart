
import 'package:flutter/material.dart';
import 'package:academia/Features/Home/models/schedule_item_model.dart';

class ScheduleCard extends StatelessWidget {
  final ScheduleItem item;
  final Color accentColor;
  final bool isLast; // Added to handle the timeline line length

  const ScheduleCard({
    required this.item,
    required this.accentColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      // Ensures the vertical line matches the card height
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Time Column
          Column(
            children: [
              Text(
                item.time.split(" - ")[0], // Start time
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                item.time.split(" - ")[1], // End time
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              // Vertical Timeline Line
              Expanded(
                child: Container(
                  width: 1,
                  margin: EdgeInsets.symmetric(vertical: 4),
                  color: isLast ? Colors.transparent : Colors.grey[300],
                ),
              ),
            ],
          ),
          SizedBox(width: 15),

          // 2. The Main Class Card
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: 15),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Color Indicator Bar
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: 12),
                  // Text Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D4B94),
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "${item.location} . ${item.instructor}",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tag (Lecture/Section)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.type,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
