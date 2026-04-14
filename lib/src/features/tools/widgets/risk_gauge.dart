import 'dart:math' as math;
import 'package:flutter/material.dart';

class RiskGauge extends StatefulWidget {
  final double percentage; // 0.0 to 1.0 (Higher is BETTER compliance, lower risk)
  final double size;

  const RiskGauge({
    super.key,
    required this.percentage,
    this.size = 200,
  });

  @override
  State<RiskGauge> createState() => _RiskGaugeState();
}

class _RiskGaugeState extends State<RiskGauge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.percentage).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size / 2 + 20),
          painter: _GaugePainter(_animation.value),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;

  _GaugePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 20);
    final radius = math.min(size.width / 2, size.height - 20);
    final strokeWidth = 15.0;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Dibuja el fondo del arco (Gris sutil)
    final bgPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, math.pi, math.pi, false, bgPaint);

    // Mapa de colores segun valor (Rojo -> Naranja -> Verde)
    // Nota: El valor representa CUMPLIMIENTO (1.0 es verde)
    Color gaugeColor;
    if (value < 0.33) {
      gaugeColor = Colors.red;
    } else if (value < 0.66) {
      gaugeColor = Colors.orange;
    } else {
      gaugeColor = Colors.green;
    }

    final activePaint = Paint()
      ..color = gaugeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, math.pi, math.pi * value, false, activePaint);

    // Dibuja la aguja
    final needlePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final angle = math.pi + (math.pi * value);
    final needleLength = radius - 10;
    final needleEnd = Offset(
      center.dx + needleLength * math.cos(angle),
      center.dy + needleLength * math.sin(angle),
    );

    canvas.drawLine(center, needleEnd, Paint()..strokeWidth = 3..color = Colors.black..strokeCap = StrokeCap.round);
    canvas.drawCircle(center, 6, needlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
