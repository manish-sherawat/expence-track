import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'app/router.dart';
import 'data/database/app_database.dart';
import 'data/repositories/finance_repository.dart';
import 'providers/finance_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();
  final repo = FinanceRepository(db);

  final isCompleted = await repo.isOnboardingCompleted();
  final router = isCompleted ? appRouter : createAppRouter(initialLocation: '/onboarding');

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        financeRepositoryProvider.overrideWithValue(repo),
      ],
      child: AppApp(router: router),
    ),
  );
}
