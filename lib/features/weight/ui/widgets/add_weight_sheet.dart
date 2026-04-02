import 'package:flutter/material.dart';
import 'package:recovery_app/features/weight/data/models/weight_entry.dart';

class AddWeightSheet extends StatelessWidget {
  const AddWeightSheet({
    super.key,
    required this.onSave,
  });

  final Future<void> Function(WeightEntry entry) onSave;

  @override
  Widget build(BuildContext context) {
    return _AddWeightSheetForm(onSave: onSave);
  }
}

class _AddWeightSheetForm extends StatefulWidget {
  const _AddWeightSheetForm({required this.onSave});

  final Future<void> Function(WeightEntry entry) onSave;

  @override
  State<_AddWeightSheetForm> createState() => _AddWeightSheetFormState();
}

class _AddWeightSheetFormState extends State<_AddWeightSheetForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _weightController = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final double kg = double.parse(_weightController.text.trim());
    await widget.onSave(WeightEntry(date: _date, weightKg: kg));
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Date: ${_date.toIso8601String().split('T').first}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    TextButton(
                        onPressed: _pickDate, child: const Text('Pick date')),
                  ],
                ),
                TextFormField(
                  controller: _weightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Weight (kg)'),
                  validator: (String? value) {
                    final double? parsed = double.tryParse(value?.trim() ?? '');
                    if (parsed == null || parsed < 30 || parsed > 300) {
                      return 'Enter a weight between 30 and 300';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                FilledButton(onPressed: _save, child: const Text('Save')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
