import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/timer_model.dart';
import '../services/notification_service.dart';

class TimerProvider with ChangeNotifier {
  List<TimerModel> _timers = [];
  final NotificationService _notificationService = NotificationService();
  Timer? _updateTimer;

  List<TimerModel> get timers => _timers.where((timer) => timer.isActive).toList();
  List<TimerModel> get allTimers => _timers;

  TimerProvider() {
    _loadTimers();
    _startUpdateTimer();
  }

  void _startUpdateTimer() {
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRecurringTimers();
      notifyListeners();
    });
  }

  void _updateRecurringTimers() {
    bool hasChanges = false;
    
    for (int i = 0; i < _timers.length; i++) {
      final timer = _timers[i];
      if (timer.recurrenceType != RecurrenceType.none && timer.isActive) {
        final originalTarget = timer.targetDateTime;
        timer.updateForRecurrence();
        
        if (timer.targetDateTime != originalTarget) {
          hasChanges = true;
          
          if (timer.hasNotification) {
            _notificationService.scheduleTimerNotification(timer);
          }
          if (timer.hasDailyReminder) {
            _notificationService.scheduleDailyReminder(timer);
          }
        }
      }
    }
    
    if (hasChanges) {
      _saveTimers();
    }
  }

  Future<void> _loadTimers() async {
    final prefs = await SharedPreferences.getInstance();
    final timersJson = prefs.getStringList('timers') ?? [];
    
    _timers = timersJson
        .map((json) => TimerModel.fromJson(jsonDecode(json)))
        .toList();
    
    notifyListeners();
  }

  Future<void> _saveTimers() async {
    final prefs = await SharedPreferences.getInstance();
    final timersJson = _timers
        .map((timer) => jsonEncode(timer.toJson()))
        .toList();
    
    await prefs.setStringList('timers', timersJson);
  }

  Future<void> addTimer(TimerModel timer) async {
    _timers.add(timer);
    await _saveTimers();
    
    if (timer.hasNotification) {
      await _notificationService.scheduleTimerNotification(timer);
    }
    
    if (timer.hasDailyReminder) {
      await _notificationService.scheduleDailyReminder(timer);
    }
    
    notifyListeners();
  }

  Future<void> updateTimer(TimerModel updatedTimer) async {
    final index = _timers.indexWhere((timer) => timer.id == updatedTimer.id);
    if (index != -1) {
      await _notificationService.cancelTimerNotification(_timers[index]);
      await _notificationService.cancelDailyReminder(_timers[index]);
      
      _timers[index] = updatedTimer;
      await _saveTimers();
      
      if (updatedTimer.hasNotification) {
        await _notificationService.scheduleTimerNotification(updatedTimer);
      }
      
      if (updatedTimer.hasDailyReminder) {
        await _notificationService.scheduleDailyReminder(updatedTimer);
      }
      
      notifyListeners();
    }
  }

  Future<void> deleteTimer(String timerId) async {
    final timer = _timers.firstWhere((timer) => timer.id == timerId);
    await _notificationService.cancelTimerNotification(timer);
    await _notificationService.cancelDailyReminder(timer);
    
    _timers.removeWhere((timer) => timer.id == timerId);
    await _saveTimers();
    notifyListeners();
  }

  Future<void> toggleTimerActive(String timerId) async {
    final index = _timers.indexWhere((timer) => timer.id == timerId);
    if (index != -1) {
      final timer = _timers[index];
      final updatedTimer = timer.copyWith(isActive: !timer.isActive);
      
      if (updatedTimer.isActive) {
        if (updatedTimer.hasNotification) {
          await _notificationService.scheduleTimerNotification(updatedTimer);
        }
        if (updatedTimer.hasDailyReminder) {
          await _notificationService.scheduleDailyReminder(updatedTimer);
        }
      } else {
        await _notificationService.cancelTimerNotification(timer);
        await _notificationService.cancelDailyReminder(timer);
      }
      
      _timers[index] = updatedTimer;
      await _saveTimers();
      notifyListeners();
    }
  }

  Future<void> sendTestNotification(TimerModel timer) async {
    await _notificationService.sendTestNotification(timer);
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
} 