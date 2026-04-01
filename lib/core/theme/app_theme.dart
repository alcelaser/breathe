import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFFCFCFC), // Very soft white
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFA3B19E), // Muted light sage
        surface: const Color(0xFFFCFCFC),
      ),
      cardTheme: const CardTheme(
        elevation: 0,
        color: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.transparent),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.zero,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w300,
          letterSpacing: 1.5,
          color: Color(0xFF424242),
        ),
        bodyMedium: TextStyle(
          fontWeight: FontWeight.w300,
          letterSpacing: 0.5,
          height: 1.6,
          color: Color(0xFF616161),
        ),
        bodyLarge: TextStyle(
          fontWeight: FontWeight.w300,
          letterSpacing: 0.5,
          color: Color(0xFF424242),
        ),
        labelLarge: TextStyle(
          fontWeight: FontWeight.w400,
          letterSpacing: 1.0,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: const Color(0xFFFCFCFC),
        indicatorColor: Colors.transparent,
        labelTextStyle: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(color: Color(0xFF424242), fontWeight: FontWeight.w500);
          }
          return const TextStyle(color: Color(0xFFBDBDBD));
        }),
        iconTheme: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: Color(0xFF424242));
          }
          return const IconThemeData(color: Color(0xFFBDBDBD));
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFFA3B19E),
          foregroundColor: const Color(0xFFFCFCFC),
          shape: const BeveledRectangleBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(letterSpacing: 2.0, fontWeight: FontWeight.w400),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: const Color(0xFF616161),
          side: const BorderSide(color: Color(0xFFEEEEEE)),
          shape: const BeveledRectangleBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(letterSpacing: 2.0, fontWeight: FontWeight.w400),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF616161),
          textStyle: const TextStyle(letterSpacing: 2.0, fontWeight: FontWeight.w400),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: const Color(0xFFA3B19E),
        inactiveTrackColor: const Color(0xFFEEEEEE),
        thumbColor: const Color(0xFFA3B19E),
        overlayColor: const Color(0xFFA3B19E).withOpacity(0.1),
        trackHeight: 2.0,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0, elevation: 0),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFFFCFCFC),
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
