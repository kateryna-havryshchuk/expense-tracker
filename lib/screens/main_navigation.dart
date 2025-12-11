import 'package:flutter/material.dart';
import 'package:expense_tracker/screens/home/home_screen.dart';
import 'package:expense_tracker/screens/stats/stats_screen.dart';
import 'package:expense_tracker/screens/adding/add_expense_screen.dart';
import 'package:expense_tracker/screens/budget/budget_screen.dart';
import 'package:expense_tracker/screens/settings/settings_screen.dart';
import 'package:expense_tracker/components/navigatior_bar.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentPageIndex = 0;

  final List<Widget> pages = const [
    HomeScreen(),
    StatsScreen(),
    AddScreen(),
    BudgetScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentPageIndex],
      bottomNavigationBar: MyNavigationBar(
        currentIndex: currentPageIndex,
        onTap: (index) {
          setState(() {
            currentPageIndex = index;
          });
        },
      ),
    );
  }
}
