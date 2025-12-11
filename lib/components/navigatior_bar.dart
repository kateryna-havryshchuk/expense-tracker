import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MyNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MyNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFDDDDDD),
            width: 1.0,
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        backgroundColor: Colors.white,
        indicatorColor: Colors.transparent, 
        overlayColor: WidgetStatePropertyAll(Colors.transparent),
        destinations: [
          NavigationDestination(
            selectedIcon: Icon(PhosphorIconsFill.house, color: Color(0xFF6366F1), size: 30),
            icon: Icon(PhosphorIconsRegular.house),
            label: "Home",
          ),
          NavigationDestination(
            selectedIcon: Icon(PhosphorIconsFill.chartPie, color: Color(0xFF6366F1), size: 30),
            icon: Icon(PhosphorIconsRegular.chartPie),
            label: "Stats",
          ),
          NavigationDestination(
            selectedIcon: Icon(PhosphorIconsFill.plusCircle, color: Color(0xFF6366F1), size: 70),
            icon: Icon(PhosphorIconsFill.plusCircle, color: Color(0xFF6366F1), size: 65),
            label: '',
          ),
          NavigationDestination(
            selectedIcon: Icon(PhosphorIconsFill.piggyBank, color: Color(0xFF6366F1), size: 30),
            icon: Icon(PhosphorIconsRegular.piggyBank),
            label: "Budget",
          ),
          NavigationDestination(
            selectedIcon: Icon(PhosphorIconsFill.gear, color: Color(0xFF6366F1), size: 30),
            icon: Icon(PhosphorIconsRegular.gear),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
