import 'package:flutter/material.dart';
import 'package:recovery_app/features/meals/data/models/meal.dart';

class AddMealSheet extends StatelessWidget {
  const AddMealSheet({
    super.key,
    required this.initialDate,
    required this.onSave,
  });

  final DateTime initialDate;
  final Future<void> Function(Meal meal) onSave;

  @override
  Widget build(BuildContext context) {
    return _AddMealSheetForm(
      initialDate: initialDate,
      onSave: onSave,
    );
  }
}

class _AddMealSheetForm extends StatefulWidget {
  const _AddMealSheetForm({
    required this.initialDate,
    required this.onSave,
  });

  final DateTime initialDate;
  final Future<void> Function(Meal meal) onSave;

  @override
  State<_AddMealSheetForm> createState() => _AddMealSheetFormState();
}

class _AddMealSheetFormState extends State<_AddMealSheetForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  MealTimeOfDay _selected = MealTimeOfDay.breakfast;

  @override
  void dispose() {
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final Meal meal = Meal(
      date: widget.initialDate,
      timeOfDay: _selected,
      description: _descriptionController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    await widget.onSave(meal);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Add Meal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: MealTimeOfDay.values.map((MealTimeOfDay value) {
                return ChoiceChip(
                  label: Text(value.name),
                  selected: _selected == value,
                  onSelected: (_) => setState(() => _selected = value),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLength: 200,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (String? value) {
                final String text = value?.trim() ?? '';
                if (text.isEmpty) {
                  return 'Description is required';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
