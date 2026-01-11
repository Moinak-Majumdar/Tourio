import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;
  final double width;
  final EdgeInsets margin;
  final List<BoxShadow>? boxShadow;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 22,
    this.padding = const EdgeInsets.all(24),
    this.width = double.infinity,
    this.margin = EdgeInsets.zero,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: margin,
      decoration: BoxDecoration(boxShadow: boxShadow),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            // 2️⃣ GREEN GLOW ENERGY
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topRight,
                      radius: 1.8,
                      colors: [
                        Color(0xFF2AFF57).withValues(alpha: 0.65),
                        Color(0xFF0f172a),
                        Color(0xFF020617),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 3️⃣ GLASS FROST LAYER
            Container(
              width: width,
              padding: padding,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0f172a).withValues(alpha: 0.55),
                    Color(0xFF020617).withValues(alpha: 0.55),
                  ],
                ),
                border: Border(
                  right: BorderSide(
                    color: Colors.white.withAlpha(20),
                    width: 0.5,
                  ),
                  bottom: BorderSide(
                    color: Colors.white.withAlpha(20),
                    width: 0.5,
                  ),
                ),
              ),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
