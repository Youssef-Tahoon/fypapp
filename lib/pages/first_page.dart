import 'package:flutter/material.dart';
import '../colors/colors.dart';
import '../assets.dart';
import '../widgets/form_fields.dart'; // Assuming you moved PrimaryButton here
import 'package:dots_indicator/dots_indicator.dart'; // Make sure this is in pubspec

class Onboarding {
  final String bgImage;
  final String title;
  final String info;

  Onboarding({
    required this.bgImage,
    required this.title,
    required this.info,
  });
}

final List<Onboarding> onboardingList = [
  Onboarding(
    bgImage: AppImagePath.kRectangleBackgound,
    title: 'Understand Zakat Easily',
    info: 'Learn how and when to pay Zakat with confidence and accuracy.',
  ),
  Onboarding(
    bgImage: AppImagePath.kRectangleBackgound,
    title: 'Help Those in Need',
    info: 'Discover real cases and make a meaningful impact with your Zakat.',
  ),
  Onboarding(
    bgImage: AppImagePath.kRectangleBackgound,
    title: 'Track Your Contributions',
    info: 'View your payment history and manage your obligations simply.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final onboarding = onboardingList[_currentIndex];

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(onboarding.bgImage),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AppColor.kSamiDarkColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Column(
            children: [
              const Spacer(),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: onboardingList.length,
                  onPageChanged: (index) => setState(() => _currentIndex = index),
                  itemBuilder: (context, index) {
                    final item = onboardingList[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item.info,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              DotsIndicator(
                dotsCount: onboardingList.length,
                position: _currentIndex,
                decorator: DotsDecorator(
                  activeColor: AppColor.kPrimary,
                  size: const Size.square(8.0),
                  activeSize: const Size(24.0, 8.0),
                  activeShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              PrimaryButton(
                onTap: () {
                  if (_currentIndex == onboardingList.length - 1) {
                    Navigator.pushReplacementNamed(context, '/register');
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                    );
                  }
                },
                text: _currentIndex == onboardingList.length - 1
                    ? "Get Started"
                    : "Continue",
                height: 50,
                width: double.infinity,
                textColor: Colors.white,
                bgColor: AppColor.kPrimary,
                borderRadius: 12,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
