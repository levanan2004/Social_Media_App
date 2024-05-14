import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      background: Colors.grey[300]!,
      primary: Colors.white,
      secondary: Colors.grey[200]!,
      onBackground: Colors.grey[400]!,
      inversePrimary: Colors.grey[500]!,
    ),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: Colors.black)));
