import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ExpenseCategoryConfig {
  final IconData icon;
  final Color? color;

  const ExpenseCategoryConfig({required this.icon, this.color});
}

const expenseCategoryList = [
  'Food',
  'Travel',
  'Hotel',
  'Shopping',
  'Tickets',
  'Emergency',
  'Other',
];
const Map<String, ExpenseCategoryConfig> expenseCategoryMap = {
  'Food': ExpenseCategoryConfig(
    icon: LucideIcons.utensils,
    color: Color(0xFFFFC94A),
  ),

  'Travel': ExpenseCategoryConfig(
    icon: LucideIcons.bus,
    color: Color(0xFF64B5F6),
  ),

  'Hotel': ExpenseCategoryConfig(icon: Icons.hotel, color: Color(0xFFB39DDB)),

  'Shopping': ExpenseCategoryConfig(
    icon: LucideIcons.shoppingBag,
    color: Color(0xFFF06292),
  ),

  'Tickets': ExpenseCategoryConfig(
    icon: LucideIcons.ticket,
    color: Color(0xFF80CBC4),
  ),

  'Emergency': ExpenseCategoryConfig(icon: Icons.sos, color: Color(0xFFEF5350)),

  'Other': ExpenseCategoryConfig(
    icon: LucideIcons.moreHorizontal,
    color: Color(0xFF90A4AE),
  ),
};
