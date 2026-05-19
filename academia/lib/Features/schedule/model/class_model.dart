import 'package:flutter/material.dart';

class ClassModel {
  final String title;
  final String room;
  final String instructor;
  final String startTime;
  final String endTime;
  final String type;
  final Color accentColor;

  ClassModel({
    required this.title,
    required this.room,
    required this.instructor,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.accentColor,
  });
}
