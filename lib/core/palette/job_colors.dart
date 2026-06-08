// SPDX-License-Identifier: GPL-3.0-only
import 'package:flutter/material.dart';

/// 근무처 색상 고정 팔레트. 캘린더 dot, 카드 강조에 사용.
/// ARGB 정수로 DB에 저장.
class JobColors {
  static const List<Color> palette = [
    Color(0xFFEF4444), // red
    Color(0xFFF59E0B), // amber
    Color(0xFFFACC15), // yellow
    Color(0xFF22C55E), // green
    Color(0xFF06B6D4), // cyan
    Color(0xFF3B82F6), // blue
    Color(0xFF8B5CF6), // violet
    Color(0xFFEC4899), // pink
  ];

  static int defaultArgb() => palette.first.toARGB32();

  static Color fromArgb(int argb) => Color(argb);
}
