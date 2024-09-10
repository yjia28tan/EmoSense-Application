import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:emosense/design_widgets/app_color.dart';

final TextStyle titleBlack = GoogleFonts.leagueSpartan(
  color: AppColors.textColorBlack,
  fontWeight: FontWeight.bold,
  fontSize: 18,
);

final TextStyle whiteText = GoogleFonts.leagueSpartan(
  color: Color(0xFFF2F2F2),
  fontSize: 18,
  fontWeight: FontWeight.bold,
);

final TextStyle greySmallText = GoogleFonts.leagueSpartan(
  color: AppColors.textColorGrey,
  fontSize: 18,
  fontWeight: FontWeight.normal,
);


final TextStyle inkwellText = GoogleFonts.leagueSpartan(
  color: AppColors.darkPurpleColor,
  fontSize: 15,
  fontWeight: FontWeight.normal,
);

final TextStyle HomeButton = GoogleFonts.leagueSpartan(
  color: AppColors.textColorGrey,
  fontSize: 16,
  fontWeight: FontWeight.bold,
);



final TextStyle signupTitle = GoogleFonts.leagueSpartan(
  color: Color(0xFF8D68B8),
  fontWeight: FontWeight.bold,
  fontSize: 35,
);

final TextStyle headerText = GoogleFonts.leagueSpartan(
  color: Color(0xFFFFFFFF),
  fontSize: 24,
  fontWeight: FontWeight.bold,
);

final TextStyle homepageText = GoogleFonts.leagueSpartan(
  color: Color(0xFF1f1f1f),
  fontSize: 18,
  fontWeight: FontWeight.bold,
);

final TextStyle homeButtonText = GoogleFonts.leagueSpartan(
  color: Color(0xFFFFFFFF),
  fontSize: 18,
  fontWeight: FontWeight.w900,
);

final TextStyle userName_display = GoogleFonts.leagueSpartan(
  color: Color(0xFF8D68B8),
  fontWeight: FontWeight.bold,
  fontSize: 30,
);

const TextStyle moodText = TextStyle(
  color: Color(0xFF453276),
  fontSize: 15,
  fontWeight: FontWeight.bold,
);

const TextStyle aptosBody = TextStyle(
  fontFamily: 'Aptos',       // Use the family name you defined in pubspec.yaml
  fontSize: 16,              // Body font size
  fontWeight: FontWeight.normal,
  color: Colors.black,       // Set the desired color
);

const TextStyle aptosBold = TextStyle(
  fontFamily: 'Aptos',
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: Colors.black,
);

const TextStyle aptosItalic = TextStyle(
  fontFamily: 'Aptos',
  fontSize: 16,
  fontStyle: FontStyle.italic,
  color: Colors.black,
);