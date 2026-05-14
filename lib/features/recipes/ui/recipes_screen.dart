import 'package:flutter/material.dart';

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              children: <Widget>[
                Text(
                  'RECIPES',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        letterSpacing: 4.0,
                        fontWeight: FontWeight.w400,
                      ),
                ),
                const SizedBox(height: 32),
                // TODO: list recipes here
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: open add recipe sheet
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
