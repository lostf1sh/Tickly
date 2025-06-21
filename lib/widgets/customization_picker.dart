import 'package:flutter/material.dart';
import '../models/timer_model.dart';

class CustomizationPicker extends StatefulWidget {
  final String initialIconName;
  final Color initialColor;
  final Function(String) onIconChanged;
  final Function(Color) onColorChanged;

  const CustomizationPicker({
    super.key,
    required this.initialIconName,
    required this.initialColor,
    required this.onIconChanged,
    required this.onColorChanged,
  });

  @override
  State<CustomizationPicker> createState() => _CustomizationPickerState();
}

class _CustomizationPickerState extends State<CustomizationPicker> {
  late String _selectedIconName;
  late Color _selectedColor;

  static const List<String> availableIconNames = [
    'timer',
    'event',
    'cake',
    'celebration',
    'flight',
    'school',
    'work',
    'favorite',
    'star',
    'home',
    'sports_soccer',
    'music_note',
    'book',
    'fitness_center',
    'restaurant',
    'shopping_cart',
    'medical_services',
    'psychology',
    'science',
    'architecture',
  ];

  static const List<Color> availableColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
    Colors.deepOrange,
    Colors.lime,
    Colors.brown,
    Colors.grey,
    Colors.deepPurple,
  ];

  @override
  void initState() {
    super.initState();
    _selectedIconName = widget.initialIconName;
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Icon',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 140,
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
          ),
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: availableIconNames.length,
            itemBuilder: (context, index) {
              final iconName = availableIconNames[index];
              final icon = TimerModel.iconNameToIconData(iconName);
              final isSelected = iconName == _selectedIconName;
              
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedIconName = iconName;
                  });
                  widget.onIconChanged(iconName);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? _selectedColor.withOpacity(0.2)
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected 
                        ? Border.all(color: _selectedColor, width: 2)
                        : Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: _selectedColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? _selectedColor : theme.colorScheme.onSurfaceVariant,
                    size: 28,
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 20),
        
        Text(
          'Choose Color',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 70,
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            itemCount: availableColors.length,
            itemBuilder: (context, index) {
              final color = availableColors[index];
              final isSelected = color == _selectedColor;
              
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                    widget.onColorChanged(color);
                  },
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected 
                          ? Border.all(color: theme.colorScheme.onSurface, width: 3)
                          : Border.all(color: theme.colorScheme.outline.withOpacity(0.3), width: 1),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ] : null,
                    ),
                    child: isSelected 
                        ? Icon(
                            Icons.check,
                            color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                            size: 24,
                          )
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _selectedColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _selectedColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                TimerModel.iconNameToIconData(_selectedIconName),
                color: _selectedColor,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Preview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: _selectedColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 