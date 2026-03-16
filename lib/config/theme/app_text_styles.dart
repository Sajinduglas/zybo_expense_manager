import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Inter';

  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 24.0,
    color: AppColors.textPrimary,
    height: 1.5, // 36px line height
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 18.0,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 16.0, 
    color: AppColors.textPrimary, 
  );
  static const TextStyle body15 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 15.0,
    color: AppColors.textPrimary, 
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 18.0,
    color: AppColors.white,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 13.0,
    color: AppColors.textSecondary,
  );

  static const TextStyle onboardingTitle = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 32.0,
    color: AppColors.white,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle onboardingBody = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 16.0,
    color: AppColors.white,
  );

  static const TextStyle authTitle = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 24.0,
    color: AppColors.white,
  );

  static const TextStyle authSubtitle = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 15.0,
    color: AppColors.white,
    // Note: opacity handled at call site via copyWith or predefined tokens
  );

  static const TextStyle authBody15 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 15.0,
    color: AppColors.white,
  );

  static const TextStyle authButtonText = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 16.0,
    color: AppColors.white,
  );

  // Home Screen Styles
  static const TextStyle homeWelcome = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 20.0,
    color: AppColors.white,
  );

  static const TextStyle homeCardTitle = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 13.0,
    color: AppColors.white,
  );

  static const TextStyle homeCardAmount = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 20.0,
    color: AppColors.white,
  );

  static const TextStyle homeSectionTitle = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 16.0,
    color: AppColors.white,
  );

  static const TextStyle homeLimitLabel = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 13.0,
    color: AppColors.white,
  );

  static const TextStyle homeLimitAmount = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 16.0,
    color: AppColors.white,
  );

  // Transaction List Styles
  static const TextStyle txName = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 16.0,
    color: AppColors.white,
  );

  static const TextStyle txCategory = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 14.0,
    color: AppColors.transactionListMuted,
  );

  static const TextStyle txDate = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 13.0,
    color: AppColors.transactionListMuted,
  );

  static const TextStyle txAmount = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 22.0,
  );

  // Profile Screen Styles
  static const TextStyle profileNickname = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 16.0,
    color: AppColors.white,
  );

  static const TextStyle profileSectionTitle = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 20.0,
    color: AppColors.white,
  );

  static const TextStyle profileSectionLabel = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 14.0,
    color: AppColors.white,
  );

  static const TextStyle profileLimitHint = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 18.0,
    color: AppColors.white,
  );

  static const TextStyle profileLimitCurrent = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 15.0,
    color: AppColors.white,
  );

  static const TextStyle profileLimitAmount = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 16.0,
    color: AppColors.white,
  );

  static const TextStyle profileHint600 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 15.0,
    color: AppColors.profileNicknameText,
  );

  static const TextStyle profileItemName = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 16.0,
    color: AppColors.white,
  );
}
