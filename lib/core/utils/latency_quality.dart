import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

Color latencyColor(int latencyMs) {
  if (latencyMs < 35) return AppColors.accent;
  if (latencyMs < 80) return AppColors.warning;
  return AppColors.danger;
}
