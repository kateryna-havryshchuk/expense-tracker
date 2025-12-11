import 'package:expense_tracker/models/category.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoryIconWidget extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryIconWidget({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  Color _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return Colors.grey;
    }
    
    try {
      final hexColor = colorString.replaceAll('#', '');
      return Color(int.parse('FF$hexColor', radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  IconData _parseIcon(String? iconString) {
    final iconMap = {
      'utensils': FontAwesomeIcons.utensils,
      'car': FontAwesomeIcons.car,
      'bagShopping': FontAwesomeIcons.bagShopping,
      'gamepad': FontAwesomeIcons.gamepad,
      'briefcase': FontAwesomeIcons.briefcase,
      'heartPulse': FontAwesomeIcons.heartPulse,
      'graduationCap': FontAwesomeIcons.graduationCap,
      'ellipsis': FontAwesomeIcons.ellipsis,
    };

    return iconMap[iconString] ?? FontAwesomeIcons.question;
  }

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(category.color);
    final icon = _parseIcon(category.icon);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.0),
          border: isSelected
              ? Border.all(color: color, width: 2)
              : Border.all(color: Colors.transparent, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              spreadRadius: 0,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.12),
              ),
              child: FaIcon(
                icon,
                size: 22,
                color: color,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}