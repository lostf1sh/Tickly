import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../models/timer_model.dart';
import '../services/share_service.dart';
import 'timer_form_dialog.dart';

class TimerCard extends StatefulWidget {
  final TimerModel timer;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggle;
  final VoidCallback? onShare;
  final VoidCallback? onSelect;
  final VoidCallback? onLongPress;
  final bool isSelectionMode;
  final bool isSelected;

  const TimerCard({
    super.key,
    required this.timer,
    this.onEdit,
    this.onDelete,
    this.onToggle,
    this.onShare,
    this.onSelect,
    this.onLongPress,
    this.isSelectionMode = false,
    this.isSelected = false,
  });

  @override
  State<TimerCard> createState() => _TimerCardState();
}

class _TimerCardState extends State<TimerCard> with TickerProviderStateMixin, WidgetsBindingObserver {
  Timer? _countdownTimer;
  Duration _remainingTime = Duration.zero;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _updateRemainingTime();
    _startCountdown();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.resumed) {
      _updateRemainingTime();
      if (_countdownTimer == null || !_countdownTimer!.isActive) {
        _startCountdown();
      }
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _updateRemainingTime();
        });
      }
    });
  }

  void _updateRemainingTime() {
    final now = DateTime.now();
    final difference = widget.timer.targetDateTime.difference(now);
    _remainingTime = difference.isNegative ? Duration.zero : difference;
    _isExpired = difference.isNegative;
    
    if (_remainingTime.inHours < 1 && _remainingTime.inHours >= 0 && !_isExpired) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      if (_pulseController.isAnimating) {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: widget.isSelected 
            ? Border.all(
                color: theme.colorScheme.primary,
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Card(
              elevation: widget.isSelected ? 4 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () {
                  if (widget.isSelectionMode) {
                    widget.onSelect?.call();
                  } else {
                    widget.onEdit?.call();
                  }
                },
                onLongPress: widget.onLongPress,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (widget.isSelectionMode) ...[
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: widget.isSelected 
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.surfaceVariant,
                                border: Border.all(
                                  color: widget.isSelected 
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outline,
                                  width: 2,
                                ),
                              ),
                              child: widget.isSelected
                                  ? Icon(
                                      Icons.check,
                                      size: 16,
                                      color: theme.colorScheme.onPrimary,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                          ],
                          
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: widget.timer.themeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              TimerModel.iconNameToIconData(widget.timer.iconName),
                              color: widget.timer.themeColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.timer.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _isExpired 
                                        ? theme.colorScheme.error
                                        : theme.colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _isExpired ? 'Expired' : 'Time remaining',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: _isExpired 
                                        ? theme.colorScheme.error
                                        : theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          if (!widget.isSelectionMode) ...[
                            IconButton(
                              onPressed: () => _shareTimer(context),
                              icon: Icon(
                                Icons.share_outlined,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                              tooltip: 'Share Timer',
                              style: IconButton.styleFrom(
                                backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            
                            PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              tooltip: 'More Options',
                              onSelected: (value) {
                                switch (value) {
                                  case 'edit':
                                    widget.onEdit?.call();
                                    break;
                                  case 'delete':
                                    widget.onDelete?.call();
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit_outlined,
                                        color: theme.colorScheme.primary,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        color: theme.colorScheme.error,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text('Delete'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      if (!_isExpired) ...[
                        _buildCountdownDisplay(theme),
                        const SizedBox(height: 12),
                      ],
                      
                      LinearProgressIndicator(
                        value: _getProgressValue(widget.timer.targetDateTime),
                        backgroundColor: theme.colorScheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _isExpired 
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM dd, yyyy • HH:mm').format(widget.timer.targetDateTime),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (widget.timer.recurrenceType != RecurrenceType.none) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getRecurrenceText(widget.timer.recurrenceType),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSecondaryContainer,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCountdownDisplay(ThemeData theme) {
    final days = _remainingTime.inDays;
    final hours = _remainingTime.inHours % 24;
    final minutes = _remainingTime.inMinutes % 60;
    final seconds = _remainingTime.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (days > 0) _buildTimeUnit(days, 'DAYS', theme),
          _buildTimeUnit(hours, 'HOURS', theme),
          _buildTimeUnit(minutes, 'MIN', theme),
          _buildTimeUnit(seconds, 'SEC', theme),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(int value, String label, ThemeData theme) {
    return Expanded(
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: Text(
              value.toString().padLeft(2, '0'),
              key: ValueKey(value),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  double _getProgressValue(DateTime targetDateTime) {
    final now = DateTime.now();
    final total = targetDateTime.difference(now.add(const Duration(days: 365))).inMilliseconds;
    final remaining = targetDateTime.difference(now).inMilliseconds;
    
    if (remaining <= 0) return 1.0;
    if (total <= 0) return 0.0;
    
    return 1.0 - (remaining / total);
  }

  String _getRecurrenceText(RecurrenceType recurrenceType) {
    switch (recurrenceType) {
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.monthly:
        return 'Monthly';
      case RecurrenceType.yearly:
        return 'Yearly';
      case RecurrenceType.none:
        return '';
    }
  }

  Future<void> _shareTimer(BuildContext context) async {
    final shareService = ShareService();
    await shareService.shareTimer(widget.timer);
  }
} 