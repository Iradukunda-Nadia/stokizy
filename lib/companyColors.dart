
import 'package:flutter/material.dart';

class CompanyColors{
  static const MaterialColor appcolor = MaterialColor(_appcolorPrimaryValue, <int, Color>{
    50: Color(0xFFF8F6FB),
    100: Color(0xFFEDE8F6),
    200: Color(0xFFE1D8F0),
    300: Color(0xFFD5C8EA),
    400: Color(0xFFCCBDE6),
    500: Color(_appcolorPrimaryValue),
    600: Color(0xFFBDAADD),
    700: Color(0xFFB5A1D9),
    800: Color(0xFFAE98D5),
    900: Color(0xFFA188CD),
  });
  static const int _appcolorPrimaryValue = 0xFFC3B1E1;

  static const MaterialColor appcolorAccent = MaterialColor(_appcolorAccentValue, <int, Color>{
    100: Color(0xFFFFFFFF),
    200: Color(_appcolorAccentValue),
    400: Color(0xFFFAF6FF),
    700: Color(0xFFE9DDFF),
  });
  static const int _appcolorAccentValue = 0xFFFFFFFF;
}