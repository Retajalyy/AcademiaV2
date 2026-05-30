import 'package:flutter/material.dart';

enum ServiceStatus { none, opened, closed, pending }

class ServiceItemModel {
  final String id;
  final String title;
  final String subtitle;
  final String iconAsset;
  final IconData? iconData;     // fallback when no SVG is available
  final Color accentColor;
  final Color accentBackground;
  final ServiceStatus status;
  final String? route;

  const ServiceItemModel({
    required this.id,
    required this.title,
    required this.subtitle,
    this.iconAsset = '',
    this.iconData,
    required this.accentColor,
    required this.accentBackground,
    this.status = ServiceStatus.none,
    this.route,
  });
}

class ServiceSectionModel {
  final String title;
  final List<ServiceItemModel> items;

  const ServiceSectionModel({
    required this.title,
    required this.items,
  });
}