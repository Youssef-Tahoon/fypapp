import 'package:flutter/material.dart';
import 'package:fyp_zakaty_app/auth/forgot_password_page.dart';
import 'package:provider/provider.dart';
import 'package:fyp_zakaty_app/auth/register_page.dart';
import 'package:fyp_zakaty_app/providers/user_provider.dart';
import '../colors/colors.dart';
import '../assets.dart';
import '../pages/main_navigation.dart';
import '../widgets/secondary_button.dart';
import '../widgets/form_fields.dart';
import '../widgets/background_image_container.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  int _adminTapCount = 0;
  final _adminTapThreshold = 10;
  DateTime? _lastTapTime;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.signIn(
          emailController.text.trim(),
          passwordController.text,
        );

        if (mounted && userProvider.isAuthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MainNavigation()),
          );
        }
      } catch (e) {
        if (mounted) {
          // Provide user-friendly error message
          String errorMessage = 'Login failed';

          // Handle common Firebase auth errors with user-friendly messages
          if (e.toString().contains('user-not-found') ||
              e.toString().contains('wrong-password') ||
              e.toString().contains('invalid-credential')) {
            errorMessage = 'Email and password do not match. Please try again.';
          } else if (e.toString().contains('too-many-requests')) {
            errorMessage =
                'Too many failed login attempts. Please try again later.';
          } else if (e.toString().contains('network-request-failed')) {
            errorMessage =
                'Network error. Please check your internet connection.';
          } else if (e.toString().contains('user-disabled')) {
            errorMessage =
                'This account has been disabled. Please contact support.';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  void _handleLogoTap() {
    final now = DateTime.now();
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) > Duration(seconds: 3)) {
      _adminTapCount = 0;
    }
    _lastTapTime = now;

    setState(() {
      _adminTapCount++;
      if (_adminTapCount >= _adminTapThreshold) {
        _adminTapCount = 0;
        Navigator.pushNamed(context, '/admin-login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return BackgroundImageContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 235),
                GestureDetector(
                  onTap: _handleLogoTap,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Image.asset(
                      'assets/images/logo.png', // Make sure you have this image
                      height: 120,
                      width: 120,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 32, bottom: 15),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Log in',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                        color: AppColor.kLightAccentColor,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColor.kSamiDarkColor.withOpacity(0.4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.kSamiDarkColor.withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: emailController,
                          validator: _validateEmail,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: passwordController,
                          validator: _validatePassword,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 326,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: userProvider.isLoading
                                ? null
                                : () => _login(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.kPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: userProvider.isLoading
                                ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    'Continue',
                                    style: TextStyle(
                                      color: AppColor.kWhiteColor,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ForgotPasswordPage()),
                            );
                          },
                          child: Text(
                            'Forgot password?',
                            style: TextStyle(
                              color: AppColor.kPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const DividerRow(),
                        const SizedBox(height: 32),
                        SecondaryButton(
                          onTap: () {
                            // TODO: Implement Google Sign In
                          },
                          borderRadius: 8,
                          fontSize: 14,
                          height: 48,
                          width: 326,
                          text: 'Login with Google',
                          textColor: AppColor.kBlackColor,
                          bgColor: AppColor.kLightAccentColor,
                          icons: AppImagePath.kGoogleLogo,
                        ),
                        const SizedBox(height: 16),
                        SecondaryButton(
                          onTap: () {
                            // TODO: Implement Apple Sign In
                          },
                          borderRadius: 8,
                          fontSize: 14,
                          height: 48,
                          width: 326,
                          text: 'Login with Apple',
                          textColor: AppColor.kBlackColor,
                          bgColor: AppColor.kLightAccentColor,
                          icons: AppImagePath.kApple,
                        ),
                        const SizedBox(height: 32),
                        CustomRichText(
                          title: "Don't have an account?",
                          subtitle: ' Sign up',
                          subtitleTextStyle: TextStyle(
                            color: AppColor.kPrimary,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                          onTab: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignUpScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
