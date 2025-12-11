import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/screens/auth/signin_screen.dart';
import 'package:expense_tracker/screens/main_navigation.dart';
import 'package:expense_tracker/screens/settings/components/setting_option_list.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/providers/settings_provider.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // ✅ Використовуємо Provider замість user?.photoURL
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        String userName = user?.displayName ?? user?.email?.split('@')[0] ?? 'Guest';
        String userEmail = user?.email ?? 'no-email@example.com';

        return Container(
          width: double.infinity,
          color: Colors.grey.shade50,
          child: Column(
            children: [
              // Header
              Container(
                height: 100,
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const MainNavigation()),
                            (route) => false,
                          );
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: const Text(
                        "Settings",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Profile Container
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 20),
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3.0),
                              ),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                // ✅ Використовуємо settingsProvider.userAvatarUrl
                                backgroundImage: settingsProvider.userAvatarUrl != null
                                    ? NetworkImage(settingsProvider.userAvatarUrl!)
                                    : null,
                                child: settingsProvider.userAvatarUrl == null
                                    ? const Icon(Icons.person, size: 40, color: Colors.white)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 30),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    userEmail,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withValues(alpha: 0.85),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SettingsOptionsList(),

                      // Sign Out Button
                      Consumer<AuthProvider>(
                        builder: (context, auth, child) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red.shade700,
                                backgroundColor: Colors.red.withValues(alpha: 0.05),
                                side: BorderSide(color: Colors.red.withValues(alpha: 0.3), width: 1.5),
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: () async {
                                final success = await auth.signOut();
                                if (success && context.mounted) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                                    (route) => false,
                                  );
                                } else if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Sign out failed: ${auth.error}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.logout, size: 20),
                                  SizedBox(width: 10),
                                  Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}