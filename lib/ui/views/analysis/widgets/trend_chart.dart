import 'package:flutter/material.dart';
import 'package:jar/l10n/app_localizations.dart';
import 'package:jar/utils/movement_data_processor.dart';
import 'dart:math';

class TrendChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const TrendChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      return Center(child: Text(l10n.noData));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: ChartPainter(data: data),
        );
      },
    );
  }
}

class ChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  ChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final processed = MovementDataProcessor.process(data);
    final inData = processed.inData;
    final outData = processed.outData;
    final sortedDates = processed.sortedDates;
    if (sortedDates.isEmpty) return;

    final double yMax = (processed.maxCount == 0 ? 10 : processed.maxCount).toDouble() * 1.2;

    final Paint linePaintIn = Paint()
      ..color = Colors.green
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final Paint linePaintOut = Paint()
      ..color = Colors.orange
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final Paint dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Paint gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1.0;

    final double padding = 30.0;
    final double chartWidth = size.width - padding * 2;
    final double chartHeight = size.height - padding * 2;

    for (int i = 0; i <= 5; i++) {
      double y = padding + chartHeight - (chartHeight / 5) * i;
      canvas.drawLine(
          Offset(padding, y), Offset(size.width - padding, y), gridPaint);

      double value = (yMax / 5 * i);
      TextSpan span = TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 10),
          text: value.toStringAsFixed(0));
      TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.right,
          textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(padding - tp.width - 5, y - tp.height / 2));
    }

    Path pathIn = Path();
    Path pathOut = Path();

    double xStep =
        chartWidth / (sortedDates.length > 1 ? sortedDates.length - 1 : 1);

    for (int i = 0; i < sortedDates.length; i++) {
      String date = sortedDates[i];
      double x = padding + (i * xStep);

      double valIn = (inData[date] ?? 0).toDouble();
      double yIn = padding + chartHeight - (valIn / yMax * chartHeight);

      if (i == 0) {
        pathIn.moveTo(x, yIn);
      } else {
        pathIn.lineTo(x, yIn);
      }

      double valOut = (outData[date] ?? 0).toDouble();
      double yOut = padding + chartHeight - (valOut / yMax * chartHeight);

      if (i == 0) {
        pathOut.moveTo(x, yOut);
      } else {
        pathOut.lineTo(x, yOut);
      }
    }

    canvas.drawPath(pathIn, linePaintIn);
    canvas.drawPath(pathOut, linePaintOut);

    int skip = (sortedDates.length * 40 / chartWidth).ceil();
    if (skip < 1) skip = 1;

    for (int i = 0; i < sortedDates.length; i++) {
      String date = sortedDates[i];
      double x = padding + (i * xStep);

      double valIn = (inData[date] ?? 0).toDouble();
      double yIn = padding + chartHeight - (valIn / yMax * chartHeight);
      canvas.drawCircle(Offset(x, yIn), 4, dotPaint);
      canvas.drawCircle(
          Offset(x, yIn),
          4,
          linePaintIn
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);

      double valOut = (outData[date] ?? 0).toDouble();
      double yOut = padding + chartHeight - (valOut / yMax * chartHeight);
      canvas.drawCircle(Offset(x, yOut), 4, dotPaint);
      canvas.drawCircle(
          Offset(x, yOut),
          4,
          linePaintOut
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);

      if (i % skip == 0) {
        final label = MovementDataProcessor.formatDateLabel(date);

        TextSpan span = TextSpan(
            style: const TextStyle(color: Colors.black, fontSize: 10),
            text: label);
        TextPainter tp = TextPainter(
            text: span,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(canvas, Offset(x - tp.width / 2, padding + chartHeight + 5));
      }
    }
  }

  @override
  bool shouldRepaint(covariant ChartPainter oldDelegate) {
    if (oldDelegate.data.length != data.length) return true;
    for (int i = 0; i < data.length; i++) {
      if (oldDelegate.data[i]['date'] != data[i]['date'] ||
          oldDelegate.data[i]['type'] != data[i]['type'] ||
          oldDelegate.data[i]['count'] != data[i]['count']) {
        return true;
      }
    }
    return false;
  }
}
