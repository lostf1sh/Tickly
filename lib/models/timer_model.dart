import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum RecurrenceType {
  none,
  daily,
  weekly,
  monthly,
  yearly,
}

class TimerModel {
  final String id;
  String name;
  DateTime targetDateTime;
  bool isActive;
  int? reminderHours;
  bool hasNotification;
  bool hasDailyReminder;
  TimeOfDay? dailyReminderTime;
  String iconName;
  Color themeColor;
  RecurrenceType recurrenceType;
  DateTime? originalTargetDateTime;

  TimerModel({
    String? id,
    required this.name,
    required this.targetDateTime,
    this.isActive = true,
    this.reminderHours,
    this.hasNotification = false,
    this.hasDailyReminder = false,
    this.dailyReminderTime,
    this.iconName = 'timer',
    this.themeColor = Colors.blue,
    this.recurrenceType = RecurrenceType.none,
    this.originalTargetDateTime,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'targetDateTime': targetDateTime.millisecondsSinceEpoch,
      'isActive': isActive,
      'reminderHours': reminderHours,
      'hasNotification': hasNotification,
      'hasDailyReminder': hasDailyReminder,
      'dailyReminderTime': dailyReminderTime != null 
          ? '${dailyReminderTime!.hour}:${dailyReminderTime!.minute}'
          : null,
      'iconName': iconName,
      'themeColor': themeColor.value,
      'recurrenceType': recurrenceType.index,
      'originalTargetDateTime': originalTargetDateTime?.millisecondsSinceEpoch,
    };
  }

  factory TimerModel.fromJson(Map<String, dynamic> json) {
    TimeOfDay? dailyReminderTime;
    if (json['dailyReminderTime'] != null) {
      final timeParts = json['dailyReminderTime'].split(':');
      dailyReminderTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    }

    DateTime? originalTargetDateTime;
    if (json['originalTargetDateTime'] != null) {
      originalTargetDateTime = DateTime.fromMillisecondsSinceEpoch(json['originalTargetDateTime']);
    }

    return TimerModel(
      id: json['id'],
      name: json['name'],
      targetDateTime: DateTime.fromMillisecondsSinceEpoch(json['targetDateTime']),
      isActive: json['isActive'] ?? true,
      reminderHours: json['reminderHours'],
      hasNotification: json['hasNotification'] ?? false,
      hasDailyReminder: json['hasDailyReminder'] ?? false,
      dailyReminderTime: dailyReminderTime,
      iconName: json['iconName'] ?? 'timer',
      themeColor: Color(json['themeColor'] ?? Colors.blue.value),
      recurrenceType: RecurrenceType.values[json['recurrenceType'] ?? 0],
      originalTargetDateTime: originalTargetDateTime,
    );
  }

  Duration get remainingTime {
    final now = DateTime.now();
    final difference = targetDateTime.difference(now);
    return difference.isNegative ? Duration.zero : difference;
  }

  bool get isExpired => targetDateTime.isBefore(DateTime.now());

  int get daysLeft {
    final now = DateTime.now();
    final difference = targetDateTime.difference(now);
    return difference.isNegative ? 0 : difference.inDays;
  }

  void updateForRecurrence() {
    if (recurrenceType == RecurrenceType.none || originalTargetDateTime == null) return;

    final now = DateTime.now();
    if (targetDateTime.isBefore(now)) {
      DateTime nextDateTime = originalTargetDateTime!;
      
      while (nextDateTime.isBefore(now)) {
        switch (recurrenceType) {
          case RecurrenceType.daily:
            nextDateTime = nextDateTime.add(const Duration(days: 1));
            break;
          case RecurrenceType.weekly:
            nextDateTime = nextDateTime.add(const Duration(days: 7));
            break;
          case RecurrenceType.monthly:
            nextDateTime = DateTime(
              nextDateTime.year,
              nextDateTime.month + 1,
              nextDateTime.day,
              nextDateTime.hour,
              nextDateTime.minute,
            );
            break;
          case RecurrenceType.yearly:
            nextDateTime = DateTime(
              nextDateTime.year + 1,
              nextDateTime.month,
              nextDateTime.day,
              nextDateTime.hour,
              nextDateTime.minute,
            );
            break;
          case RecurrenceType.none:
            return;
        }
      }
      
      targetDateTime = nextDateTime;
    }
  }

  TimerModel copyWith({
    String? name,
    DateTime? targetDateTime,
    bool? isActive,
    int? reminderHours,
    bool? hasNotification,
    bool? hasDailyReminder,
    TimeOfDay? dailyReminderTime,
    String? iconName,
    Color? themeColor,
    RecurrenceType? recurrenceType,
    DateTime? originalTargetDateTime,
  }) {
    return TimerModel(
      id: id,
      name: name ?? this.name,
      targetDateTime: targetDateTime ?? this.targetDateTime,
      isActive: isActive ?? this.isActive,
      reminderHours: reminderHours ?? this.reminderHours,
      hasNotification: hasNotification ?? this.hasNotification,
      hasDailyReminder: hasDailyReminder ?? this.hasDailyReminder,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      iconName: iconName ?? this.iconName,
      themeColor: themeColor ?? this.themeColor,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      originalTargetDateTime: originalTargetDateTime ?? this.originalTargetDateTime,
    );
  }

  static const Map<String, IconData> iconMap = {
    'timer': Icons.timer,
    'event': Icons.event,
    'cake': Icons.cake,
    'celebration': Icons.celebration,
    'flight': Icons.flight,
    'school': Icons.school,
    'work': Icons.work,
    'favorite': Icons.favorite,
    'star': Icons.star,
    'home': Icons.home,
    'sports_soccer': Icons.sports_soccer,
    'music_note': Icons.music_note,
    'book': Icons.book,
    'fitness_center': Icons.fitness_center,
    'restaurant': Icons.restaurant,
    'shopping_cart': Icons.shopping_cart,
    'medical_services': Icons.medical_services,
    'psychology': Icons.psychology,
    'science': Icons.science,
    'architecture': Icons.architecture,
  };

  static IconData iconNameToIconData(String name) {
    return iconMap[name] ?? Icons.timer;
  }
} 