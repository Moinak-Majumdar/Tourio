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
  'Food': ExpenseCategoryConfig(icon: LucideIcons.utensils),
  'Travel': ExpenseCategoryConfig(icon: LucideIcons.bus),
  'Hotel': ExpenseCategoryConfig(icon: Icons.hotel),
  'Shopping': ExpenseCategoryConfig(icon: LucideIcons.shoppingBag),
  'Tickets': ExpenseCategoryConfig(icon: LucideIcons.ticket),
  'Emergency': ExpenseCategoryConfig(icon: Icons.sos),
  'Other': ExpenseCategoryConfig(icon: LucideIcons.moreHorizontal),
};
