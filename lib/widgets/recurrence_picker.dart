import 'package:flutter/material.dart';
import '../models/timer_model.dart';

class RecurrencePicker extends StatelessWidget {
  final RecurrenceType selectedRecurrence;
  final Function(RecurrenceType) onRecurrenceChanged;

  const RecurrencePicker({
    super.key,
    required this.selectedRecurrence,
    required this.onRecurrenceChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
      ),
      child: Column(
        children: RecurrenceType.values.map((recurrence) {
          final isSelected = recurrence == selectedRecurrence;
          
          return RadioListTile<RecurrenceType>(
            value: recurrence,
            groupValue: selectedRecurrence,
            onChanged: (value) {
              if (value != null) {
                onRecurrenceChanged(value);
              }
            },
            title: Row(
              children: [
                Icon(
                  _getRecurrenceIcon(recurrence),
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  _getRecurrenceLabel(recurrence),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            subtitle: Text(
              _getRecurrenceDescription(recurrence),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            activeColor: theme.colorScheme.primary,
          );
        }).toList(),
      ),
    );
  }

  IconData _getRecurrenceIcon(RecurrenceType recurrence) {
    switch (recurrence) {
      case RecurrenceType.none:
        return Icons.block;
      case RecurrenceType.daily:
        return Icons.repeat;
      case RecurrenceType.weekly:
        return Icons.view_week;
      case RecurrenceType.monthly:
        return Icons.calendar_month;
      case RecurrenceType.yearly:
        return Icons.calendar_today;
    }
  }

  String _getRecurrenceLabel(RecurrenceType recurrence) {
    switch (recurrence) {
      case RecurrenceType.none:
        return 'No Recurrence';
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.monthly:
        return 'Monthly';
      case RecurrenceType.yearly:
        return 'Yearly';
    }
  }

  String _getRecurrenceDescription(RecurrenceType recurrence) {
    switch (recurrence) {
      case RecurrenceType.none:
        return 'Timer will only run once';
      case RecurrenceType.daily:
        return 'Timer will repeat every day at the same time';
      case RecurrenceType.weekly:
        return 'Timer will repeat every week on the same day and time';
      case RecurrenceType.monthly:
        return 'Timer will repeat every month on the same date and time';
      case RecurrenceType.yearly:
        return 'Timer will repeat every year on the same date and time';
    }
  }
} 