import 'package:expense_tracker/components/rounded_button.dart';
import 'package:expense_tracker/core/widgets/themes/app_colors.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/screens/auth/components/background.dart';
import 'package:expense_tracker/screens/auth/singup_screen.dart';
import 'package:expense_tracker/screens/main_navigation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_strings.dart';
import 'package:provider/provider.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).clearError();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: size.height * 0.15),
            Text(
              AppStrings.appName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
                color: Colors.white,
              ),
            ),
            Text(
              AppStrings.appTagline,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            SizedBox(height: size.height * 0.005),
            Text(
              AppStrings.welcomeBack,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
                color: Colors.white,
              ),
            ),

            Consumer<AuthProvider>(
              builder: (context, auth, child) {
                if (auth.error != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(auth.error!),
                        backgroundColor: Colors.redAccent,
                        duration: const Duration(milliseconds: 1500),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                    );
                    auth.clearError();
                  });
                }
                return child!;
              },
              child: _buildFormAndButtons(context, size),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormAndButtons(BuildContext context, Size size) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.1,
            vertical: size.height * 0.02,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Поле Email
                TextFormField(
                  controller: _emailController,
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: AppStrings.emailHint,
                    hintStyle: TextStyle(color: Colors.white54),
                    prefixIcon: Icon(Icons.email, color: Colors.white),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2),
                    ),
                    errorStyle: TextStyle(
                      color: Colors.red[300],
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    errorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red[300]!, width: 2),
                    ),
                    focusedErrorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red[300]!, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.emailEmptyError;
                    }
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) {
                      return AppStrings.emailInvalidError;
                    }
                    return null;
                  },
                ),
                SizedBox(height: size.height * 0.01),
                TextFormField(
                  controller: _passwordController,
                  style: TextStyle(color: Colors.white),
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: AppStrings.passwordHint,
                    hintStyle: TextStyle(color: Colors.white54),
                    prefixIcon: Icon(Icons.lock, color: Colors.white),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2),
                    ),
                    errorStyle: TextStyle(
                      color: Colors.red[300],
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    errorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red[300]!, width: 2),
                    ),
                    focusedErrorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red[300]!, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.passwordEmptyError;
                    }
                    if (value.length < 6) {
                      return AppStrings.passwordLengthError;
                    }
                    final passwordRegex = RegExp(r'^[a-zA-Z0-9]{6,}$');
                    if (!passwordRegex.hasMatch(value)) {
                      return 'Password must contain only letters and numbers';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: size.height * 0.04),

        if (auth.isLoading)
          const CircularProgressIndicator(color: Colors.white)
        else
          RoundedButton(
            text: AppStrings.signInButton,
            colorStart: Colors.white,
            colorEnd: Colors.white,
            textColor: violetPrimaryColor,
            press: () async {
              await FirebaseAnalytics.instance.logEvent(name: "log in");

              if (!_formKey.currentState!.validate()) return;

              bool success = await auth.signInWithEmail(
                _emailController.text.trim(),
                _passwordController.text.trim(),
              );

              if (success && context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MainNavigation()),
                  (route) => false,
                );
              }
            },
          ),

        SizedBox(height: size.height * 0.04),

        // Divider
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
          child: Row(
            children: [
              Expanded(
                child: Divider(
                  color: Colors.grey[200],
                  thickness: 1,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  AppStrings.orContinueWith,
                  style: TextStyle(color: Colors.grey[200]),
                ),
              ),
              Expanded(
                child: Divider(
                  color: Colors.grey[200],
                  thickness: 1,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: size.height * 0.04),

        RoundedButton(
          text: AppStrings.googleButton,
          colorStart: Colors.white.withAlpha(100),
          colorEnd: Colors.white.withAlpha(100),
          textColor: Colors.white,
          fontWeight: FontWeight.bold,
          width: 150,
          press: () async {
            // ✅ Використовуємо новий метод
            bool success = await auth.signInWithGoogle();
            if (success && context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MainNavigation()),
                (route) => false,
              );
            }
          },
        ),

        SizedBox(height: size.height * 0.04),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 80),
          child: Row(
            children: [
              Text(
                AppStrings.dontHaveAccount,
                style: TextStyle(color: Color(0xFF502080)),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    AppStrings.signUpButton,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}