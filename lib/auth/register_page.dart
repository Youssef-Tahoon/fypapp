import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fyp_zakaty_app/providers/user_provider.dart';
import '../colors/colors.dart';
import '../assets.dart';
import '../pages/main_navigation.dart';
import '../widgets/form_fields.dart';
import '../widgets/background_image_container.dart';
import '../widgets/secondary_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final confirmPassController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

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

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        
        // Set loading indicator
        setState(() {});
        
        await userProvider.register(
          emailController.text.trim(),
          passController.text,
        );

        // Firebase auth listener in UserProvider will update the user
        // Check after a short delay to ensure auth state has propagated
        await Future.delayed(Duration(milliseconds: 500));
        
        if (mounted) {
          // Show success message whether or not userProvider.isAuthenticated is true yet
          // The Firebase auth state might take a moment to update
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'Registration successful! Welcome to ZakatApp',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          
          // Short delay to allow user to see the success message
          await Future.delayed(Duration(seconds: 1));
          
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => MainNavigation()),
            );
          }
        }
      } catch (e) {
        print('Registration error: ${e.toString()}');
        
        if (mounted) {
          // Display user-friendly error message
          String errorMessage = 'Registration failed';
          
          // Extract more specific error messages if available
          if (e.toString().contains('email-already-in-use')) {
            errorMessage = 'This email is already registered. Please use a different email or try logging in.';
          } else if (e.toString().contains('weak-password')) {
            errorMessage = 'Password is too weak. Please choose a stronger password.';
          } else if (e.toString().contains('invalid-email')) {
            errorMessage = 'The email address is not valid. Please check and try again.';
          } else if (e.toString().contains('network')) {
            errorMessage = 'Network error. Please check your internet connection and try again.';
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
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    }
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
                Padding(
                  padding: const EdgeInsets.only(left: 32, bottom: 15),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                        fontSize: 32,
                        color: AppColor.kLightAccentColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColor.kSamiDarkColor.withOpacity(0.8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.kSamiDarkColor.withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        CustomRichText(
                          title: '',
                          subtitle: 'Looks like you don\'t have an account. Let\'s create a new account for you.',

                          subtitleTextStyle: TextStyle(
                            color: AppColor.kLightAccentColor,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                          onTab: () {},
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: nameController,
                          validator: _validateName,
                          decoration: InputDecoration(
                            hintText: 'Name',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: emailController,
                          validator: _validateEmail,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: passController,
                          validator: _validatePassword,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
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
                        TextFormField(
                          controller: confirmPassController,
                          validator: _validateConfirmPassword,
                          obscureText: !_isConfirmPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'Confirm Password',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: AppColor.kLightAccentColor,
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                            children: [
                              const TextSpan(text: 'By selecting Create Account below, '),
                              const TextSpan(text: 'I agree to '),
                              TextSpan(
                                text: 'Terms of Service',
                                style: TextStyle(
                                  color: AppColor.kPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const TextSpan(text: ' & '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  color: AppColor.kPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 326,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: userProvider.isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.kPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: userProvider.isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    'Create Account',
                                    style: TextStyle(
                                      color: AppColor.kWhiteColor,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),
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
                        const SizedBox(height: 24),
                        CustomRichText(
                          title: 'Already have an account?',
                          subtitle: ' Log in',
                          subtitleTextStyle: TextStyle(
                            color: AppColor.kPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter',
                          ),
                          onTab: () {
                            Navigator.pushReplacementNamed(context, '/login');
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

