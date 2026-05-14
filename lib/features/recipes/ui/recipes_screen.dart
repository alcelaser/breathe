import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recovery_app/features/recipes/providers/recipes_providers.dart';

class RecipesScreen extends ConsumerWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsyncValue = ref.watch(recipesNotifierProvider);

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
                recipesAsyncValue.when(
                  data: (recipes) {
                    if (recipes.isEmpty) {
                      return const Center(
                        child: Text('No recipes added yet.'),
                      );
                    }
                    return Column(
                      children: recipes.map((recipe) {
                        return ListTile(
                          title: Text(recipe.title),
                          subtitle: Text(recipe.sourceLink ?? 'No link'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => ref
                                .read(recipesNotifierProvider.notifier)
                                .deleteRecipe(recipe.id),
                          ),
                          onTap: () {
                            // show details
                          },
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        backgroundColor: const Color(0xFFEEEEEE),
        foregroundColor: const Color(0xFF424242),
        onPressed: () {
          _showAddRecipeSheet(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddRecipeSheet(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final linkController = TextEditingController();
    final contentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Recipe Title'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: linkController,
                decoration: const InputDecoration(labelText: 'Link (YouTube/Website)'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Paste Recipe Here'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final title = titleController.text.trim();
                  final link = linkController.text.trim();
                  final content = contentController.text.trim();

                  if (title.isNotEmpty) {
                    ref.read(recipesNotifierProvider.notifier).addRecipe(
                      title,
                      link.isEmpty ? null : link,
                      content.isEmpty ? null : content,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save Recipe'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
