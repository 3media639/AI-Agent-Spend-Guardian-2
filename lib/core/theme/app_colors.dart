import 'package:flutter/material.dart';

/// SpendGuard iOS Design Palette
/// Inspired by clean iOS Apple System & Life Admin aesthetics
/// Teal accent (#0E7C86 / #3CB8C3), pristine frosted backgrounds, soft translucent cards & badges
class AppColors {
  // Primary iOS Teal Brand Accents (Exact match with user prototype)
  static const Color primaryEmerald = Color(0xFF0E7C86); // Deep Teal
  static const Color primaryEmeraldDark = Color(0xFF0A5C64);
  static const Color primaryEmeraldLight = Color(0xFF3CB8C3); // Vibrant Cyan-Teal
  static const Color primaryTealSurface = Color(0x1F0E7C86); // 12% opacity accent

  // Safety & Emergency Freeze
  static const Color emergencyRed = Color(0xFFD6423A);
  static const Color emergencyRedDark = Color(0xFFB91C1C);
  static const Color emergencyRedLight = Color(0xFFFF6259);
  static const Color emergencyRedSurface = Color(0x24D6423A);

  // Warnings & Alerts
  static const Color warningAmber = Color(0xFFD98200);
  static const Color warningAmberLight = Color(0xFFF0A030);
  static const Color warningAmberSurface = Color(0x28D98200);
  static const Color successGreen = Color(0xFF2E9B5F);
  static const Color successGreenLight = Color(0xFF4CC27F);
  static const Color successGreenSurface = Color(0x262E9B5F);
  static const Color infoBlue = Color(0xFF0E7C86);

  // iOS Light Theme Palette
  static const Color lightPage = Color(0xFFE9EBF0);
  static const Color lightBg = Color(0xFFF4F5F8);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardTranslucent = Color(0xB8FFFFFF); // rgba(255,255,255,.72)
  static const Color lightCardHover = Color(0xFFEEF0F4);
  static const Color lightBorder = Color(0x1F3C3C43); // rgba(60,60,67,.12)
  static const Color lightTextPrimary = Color(0xFF1C1C1E);
  static const Color lightTextSecondary = Color(0xFF6E6E73);
  static const Color lightTextMuted = Color(0xFF8E8E93);

  // iOS Dark Theme Palette
  static const Color darkPage = Color(0xFF08090B);
  static const Color darkBg = Color(0xFF0E0F12);
  static const Color darkCard = Color(0xFF1C1D22);
  static const Color darkCardTranslucent = Color(0x9E2C2E36); // rgba(44,46,54,.62)
  static const Color darkCardHover = Color(0xFF26272F);
  static const Color darkBorder = Color(0x17FFFFFF); // rgba(255,255,255,.09)
  static const Color darkTextPrimary = Color(0xFFF2F2F7);
  static const Color darkTextSecondary = Color(0xFF9A9AA2);
  static const Color darkTextMuted = Color(0xFF636366);

  // Provider Brand Identifiers
  static const Color providerOpenAI = Color(0xFF10A37F);
  static const Color providerClaude = Color(0xFFD97706);
  static const Color providerGemini = Color(0xFF2563EB);
  static const Color providerGroq = Color(0xFFEA580C);
}
