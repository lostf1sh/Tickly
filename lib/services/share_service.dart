import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../models/timer_model.dart';
import 'package:intl/intl.dart';

class ShareService {
  static final ShareService _instance = ShareService._internal();
  factory ShareService() => _instance;
  ShareService._internal();

  Future<void> shareTimer(TimerModel timer) async {
    try {
      final imageBytes = await _generateTimerImage(timer);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/timer_${timer.id}.png');
      await file.writeAsBytes(imageBytes);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Check out my timer: ${timer.name}',
      );
    } catch (e) {
      debugPrint('Error sharing timer: $e');
    }
  }

  Future<Uint8List> _generateTimerImage(TimerModel timer) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(400, 600);
    
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    
    final borderPaint = Paint()
      ..color = timer.themeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawRect(Rect.fromLTWH(4, 4, size.width - 8, size.height - 8), borderPaint);
    
    final iconPaint = Paint()
      ..color = timer.themeColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(200, 80), 40, iconPaint);
    
    final iconBorderPaint = Paint()
      ..color = timer.themeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(const Offset(200, 80), 40, iconBorderPaint);
    
    _drawIcon(canvas, timer.icon, const Offset(200, 80), 24, timer.themeColor);
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: timer.name,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(
      (size.width - textPainter.width) / 2,
      160,
    ));
    
    final remainingTime = timer.targetDateTime.difference(DateTime.now());
    String timeText;
    if (remainingTime.isNegative) {
      timeText = 'Expired';
    } else {
      final days = remainingTime.inDays;
      final hours = remainingTime.inHours % 24;
      final minutes = remainingTime.inMinutes % 60;
      
      if (days > 0) {
        timeText = '$days days, $hours hours';
      } else if (hours > 0) {
        timeText = '$hours hours, $minutes minutes';
      } else {
        timeText = '$minutes minutes';
      }
    }
    
    final timePainter = TextPainter(
      text: TextSpan(
        text: timeText,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: timer.themeColor,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    timePainter.layout();
    timePainter.paint(canvas, Offset(
      (size.width - timePainter.width) / 2,
      200,
    ));
    
    final statusText = remainingTime.isNegative ? 'Timer has expired' : 'Time remaining';
    final statusPainter = TextPainter(
      text: TextSpan(
        text: statusText,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    statusPainter.layout();
    statusPainter.paint(canvas, Offset(
      (size.width - statusPainter.width) / 2,
      240,
    ));
    
    final targetDate = DateFormat('MMM dd, yyyy • HH:mm').format(timer.targetDateTime);
    final datePainter = TextPainter(
      text: TextSpan(
        text: 'Target: $targetDate',
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    datePainter.layout();
    datePainter.paint(canvas, Offset(
      (size.width - datePainter.width) / 2,
      280,
    ));
    
    final appText = 'Tickly';
    final appPainter = TextPainter(
      text: TextSpan(
        text: appText,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: timer.themeColor,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    appPainter.layout();
    appPainter.paint(canvas, Offset(
      (size.width - appPainter.width) / 2,
      520,
    ));
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return byteData!.buffer.asUint8List();
  }

  void _drawIcon(Canvas canvas, IconData icon, Offset offset, double size, Color color) {
    final iconData = IconData(
      icon.codePoint,
      fontFamily: icon.fontFamily,
    );
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          fontSize: size,
          fontFamily: iconData.fontFamily,
          color: color,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, offset);
  }
} 