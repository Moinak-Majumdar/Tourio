import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
    final i = _initialIndex(widget.summaries);
    _index = i;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final day = widget.summaries[_index];
    final prev = _index > 0 ? widget.summaries[_index - 1] : null;

    final spent = day.totalAmount;
    final diffFromLastDay = prev == null ? null : spent - prev.totalAmount;

    ExpenseModel? mostExpensive;

    for (final e in day.items) {
      if (mostExpensive == null || e.amount > mostExpensive.amount) {
        mostExpensive = e;
      }
    }

    final budgetPerDay = widget.tour.budget != null
        ? widget.tour.budget! / widget.tour.totalDays
        : 0.0;

    final progress = budgetPerDay != 0 ? spent / budgetPerDay : 0.0;

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
              _DailySpendStatus(
                spent: spent,
                budgetPerDay: budgetPerDay,
                day: day.date,
                progress: progress,
                diff: (budgetPerDay - spent).abs().toStringAsFixed(0),
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
                  else if (diffFromLastDay != null)
                    Row(
                      children: [
                        Icon(
                          diffFromLastDay >= 0
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          size: 18,
                          color: diffFromLastDay >= 0
                              ? Colors.redAccent
                              : Colors.greenAccent,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          diffFromLastDay >= 0
                              ? '+ ₹${diffFromLastDay.toStringAsFixed(0)} vs yesterday'
                              : '- ₹${diffFromLastDay.abs().toStringAsFixed(0)} vs yesterday',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: diffFromLastDay >= 0
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
                )
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 24.0, 0.0),
                  child: Icon(
                    Icons.self_improvement_rounded,
                    size: 100,
                    color: scheme.secondary,
                  ),
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
                    expenseCategoryMap[mostExpensive.category]?.icon ??
                        LucideIcons.moreHorizontal,
                    size: 24,
                    color:
                        expenseCategoryMap[mostExpensive.category]?.color ??
                        Color(0xFF90A4AE),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Most spent: ${mostExpensive.title}  - ₹${mostExpensive.amount.toStringAsFixed(0)}',
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

enum _DayKind { past, today, future }

class _Status {
  final String text;
  final Color color;
  final IconData icon;

  const _Status({required this.text, required this.color, required this.icon});
}

class _DailySpendStatus extends StatelessWidget {
  final double spent;
  final double budgetPerDay;
  final DateTime day;
  final double progress;
  final String diff;

  const _DailySpendStatus({
    required this.spent,
    required this.budgetPerDay,
    required this.day,
    required this.progress,
    required this.diff,
  });

  _DayKind _classifyDay(DateTime d) {
    final now = DateTime.now();
    if (_sameDay(d, now)) return _DayKind.today;
    if (d.isBefore(now)) return _DayKind.past;
    return _DayKind.future;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final status = _resolveStatus(scheme);

    return SizedBox(
      width: 150,
      child: Row(
        children: [
          Icon(status.icon, size: 30, color: status.color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              status.text,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: status.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _Status _resolveStatus(ColorScheme scheme) {
    final kind = _classifyDay(day);

    if (budgetPerDay <= 0) {
      return _Status(
        text: kind == _DayKind.today ? 'No daily budget set' : 'Daily snapshot',
        color: scheme.outline,
        icon: Icons.insights_rounded,
      );
    }

    if (spent == 0) {
      if (kind == _DayKind.future) {
        return _Status(
          text: 'Planned day',
          color: scheme.outline,
          icon: Icons.schedule,
        );
      }
      return _Status(
        text: kind == _DayKind.today ? 'No spending yet' : 'No spending',
        color: scheme.outline,
        icon: Icons.self_improvement_rounded,
      );
    }

    // 🟢 UNDER BUDGET
    if (progress < 0.9) {
      return _Status(
        text: kind == _DayKind.today
            ? '₹$diff available today'
            : 'Under budget by ₹$diff',
        color: const Color(0xff2ECC71),
        icon: Icons.verified_rounded,
      );
    }

    // 🟡 ON TRACK
    if (progress <= 1.0) {
      return _Status(
        text: kind == _DayKind.today ? 'Right on track' : 'On budget',
        color: scheme.primary,
        icon: LucideIcons.checkCircle,
      );
    }

    // 🟠 WARNING
    if (progress <= 1.1) {
      return _Status(
        text: kind == _DayKind.today
            ? 'Almost out of today’s budget'
            : 'Slightly over budget',
        color: const Color(0xffF39C12),
        icon: Icons.warning,
      );
    }

    // 🔴 DANGER
    return _Status(
      text: kind == _DayKind.today
          ? 'Over limit by ₹$diff'
          : 'Exceeded budget by ₹$diff',
      color: const Color(0xffE74C3C),
      icon: Icons.error,
    );
  }
}

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
        colors: [
          const Color(0xff40E0D0),
          const Color(0xffFF8C00),
          const Color(0xffFF0080),
        ],
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
