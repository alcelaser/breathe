import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recovery_app/features/recipes/data/models/recipe.dart';
import 'package:recovery_app/core/database/database_providers.dart';
import 'package:uuid/uuid.dart';

class RecipesNotifier extends AsyncNotifier<List<Recipe>> {
  @override
  Future<List<Recipe>> build() async {
    final helper = ref.watch(databaseHelperProvider);
    final db = await helper.database;
    final List<Map<String, dynamic>> maps = await db.query('recipes');
    return maps.map((e) => Recipe(
      id: e['id'] as String,
      title: e['title'] as String,
      sourceLink: e['source_link'] as String?,
      content: e['content'] as String?,
    )).toList();
  }

  Future<void> addRecipe(String title, String? sourceLink, String? content) async {
    final recipe = Recipe(
      id: const Uuid().v4(),
      title: title,
      sourceLink: sourceLink,
      content: content,
    );
    final helper = ref.read(databaseHelperProvider);
    final db = await helper.database;
    await db.insert('recipes', {
      'id': recipe.id,
      'title': recipe.title,
      'source_link': recipe.sourceLink,
      'content': recipe.content,
    });
    ref.invalidateSelf();
  }

  Future<void> deleteRecipe(String id) async {
    final helper = ref.read(databaseHelperProvider);
    final db = await helper.database;
    await db.delete('recipes', where: 'id = ?', whereArgs: [id]);
    ref.invalidateSelf();
  }
}

final recipesNotifierProvider = AsyncNotifierProvider<RecipesNotifier, List<Recipe>>(
  () => RecipesNotifier(),
);