import 'package:expense_tracker/firebase_options_storage.dart';
import 'package:expense_tracker/providers/categories_provider.dart';
import 'package:expense_tracker/repositories/categories_repository.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/budget_provider.dart';

import 'repositories/transactions_repository.dart';
import 'repositories/budgets_repository.dart';

import 'core/services/auth_repository.dart';
import 'screens/welcome/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

 await Firebase.initializeApp(
    name: 'storageApp', 
    options: FirebaseStorageOptions.currentPlatform,
  );
 

  final sharedPrefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(sharedPrefs),
        ),
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(
            FirestoreTransactionsRepository(),
            FirestoreBudgetsRepository(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => BudgetProvider(
            FirestoreBudgetsRepository(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoriesProvider(
            FirestoreCategoriesRepository(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
      ),
      home: const WelcomeScreen(),
    );
  }
}
