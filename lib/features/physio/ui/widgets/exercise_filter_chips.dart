import 'package:flutter/material.dart';

class ExerciseFilterChips extends StatelessWidget {
  const ExerciseFilterChips({
    super.key,
    required this.selected,
    required this.onToggle,
    required this.onClear,
  });

  static const List<String> bodyAreas = <String>[
    'knee',
    'hip',
    'lower_back',
    'upper_back',
    'shoulder',
    'ankle',
    'neck',
    'core',
  ];

  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          ...bodyAreas.map((String area) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(area.replaceAll('_', ' ')),
                selected: selected.contains(area),
                onSelected: (_) => onToggle(area),
              ),
            );
          }),
          TextButton(onPressed: onClear, child: const Text('Clear')),
        ],
      ),
    );
  }
}
