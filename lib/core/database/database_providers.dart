import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recovery_app/core/database/database_helper.dart';

final databaseHelperProvider = Provider<DatabaseHelper>((Ref ref) {
  return DatabaseHelper.instance;
});
