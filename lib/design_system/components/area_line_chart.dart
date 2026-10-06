import 'dart:math' as math;
import 'package:flutter/widgets.dart';

import '../tokens/tokens.dart';
import 'amount_text.dart';

/// Single data point for [AreaLineChart].
class ChartDataPoint {
  final String label; // e.g. "Mon"
  final int valueCents; // Value in cents
  final DateTime? date;

  const ChartDataPoint({
    required this.label,
    required this.valueCents,
    this.date,
  });
}

/// A high-performance, interactive area line chart.
///
/// Features:
/// - Monotone cubic Bézier curve rendering
/// - Vertical gradient under the line
/// - Dotted horizontal grid lines
/// - Dynamic scrub interaction with tooltip and indicator dot
/// - Zero external chart libraries, zero Material/Cupertino
class AreaLineChart extends StatefulWidget {
  final List<ChartDataPoint> data;
  final double height;
  final Color? lineColor;
  final Color? fillColor;
  final bool showGrid;
  final bool interactive;

  const AreaLineChart({
    super.key,
    required this.data,
    this.height = 200,
    this.lineColor,
    this.fillColor,
    this.showGrid = true,
    this.interactive = true,
  });

  @override
  State<AreaLineChart> createState() => _AreaLineChartState();
}

class _AreaLineChartState extends State<AreaLineChart> {
  int? _scrubIndex;

  void _handleScrub(Offset localPosition, double width) {
    if (widget.data.isEmpty) return;
    final step = width / (widget.data.length - 1);
    final index = (localPosition.dx / step).round().clamp(0, widget.data.length - 1);

    setState(() {
      _scrubIndex = index;
    });
  }

  void _clearScrub() {
    setState(() {
      _scrubIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final text = context.text;

    final primaryLineColor = widget.lineColor ?? colors.primaryInk;
    final primaryFillColor = widget.fillColor ?? primaryLineColor;

    if (widget.data.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Text(
            'No data available',
            style: text.caption.copyWith(color: colors.textTertiary),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartWidth = constraints.maxWidth;
        const bottomLabelHeight = 24.0;
        final plotHeight = widget.height - bottomLabelHeight;

        final values = widget.data.map((d) => d.valueCents.toDouble()).toList();
        final rawMin = values.reduce(math.min);
        final rawMax = values.reduce(math.max);
        final minVal = rawMin * 0.9;
        final maxVal = rawMax == rawMin ? rawMax + 100 : rawMax * 1.1;

        return SizedBox(
          width: chartWidth,
          height: widget.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Chart Canvas
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: widget.interactive
                    ? (details) => _handleScrub(details.localPosition, chartWidth)
                    : null,
                onHorizontalDragUpdate: widget.interactive
                    ? (details) => _handleScrub(details.localPosition, chartWidth)
                    : null,
                onHorizontalDragEnd: widget.interactive ? (_) => _clearScrub() : null,
                onTapDown: widget.interactive
                    ? (details) => _handleScrub(details.localPosition, chartWidth)
                    : null,
                onTapUp: widget.interactive ? (_) => _clearScrub() : null,
                child: CustomPaint(
                  size: Size(chartWidth, plotHeight),
                  painter: _ChartPainter(
                    data: widget.data,
                    minVal: minVal,
                    maxVal: maxVal,
                    lineColor: primaryLineColor,
                    fillColor: primaryFillColor,
                    gridColor: colors.borderSubtle,
                    scrubIndex: _scrubIndex,
                  ),
                ),
              ),

              // Bottom X-Axis Labels
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: bottomLabelHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: widget.data.asMap().entries.map((entry) {
                    final isHighlighted = entry.key == _scrubIndex;
                    return Text(
                      entry.value.label,
                      style: text.caption.copyWith(
                        color: isHighlighted
                            ? colors.primaryInk
                            : colors.textTertiary,
                        fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 11,
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Interactive Scrub Tooltip
              if (_scrubIndex != null && _scrubIndex! < widget.data.length) ...[
                Builder(
                  builder: (context) {
                    final item = widget.data[_scrubIndex!];
                    final step = chartWidth / (widget.data.length - 1);
                    final dotX = _scrubIndex! * step;
                    final normY = (item.valueCents - minVal) / (maxVal - minVal);
                    final dotY = plotHeight - (normY * plotHeight);

                    return Positioned(
                      left: (dotX - 50).clamp(0.0, chartWidth - 100),
                      top: math.max(0.0, dotY - 56),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primaryInk,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: colors.shadowColor.withValues(alpha: 0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.label,
                              style: text.caption.copyWith(
                                color: colors.surface.withValues(alpha: 0.7),
                                fontSize: 10,
                              ),
                            ),
                            AmountText(
                              cents: item.valueCents,
                              style: text.caption.copyWith(
                                color: colors.surface,
                                fontWeight: FontWeight.w700,
                              ),
                              centsStyle: text.caption.copyWith(
                                color: colors.surface.withValues(alpha: 0.8),
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<ChartDataPoint> data;
  final double minVal;
  final double maxVal;
  final Color lineColor;
  final Color fillColor;
  final Color gridColor;
  final int? scrubIndex;

  _ChartPainter({
    required this.data,
    required this.minVal,
    required this.maxVal,
    required this.lineColor,
    required this.fillColor,
    required this.gridColor,
    this.scrubIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    // Draw horizontal dashed grid lines (3 lines)
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (int i = 1; i <= 3; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final points = <Offset>[];
    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final normY = (data[i].valueCents - minVal) / (maxVal - minVal);
      final y = size.height - (normY * size.height);
      points.add(Offset(x, y));
    }

    // Build smooth cubic bezier curve
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final control1 = Offset(current.dx + (next.dx - current.dx) / 2, current.dy);
      final control2 = Offset(current.dx + (next.dx - current.dx) / 2, next.dy);
      path.cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, next.dx, next.dy);
    }

    // Fill area under curve
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          fillColor.withValues(alpha: 0.22),
          fillColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Stroke curve
    final strokePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, strokePaint);

    // Draw End Dot
    final lastPoint = points.last;
    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    final dotRingPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(lastPoint, 8, dotRingPaint);
    canvas.drawCircle(lastPoint, 4, dotPaint);

    // Draw Scrub Indicator if scrubbing
    if (scrubIndex != null && scrubIndex! < points.length) {
      final scrubPt = points[scrubIndex!];
      final scrubLinePaint = Paint()
        ..color = lineColor.withValues(alpha: 0.5)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(scrubPt.dx, 0),
        Offset(scrubPt.dx, size.height),
        scrubLinePaint,
      );

      canvas.drawCircle(scrubPt, 6, dotPaint);
      canvas.drawCircle(
        scrubPt,
        3,
        Paint()..color = const Color(0xFFFFFFFF),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) => true;
}
