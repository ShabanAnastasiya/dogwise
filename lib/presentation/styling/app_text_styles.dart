import 'package:flutter/material.dart';
import '../style/color.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const breedTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: GTColor.text,
  );

  static const breedSubtitle = TextStyle(
    fontSize: 14,
    color: GTColor.accent,
  );

  static const appBarTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: GTColor.text,
  );

  static const errorText = TextStyle(
    fontSize: 16,
    color: Colors.red,
    fontWeight: FontWeight.w500,
  );

  static const emptyText = TextStyle(
    fontSize: 16,
    color: GTColor.accent,
    fontStyle: FontStyle.italic,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.text,
  );
}
