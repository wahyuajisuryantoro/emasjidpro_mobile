import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppText {
  // Heading Styles
  static TextStyle h1({Color? color}) => GoogleFonts.rubik(
        fontSize: 40,
        letterSpacing: -0.5,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle h2({Color? color}) => GoogleFonts.rubik(
        fontSize: 32,
        letterSpacing: -0.5,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle h3({Color? color}) => GoogleFonts.rubik(
        fontSize: 28,
        letterSpacing: 0,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle h4({Color? color}) => GoogleFonts.rubik(
        fontSize: 24,
        letterSpacing: 0.25,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle h5({Color? color}) => GoogleFonts.rubik(
        fontSize: 20,
        letterSpacing: 0,
        fontWeight: FontWeight.w600,
        color: color,
      );

       static TextStyle h5thin({Color? color}) => GoogleFonts.rubik(
        fontSize: 20,
        letterSpacing: 0,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle h6({Color? color}) => GoogleFonts.rubik(
        fontSize: 16,
        letterSpacing: 0.15,
        fontWeight: FontWeight.w600,
        color: color,
      );

  // Paragraph Styles
  static TextStyle p({Color? color}) => GoogleFonts.rubik(
        fontSize: 16,
        letterSpacing: 0,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle pLead({Color? color}) => GoogleFonts.rubik(
        fontSize: 20,
        letterSpacing: 0,
        height: 1.5,
        fontWeight: FontWeight.w300,
        color: color,
      );

  static TextStyle pSmall({Color? color}) => GoogleFonts.rubik(
        fontSize: 14,
        letterSpacing: 0,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: color,
      );
  
  static TextStyle pSmallBold({Color? color}) => GoogleFonts.rubik(
        fontSize: 14,
        letterSpacing: 0,
        height: 1.5,
        fontWeight: FontWeight.w600,
        color: color,
      );


  // Small Text Style
  static TextStyle small({Color? color}) => GoogleFonts.rubik(
        fontSize: 12,
        letterSpacing: 0,
        height: 1.2,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle smallBold({Color? color}) => GoogleFonts.rubik(
        fontSize: 12,
        letterSpacing: 0,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: color,
      );

  // Body Text Styles
  static TextStyle bodyLarge({Color? color}) => GoogleFonts.rubik(
        fontSize: 16,
        letterSpacing: 0.5,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle bodyMedium({Color? color}) => GoogleFonts.rubik(
        fontSize: 14,
        letterSpacing: 0.25,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle bodySmall({Color? color}) => GoogleFonts.rubik(
        fontSize: 12,
        letterSpacing: 0.4,
        fontWeight: FontWeight.w400,
        color: color,
      );

  // Button & Caption Styles
  static TextStyle button({Color? color}) => GoogleFonts.rubik(
        fontSize: 14,
        letterSpacing: 1.25,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle caption({Color? color}) => GoogleFonts.rubik(
        fontSize: 12,
        letterSpacing: 0.4,
        fontWeight: FontWeight.w400,
        color: color,
      );

  // Overline Style
  static TextStyle overline({Color? color}) => GoogleFonts.rubik(
        fontSize: 10,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w400,
        color: color,
      );
}