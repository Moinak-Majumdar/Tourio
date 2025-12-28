import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tourio/models/expense_model.dart';
import 'package:tourio/models/tour_model.dart';
import 'package:tourio/screens/expense/widget/category_config.dart';

class DailySnapshotCard extends StatefulWidget {
  final List<DailyExpenseSummary> summaries;
  final TourModel tour;

  const DailySnapshotCard({
    super.key,
    required this.summaries,
    required this.tour,
  });

  @override
  State<DailySnapshotCard> createState() => _DailySnapshotCardState();
}

class _DailySnapshotCardState extends State<DailySnapshotCard> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = _initialIndex(widget.summaries);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final day = widget.summaries[_index];
    final prev = _index > 0 ? widget.summaries[_index - 1] : null;

    final spent = day.totalAmount;
    final diff = prev == null ? null : spent - prev.totalAmount;

    ExpenseModel? mostExpensive;

    for (final e in day.items) {
      if (mostExpensive == null || e.amount > mostExpensive.amount) {
        mostExpensive = e;
      }
    }

    final budgetPerDay = widget.tour.budget != null
        ? widget.tour.budget! / widget.tour.totalDays
        : 0;

    final progress = budgetPerDay != 0 ? spent / budgetPerDay : 0.toDouble();

    final daySpentDiff = budgetPerDay != 0 ? (budgetPerDay - spent) : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------- Header ----------------
          Row(
            children: [
              if (daySpentDiff != null)
                Text(
                  daySpentDiff >= 0
                      ? 'Rs.${daySpentDiff.toStringAsFixed(0)} remaining'
                      : 'Rs.${daySpentDiff.abs().toStringAsFixed(0)} over spent',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: daySpentDiff >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              if (daySpentDiff == null)
                Text(
                  'Daily report',
                  style: TextStyle(
                    color: scheme.outline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const Spacer(),
              _daySwitcher(scheme),
            ],
          ),

          const SizedBox(height: 18),

          // ---------------- Amount ----------------
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹${spent.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.w800,
                      color: scheme.secondary,
                    ),
                  ),

                  // ---------------- Delta ----------------
                  if (spent == 0)
                    Text(
                      'No spending this day',
                      style: TextStyle(color: scheme.outline),
                    )
                  else if (diff != null)
                    Row(
                      children: [
                        Icon(
                          diff >= 0
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          size: 18,
                          color: diff >= 0
                              ? Colors.redAccent
                              : Colors.greenAccent,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          diff >= 0
                              ? '+₹${diff.toStringAsFixed(0)} vs yesterday'
                              : '-₹${diff.abs().toStringAsFixed(0)} vs yesterday',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: diff >= 0
                                ? Colors.redAccent
                                : Colors.greenAccent,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const Spacer(),
              if (spent > 0)
                _ArcGauge(
                  progress: progress,
                  color: Colors.red,
                  size: 120,
                  stroke: 12,
                ),
            ],
          ),

          if (mostExpensive != null)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Icon(
                    expenseCategoryMap[mostExpensive.category]!.icon,
                    size: 24,
                    color: expenseCategoryMap[mostExpensive.category]!.color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Most spent: ${mostExpensive!.title}  - ₹${mostExpensive.amount.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ---------------- Day Switcher ----------------

  Widget _daySwitcher(ColorScheme scheme) {
    final df = DateFormat('dd MMM');

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: _index > 0 ? () => setState(() => _index--) : null,
        ),
        Text(
          df.format(widget.summaries[_index].date),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed: _index < widget.summaries.length - 1
              ? () => setState(() => _index++)
              : null,
        ),
      ],
    );
  }
}

int _initialIndex(List<DailyExpenseSummary> data) {
  if (data.isEmpty) return 0;

  final today = DateTime.now();
  final start = data.first.date;
  final end = data.last.date;

  if (today.isBefore(start)) return 0;
  if (today.isAfter(end)) return data.length - 1;

  int low = 0, high = data.length - 1;

  while (low <= high) {
    final mid = (low + high) >> 1;
    final d = data[mid].date;

    if (_sameDay(d, today)) return mid;
    if (d.isBefore(today)) {
      low = mid + 1;
    } else {
      high = mid - 1;
    }
  }

  // nearest lower valid day (most recent spending day)
  return high.clamp(0, data.length - 1);
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

class _ArcGauge extends StatelessWidget {
  final double progress; // 0.0 → 1.0
  final Color color;
  final double size;
  final double stroke;

  const _ArcGauge({
    required this.progress,
    required this.color,
    this.size = 56,
    this.stroke = 6,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final spentPercentage = (progress.clamp(0.0, 1.0) * 100.0).toStringAsFixed(
      0,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            Text(
              '$spentPercentage%',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: scheme.secondary,
              ),
            ),
            Text('Used', style: TextStyle(color: scheme.outline, fontSize: 14)),
          ],
        ),
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _ArcGaugePainter(
              progress: progress.clamp(0.0, 1.0),
              color: color,
              stroke: stroke,
            ),
          ),
        ),
      ],
    );
  }
}

class _ArcGaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double stroke;

  _ArcGaugePainter({
    required this.progress,
    required this.color,
    required this.stroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    final basePaint = Paint()
      ..color = Colors.grey[700]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final valuePaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xfff89b29), const Color(0xffff0f7b)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = -3.14 * 1.2;
    const sweepAngle = 3.14 * 1.4;

    // base arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      basePaint,
    );

    // value arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * progress,
      false,
      valuePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcGaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
