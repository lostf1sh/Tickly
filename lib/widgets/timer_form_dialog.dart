import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/timer_model.dart';
import '../providers/timer_provider.dart';
import 'customization_picker.dart';
import 'recurrence_picker.dart';

class TimerFormDialog extends StatefulWidget {
  final TimerModel? timer;

  const TimerFormDialog({
    super.key,
    this.timer,
  });

  @override
  State<TimerFormDialog> createState() => _TimerFormDialogState();
}

class _TimerFormDialogState extends State<TimerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now().add(const Duration(days: 1));
  IconData _selectedIcon = Icons.event;
  Color _selectedColor = Colors.blue;
  RecurrenceType _recurrenceType = RecurrenceType.none;
  bool _hasNotification = true;
  int? _reminderHours;
  bool _hasDailyReminder = false;
  TimeOfDay? _dailyReminderTime;

  @override
  void initState() {
    super.initState();
    if (widget.timer != null) {
      _nameController.text = widget.timer!.name;
      _selectedDateTime = widget.timer!.targetDateTime;
      _selectedIcon = widget.timer!.icon;
      _selectedColor = widget.timer!.themeColor;
      _recurrenceType = widget.timer!.recurrenceType;
      _hasNotification = widget.timer!.hasNotification;
      _reminderHours = widget.timer!.reminderHours;
      _hasDailyReminder = widget.timer!.hasDailyReminder;
      _dailyReminderTime = widget.timer!.dailyReminderTime;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.timer != null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isEditing ? Icons.edit : Icons.add,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditing ? 'Edit Timer' : 'Create Timer',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        isEditing 
                            ? 'Update your timer settings'
                            : 'Set up a new countdown timer',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            Flexible(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Timer Name',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Enter timer name',
                          prefixIcon: Icon(
                            Icons.label_outline,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a timer name';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      Text(
                        'Target Date & Time',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectDateTime(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.colorScheme.outline.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Date & Time',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _formatDateTime(_selectedDateTime),
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      Text(
                        'Customization',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      CustomizationPicker(
                        initialIcon: _selectedIcon,
                        initialColor: _selectedColor,
                        onIconChanged: (icon) => setState(() => _selectedIcon = icon),
                        onColorChanged: (color) => setState(() => _selectedColor = color),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      RecurrencePicker(
                        selectedRecurrence: _recurrenceType,
                        onRecurrenceChanged: (type) => setState(() => _recurrenceType = type),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      Text(
                        'Notifications',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      SwitchListTile(
                        title: Text(
                          'Timer Notification',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          'Get notified when timer expires',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        value: _hasNotification,
                        onChanged: (value) => setState(() => _hasNotification = value),
                        activeColor: theme.colorScheme.primary,
                        contentPadding: EdgeInsets.zero,
                      ),
                      
                      if (_hasNotification) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reminder Time',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<int>(
                                value: _reminderHours,
                                decoration: InputDecoration(
                                  hintText: 'Select reminder time',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                items: [
                                  const DropdownMenuItem(value: 1, child: Text('1 hour before')),
                                  const DropdownMenuItem(value: 2, child: Text('2 hours before')),
                                  const DropdownMenuItem(value: 6, child: Text('6 hours before')),
                                  const DropdownMenuItem(value: 12, child: Text('12 hours before')),
                                  const DropdownMenuItem(value: 24, child: Text('1 day before')),
                                  const DropdownMenuItem(value: 168, child: Text('1 week before')),
                                ],
                                onChanged: (value) => setState(() => _reminderHours = value),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 16),
                      
                      SwitchListTile(
                        title: Text(
                          'Daily Reminder',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          'Get daily reminders until timer expires',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        value: _hasDailyReminder,
                        onChanged: (value) => setState(() => _hasDailyReminder = value),
                        activeColor: theme.colorScheme.primary,
                        contentPadding: EdgeInsets.zero,
                      ),
                      
                      if (_hasDailyReminder) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Daily Reminder Time',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _selectDailyReminderTime(context),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: theme.colorScheme.outline.withOpacity(0.3),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time_outlined,
                                        color: theme.colorScheme.secondary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Reminder Time',
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: theme.colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              _dailyReminderTime != null
                                                  ? '${_dailyReminderTime!.hour.toString().padLeft(2, '0')}:${_dailyReminderTime!.minute.toString().padLeft(2, '0')}'
                                                  : 'Set time',
                                              style: theme.textTheme.bodyLarge?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: theme.colorScheme.onSurface,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: _saveTimer,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      isEditing ? 'Update' : 'Create',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.isNegative) {
      return 'Past date';
    }
    
    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    
    String timeString = '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    
    if (days > 0) {
      timeString += ' (in $days days)';
    } else if (hours > 0) {
      timeString += ' (in $hours hours)';
    } else if (minutes > 0) {
      timeString += ' (in $minutes minutes)';
    } else {
      timeString += ' (now)';
    }
    
    return timeString;
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      
      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _selectDailyReminderTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: _dailyReminderTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    
    if (time != null) {
      setState(() {
        _dailyReminderTime = time;
      });
    }
  }

  void _saveTimer() {
    if (_formKey.currentState!.validate()) {
      final timerProvider = Provider.of<TimerProvider>(context, listen: false);
      
      if (widget.timer != null) {
        final updatedTimer = widget.timer!.copyWith(
          name: _nameController.text.trim(),
          targetDateTime: _selectedDateTime,
          icon: _selectedIcon,
          themeColor: _selectedColor,
          recurrenceType: _recurrenceType,
          hasNotification: _hasNotification,
          reminderHours: _reminderHours,
          hasDailyReminder: _hasDailyReminder,
          dailyReminderTime: _dailyReminderTime,
        );
        timerProvider.updateTimer(updatedTimer);
      } else {
        final newTimer = TimerModel(
          name: _nameController.text.trim(),
          targetDateTime: _selectedDateTime,
          icon: _selectedIcon,
          themeColor: _selectedColor,
          recurrenceType: _recurrenceType,
          hasNotification: _hasNotification,
          reminderHours: _reminderHours,
          hasDailyReminder: _hasDailyReminder,
          dailyReminderTime: _dailyReminderTime,
        );
        timerProvider.addTimer(newTimer);
      }
      
      Navigator.of(context).pop();
    }
  }
} 