import 'package:flutter/material.dart';

class SettingListItem extends StatelessWidget{
  final IconData icon;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const SettingListItem({
    super.key,
    required this.icon,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context){
    return ListTile(
      onTap: onTap,
      leading: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: iconBgColor.withValues(alpha: 0.1),
          shape: BoxShape.circle
        ),
        child: Icon(
          icon,
          color: iconBgColor,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
      trailing: trailing ??
        Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade400
        ),
    );
  }
}