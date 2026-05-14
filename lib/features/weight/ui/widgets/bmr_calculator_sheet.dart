import 'package:flutter/material.dart';

class BmrCalculatorSheet extends StatefulWidget {
  const BmrCalculatorSheet({super.key});

  @override
  State<BmrCalculatorSheet> createState() => _BmrCalculatorSheetState();
}

class _BmrCalculatorSheetState extends State<BmrCalculatorSheet> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  
  String _gender = 'Male';
  String _activityLevel = 'Sedentary';
  
  double? _bmr;
  double? _tdee;

  void _calculateBmr() {
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);
    final age = int.tryParse(_ageController.text);

    if (height == null || weight == null || age == null) {
      return;
    }

    // Mifflin-St Jeor Equation
    double bmrBase = (10 * weight) + (6.25 * height) - (5 * age);
    if (_gender == 'Male') {
      bmrBase += 5;
    } else {
      bmrBase -= 161;
    }

    setState(() {
      _bmr = bmrBase;
      _tdee = _bmr! * _activityMultiplier(_activityLevel);
    });
  }

  double _activityMultiplier(String level) {
    switch (level) {
      case 'Sedentary': return 1.2;
      case 'Lightly active': return 1.375;
      case 'Moderately active': return 1.55;
      case 'Very active': return 1.725;
      case 'Extra active': return 1.9;
      default: return 1.2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'BMR Calculator',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Height (cm)'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Weight (kg)'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Age'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _gender,
            items: ['Male', 'Female'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
            onChanged: (v) => setState(() => _gender = v!),
            decoration: const InputDecoration(labelText: 'Gender'),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _activityLevel,
            items: [
              'Sedentary',
              'Lightly active',
              'Moderately active',
              'Very active',
              'Extra active'
            ].map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
            onChanged: (v) => setState(() => _activityLevel = v!),
            decoration: const InputDecoration(labelText: 'Activity Level'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculateBmr,
            child: const Text('Calculate'),
          ),
          const SizedBox(height: 24),
          if (_bmr != null && _tdee != null) ...[
            Text('BMR: ${_bmr!.toStringAsFixed(0)} kcal', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('TDEE: ${_tdee!.toStringAsFixed(0)} kcal', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}