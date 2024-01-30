import 'package:flutter/material.dart';

import 'app_dimensions.dart';


class AppTextStyles{
  AppTextStyles._();

  static String appFont = "dubai";

  static TextStyle regular({
    double fontSize = AppDimensions.medium,
    Color color = Colors.black,
    TextDecoration? textDecoration,
  }){
    return TextStyle(
      fontFamily: appFont,
      fontSize: fontSize,
      fontWeight:  FontWeight.w400,
      color: color,
      decoration: textDecoration,
    );
  }

  static TextStyle medium({
    double fontSize = AppDimensions.medium,
    Color color = Colors.black,
    TextDecoration? textDecoration,
    double? height
  }){
    return TextStyle(
      fontFamily: appFont,
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: color,
      decoration: textDecoration,
      height: height
    );
  }

  static TextStyle bold({
    double fontSize = AppDimensions.medium,
    Color color = Colors.black,
    TextDecoration? textDecoration
  }){
    return TextStyle(
      fontFamily: appFont,
      fontSize: fontSize,
      fontWeight:  FontWeight.w700,
      color: color,
      decoration: textDecoration,
    );
  }
}