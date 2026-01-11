import 'package:flutter/material.dart';
import 'package:tourio/common/theme/glass_card.dart';

class ExpenseOverview extends StatelessWidget {
  final double used;
  final double limit;

  const ExpenseOverview({super.key, required this.used, required this.limit});

  double get remaining => (limit - used).clamp(0, limit);
  double get percent => (used / limit).clamp(0, 1);

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title
          const Text(
            'Remaining Budget',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              letterSpacing: .4,
            ),
          ),

          const SizedBox(height: 10),

          /// Amount
          RichText(
            text: TextSpan(
              text: '₹${remaining.toString().split('.').first}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
              children: [
                TextSpan(
                  text:
                      '.${remaining.toString().split('.').last == '0' ? '00' : remaining.toString().split('.').last}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white38,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          /// Used / Limit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${used.toStringAsFixed(0)} used',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
              Text(
                'Limit: ₹${limit.toStringAsFixed(0)}',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// Progress
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: percent,
              borderRadius: BorderRadius.circular(99),
              minHeight: 12,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF2AFF57)),
            ),
          ),
        ],
      ),
    );
  }
}
