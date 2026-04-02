import 'package:flutter/material.dart';
import 'package:recovery_app/features/meals/data/models/meal.dart';

class AddMealSheet extends StatelessWidget {
  const AddMealSheet({
    super.key,
    required this.initialDate,
    this.initialMeal,
    required this.onSave,
  });

  final DateTime initialDate;
  final Meal? initialMeal;
  final Future<void> Function(Meal meal) onSave;

  @override
  Widget build(BuildContext context) {
    return _AddMealSheetForm(
      initialDate: initialDate,
      initialMeal: initialMeal,
      onSave: onSave,
    );
  }
}

class _AddMealSheetForm extends StatefulWidget {
  const _AddMealSheetForm({
    required this.initialDate,
    this.initialMeal,
    required this.onSave,
  });

  final DateTime initialDate;
  final Meal? initialMeal;
  final Future<void> Function(Meal meal) onSave;

  @override
  State<_AddMealSheetForm> createState() => _AddMealSheetFormState();
}

class _AddMealSheetFormState extends State<_AddMealSheetForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  late MealTimeOfDay _selected;

  @override
  void initState() {
    super.initState();
    if (widget.initialMeal != null) {
      _selected = widget.initialMeal!.timeOfDay;
      _descriptionController.text = widget.initialMeal!.description;
      _quantityController.text = widget.initialMeal!.quantity;
      _notesController.text = widget.initialMeal!.notes ?? '';
    } else {
      _selected = MealTimeOfDay.breakfast;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final Meal meal = Meal(
      id: widget.initialMeal?.id,
      date: widget.initialDate,
      timeOfDay: _selected,
      description: _descriptionController.text.trim(),
      quantity: _quantityController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    try {
      await widget.onSave(meal);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to save meal. Please try again.')),
      );
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  widget.initialMeal == null ? 'Add Meal' : 'Edit Meal',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
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
                  controller: _quantityController,
                  decoration: const InputDecoration(
                      labelText: 'Quantity (e.g., 1 cup, 100g)'),
                  validator: (String? value) {
                    final String text = value?.trim() ?? '';
                    if (text.isEmpty) {
                      return 'Quantity is required';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _notesController,
                  decoration:
                      const InputDecoration(labelText: 'Notes (optional)'),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _save,
                  child: Text(widget.initialMeal == null ? 'Add' : 'Update'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
