import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:recovery_app/features/meals/data/models/meal.dart';
import 'package:recovery_app/features/meals/providers/meal_providers.dart';
import 'package:recovery_app/features/meals/ui/widgets/add_meal_sheet.dart';
import 'package:recovery_app/features/meals/ui/widgets/meal_card.dart';

class MealsScreen extends ConsumerStatefulWidget {
  const MealsScreen({super.key});

  @override
  ConsumerState<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends ConsumerState<MealsScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 10000);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _getDateForPage(int pageIndex) {
    final int offset = pageIndex - 10000;
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    return today.add(Duration(days: offset));
  }

  Future<void> _openAddSheet(
    BuildContext context,
    WidgetRef ref,
    DateTime date, {
    Meal? meal,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AddMealSheet(
          initialDate: date,
          initialMeal: meal,
          onSave: (Meal newMeal) {
            if (meal == null) {
              return ref.read(mealNotifierProvider.notifier).addMeal(newMeal);
            } else {
              return ref.read(mealNotifierProvider.notifier).editMeal(newMeal);
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine the selected date from the current page position
    final int currentPage = _pageController.hasClients
        ? _pageController.page?.round() ?? 10000
        : 10000;
    final DateTime selectedDate = _getDateForPage(currentPage);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Expanded(
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              'MEALS - ${DateFormat.MMMEd().format(selectedDate).toUpperCase()}',
                              key: ValueKey<String>(
                                selectedDate.toIso8601String(),
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    letterSpacing: 2.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (int index) {
                      setState(() {});
                    },
                    itemBuilder: (BuildContext context, int index) {
                      final DateTime pageDate = _getDateForPage(index);
                      return _MealPageContent(
                        pageDate: pageDate,
                        onOpenAddSheet: _openAddSheet,
                      );
                    },
                  ),
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
        onPressed: () => _openAddSheet(context, ref, selectedDate),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MealPageContent extends ConsumerWidget {
  final DateTime pageDate;
  final Future<void> Function(
    BuildContext context,
    WidgetRef ref,
    DateTime date, {
    Meal? meal,
  }) onOpenAddSheet;

  const _MealPageContent({
    required this.pageDate,
    required this.onOpenAddSheet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Meal>> mealsState =
        ref.watch(mealsForDateProvider(pageDate));

    return mealsState.when(
      data: (List<Meal> meals) {
        return meals.isEmpty
            ? const Center(child: Text('Nothing logged yet'))
            : ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                children: meals.map((Meal meal) {
                  return MealCard(
                    meal: meal,
                    enableSwipeToDelete: false,
                    onEdit: () => onOpenAddSheet(
                      context,
                      ref,
                      pageDate,
                      meal: meal,
                    ),
                    onRemove: () async {
                      final int? id = meal.id;
                      if (id == null) {
                        return;
                      }
                      await ref
                          .read(mealNotifierProvider.notifier)
                          .deleteMeal(id);
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Meal deleted. Undo?'),
                        ),
                      );
                    },
                  );
                }).toList(),
              );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object _, StackTrace __) {
        return const Center(child: Text('Unable to load meals.'));
      },
    );
  }
}
