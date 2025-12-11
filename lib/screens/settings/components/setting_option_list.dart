import 'package:expense_tracker/providers/settings_provider.dart';
import 'package:expense_tracker/screens/settings/components/setting_list_item.dart';
import 'package:expense_tracker/screens/settings/components/setting_section_header.dart';
import 'package:expense_tracker/screens/settings/personal_info_screen.dart';
import 'package:expense_tracker/screens/settings/security_screen.dart';
import 'package:expense_tracker/screens/settings/currency_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsOptionsList extends StatelessWidget {
  const SettingsOptionsList({super.key});
  
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingSectionHeader(title: "Account"),
        SettingListItem(
          icon: Icons.person,
          iconBgColor: Colors.blue, 
          title: "Personal Information", 
          subtitle: "Update your details", 
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PersonalInfoScreen()),
            );
          },
        ),
        SettingListItem(
          icon: Icons.security,
          iconBgColor: Colors.purple,
          title: "Security",
          subtitle: "Password & biometrics",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SecurityScreen()),
            );
          }
        ),

        const SettingSectionHeader(title: "Preferences"),
        SettingListItem(
          icon: Icons.attach_money,
          iconBgColor: Colors.orange,
          title: "Currency",
          subtitle: "${provider.selectedCurrency} - US Dollar",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CurrencyScreen()),
            );
          }
        ),
        SettingListItem(
          icon: Icons.palette,
          iconBgColor: Colors.blueAccent,
          title: "Theme",
          subtitle: provider.isThemeDark ? "Dark mode" : "Light mode",
          onTap: () {},
          trailing: Switch(
            value: provider.isThemeDark,
            onChanged: provider.toggleTheme,
          ),
        ),
        SettingListItem(
          icon: Icons.notifications_none,
          iconBgColor: Colors.redAccent,
          title: "Notifications",
          subtitle: provider.isNotificationsOn ? "Daily reminders enabled" : "Notifications disabled",
          onTap: () {},
          trailing: Switch(
            value: provider.isNotificationsOn,
            onChanged: provider.toggleNotifications,
          ),
         ),
          const SettingSectionHeader(title: "Data & Privacy"),
        SettingListItem(
          icon: Icons.download,
          iconBgColor: Colors.green,
          title: "Export Data",
          subtitle: "Download your information",
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Exporting data...'))
            );
          },
         ),
        SettingListItem(
          icon: Icons.cloud,
          iconBgColor: Colors.deepOrange,
          title: "Backup & Sync",
          subtitle: "Cloud synchronization",
          onTap: provider.toggleSync,
          trailing: _buildSyncStatusWidget(provider.isSyncOn),
         ),
         const SizedBox(height: 20),
      ],
    );
  }
  
  Widget _buildSyncStatusWidget(bool isOn) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: isOn ? Colors.green : Colors.grey.shade400,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          isOn ? "ON" : "OFF",
          style: TextStyle(
            color: isOn ? Colors.green : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}