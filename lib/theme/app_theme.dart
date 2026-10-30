import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const forest = Color(0xFF174B3A);
  static const leaf = Color(0xFF2F8B65);
  static const gold = Color(0xFFF1C66D);
  static const cream = Color(0xFFFFF8E9);
  static const ink = Color(0xFF18372E);

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: cream,
    colorScheme: ColorScheme.fromSeed(seedColor: forest, brightness: Brightness.light,
      primary: forest, secondary: gold, surface: cream),
    textTheme: GoogleFonts.nunitoTextTheme(),
    appBarTheme: const AppBarTheme(backgroundColor: forest, foregroundColor: Colors.white, elevation: 0),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
      backgroundColor: forest, foregroundColor: Colors.white, shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13))),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF101F1A),
    colorScheme: ColorScheme.fromSeed(seedColor: leaf, brightness: Brightness.dark),
    textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme),
  );
}
