import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Brand palette. Replace primaryBlue when the definitive INNPO value is
  // confirmed from the final brand manual.
  static const primaryBlue = Color(0xFF2B6F9C);
  static const darkNavy = Color(0xFF071C2E);
  static const darkNavyAlt = Color(0xFF0D2A43);
  static const technicalBlueGradientStart = Color(0xFF061726);
  static const technicalBlueGradientEnd = Color(0xFF103B5A);

  static const lightBackground = Color(0xFFF4F7FA);
  static const cardWhite = Color(0xFFFFFFFF);
  static const softBorder = Color(0xFFE2E8F0);
  static const neutralGrey = Color(0xFF64748B);
  static const textPrimary = Color(0xFF102033);

  static const successGreen = Color(0xFF19A55A);
  static const warningAmber = Color(0xFFF5A524);
  static const criticalRed = Color(0xFFD92D20);
  static const infoBlue = Color(0xFF2563EB);

  static const subtleShadow = Color(0x1A0F172A);

  // Backward-compatible aliases used across the existing feature code.
  static const corporateBlue = primaryBlue;
  static const technicalNavy = darkNavy;
  static const technicalNavyAlt = darkNavyAlt;
  static const surfaceWhite = cardWhite;
  static const surfaceSoft = lightBackground;
  static const separator = softBorder;
  static const textSecondary = neutralGrey;
  static const success = successGreen;
  static const warning = warningAmber;
  static const critical = criticalRed;
  static const info = infoBlue;
}
