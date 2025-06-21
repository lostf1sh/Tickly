import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/timer_card.dart';
import '../widgets/timer_form_dialog.dart';
import '../models/timer_model.dart';
import '../services/share_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSelectionMode = false;
  Set<String> _selectedTimerIds = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tickly'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                onPressed: () => themeProvider.toggleTheme(),
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                tooltip: themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
              );
            },
          ),
        ],
      ),
      body: Consumer<TimerProvider>(
        builder: (context, timerProvider, child) {
          final timers = timerProvider.timers;

          if (timers.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              if (_isSelectionMode) _buildSelectionAppBar(context, timerProvider),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: timers.length,
                  itemBuilder: (context, index) {
                    final timer = timers[index];
                    final isSelected = _selectedTimerIds.contains(timer.id);
                    
                    return TimerCard(
                      timer: timer,
                      isSelectionMode: _isSelectionMode,
                      isSelected: isSelected,
                      onEdit: () => _showTimerDialog(context, timer),
                      onDelete: () => _showDeleteDialog(context, timer),
                      onToggle: () => timerProvider.toggleTimerActive(timer.id),
                      onShare: () => _shareTimer(timer),
                      onSelect: _isSelectionMode ? () => _toggleTimerSelection(timer.id) : null,
                      onLongPress: () => _enterSelectionMode(timer.id),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _isSelectionMode ? null : FloatingActionButton.extended(
        onPressed: () => _showTimerDialog(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Add Timer'),
      ),
    );
  }

  Widget _buildSelectionAppBar(BuildContext context, TimerProvider timerProvider) {
    final theme = Theme.of(context);
    final selectedCount = _selectedTimerIds.length;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Container(
                key: ValueKey(selectedCount),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$selectedCount selected',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (selectedCount > 0) ...[
                    _buildActionButton(
                      context,
                      icon: Icons.share_outlined,
                      label: 'Share',
                      onPressed: () => _shareSelectedTimers(),
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    
                    _buildActionButton(
                      context,
                      icon: Icons.delete_outline,
                      label: 'Delete',
                      onPressed: () => _deleteSelectedTimers(timerProvider),
                      color: theme.colorScheme.onSurfaceVariant,
                      isDestructive: true,
                    ),
                    const SizedBox(width: 16),
                  ],
                  
                  _buildCancelButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDestructive 
                ? theme.colorScheme.errorContainer.withOpacity(0.1)
                : theme.colorScheme.primaryContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDestructive 
                  ? theme.colorScheme.errorContainer.withOpacity(0.3)
                  : theme.colorScheme.primaryContainer.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isDestructive 
                    ? theme.colorScheme.error
                    : color,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDestructive 
                      ? theme.colorScheme.error
                      : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _exitSelectionMode,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            'Cancel',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 80,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No timers yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first countdown timer',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _showTimerDialog(context, null),
            icon: const Icon(Icons.add),
            label: const Text('Create Timer'),
          ),
        ],
      ),
    );
  }

  void _enterSelectionMode(String timerId) {
    setState(() {
      _isSelectionMode = true;
      _selectedTimerIds.add(timerId);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedTimerIds.clear();
    });
  }

  void _toggleTimerSelection(String timerId) {
    setState(() {
      if (_selectedTimerIds.contains(timerId)) {
        _selectedTimerIds.remove(timerId);
      } else {
        _selectedTimerIds.add(timerId);
      }
      
      if (_selectedTimerIds.isEmpty) {
        _exitSelectionMode();
      }
    });
  }

  void _shareSelectedTimers() {
    if (_selectedTimerIds.isNotEmpty) {
      final timerProvider = Provider.of<TimerProvider>(context, listen: false);
      final selectedTimers = timerProvider.timers
          .where((timer) => _selectedTimerIds.contains(timer.id))
          .toList();
      
      if (selectedTimers.isNotEmpty) {
        final shareService = ShareService();
        shareService.shareTimer(selectedTimers.first);
      }
    }
  }

  Future<void> _deleteSelectedTimers(TimerProvider timerProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Selected Timers'),
        content: Text('Are you sure you want to delete ${_selectedTimerIds.length} timer(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      for (final timerId in _selectedTimerIds) {
        await timerProvider.deleteTimer(timerId);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_selectedTimerIds.length} timer(s) deleted')),
        );
        _exitSelectionMode();
      }
    }
  }

  Future<void> _shareTimer(TimerModel timer) async {
    await ShareService().shareTimer(timer);
  }

  Future<void> _showTimerDialog(BuildContext context, TimerModel? timer) async {
    final result = await showDialog<TimerModel>(
      context: context,
      builder: (context) => TimerFormDialog(timer: timer),
    );

    if (result != null) {
      final timerProvider = context.read<TimerProvider>();
      
      if (timer != null) {
        await timerProvider.updateTimer(result);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Timer updated successfully')),
          );
        }
      } else {
        await timerProvider.addTimer(result);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Timer created successfully')),
          );
        }
      }
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, TimerModel timer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Timer'),
        content: Text('Are you sure you want to delete "${timer.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final timerProvider = context.read<TimerProvider>();
      await timerProvider.deleteTimer(timer.id);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Timer deleted successfully')),
        );
      }
    }
  }
} 