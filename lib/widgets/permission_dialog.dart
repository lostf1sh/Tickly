import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';

class PermissionDialog extends StatelessWidget {
  const PermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.notifications_off,
            color: theme.colorScheme.error,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Text('Notifications Disabled'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'To get the most out of Tickly, please enable notifications.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            context,
            Icons.timer,
            'Timer Reminders',
            'Get notified before your timers expire',
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            context,
            Icons.schedule,
            'Daily Reminders',
            'Never miss important countdowns',
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            context,
            Icons.notifications_active,
            'Smart Alerts',
            'Customizable reminder times',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Maybe Later'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            _openAppSettings();
          },
          child: const Text('Enable Notifications'),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openAppSettings() {
    AppSettings.openAppSettings();
  }
} 