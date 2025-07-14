import 'package:flutter/material.dart';
import 'color.dart';

class GTTextStyle {
  static const heading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: GTColor.text,
  );

  static const subtitle = TextStyle(
    fontSize: 16,
    color: GTColor.accent,
  );

  static const body = TextStyle(
    fontSize: 14,
    color: GTColor.text,
  );

  static const error = TextStyle(
    fontSize: 16,
    color: Colors.red,
    fontWeight: FontWeight.w500,
  );

  static const empty = TextStyle(
    fontSize: 16,
    color: GTColor.accent,
    fontStyle: FontStyle.italic,
  );
}
