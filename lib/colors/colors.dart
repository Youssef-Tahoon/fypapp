import 'dart:ui';
import 'package:flutter/cupertino.dart';

class AppColor {
  static Color kPrimary = const Color(0xFFCA7CD8);
  static Color kBackGroundColor = const Color(0xFF2D3047);
  static Color kLightAccentColor = const Color(0xFFF4E5F7);
  static Color kGreyColor = const Color(0xFF939999);
  static Color kSamiDarkColor = const Color(0xFF313333);
  static Color kBlackColor = const Color(0xFF000000);
  static Color kWhiteColor = const Color(0xFFFFFFFF);
  static Color kGrey3Color = const Color(0xFF272828);
  static Color kBGColor = const Color(0xFF181A1A);
  static const Color kWhite = Color(0xFFFEFEFE);
  static LinearGradient customOnboardingGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      const Color(0xFF110C1D).withOpacity(0.0),
      const Color(0xFF110C1D),
    ],
  );
}