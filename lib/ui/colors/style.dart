
import 'package:flutter/material.dart';

class AppStyle{
  static final primaryColor = Color.fromRGBO(29, 31, 46, 1);
  static final secondaryColor = Color.fromRGBO(40, 42, 59, 1);
  static final whiteAccent = Colors.white;
  static final darkBorderColor = Colors.white10;
  static final defaultBorderColor = Colors.white24;
  static final defaultUnselectedColor = Color.fromRGBO(123, 125, 134, 1);
  static final defaultSplash = Colors.black12;
  static final defaultTextColor = Color.fromRGBO(199, 198, 201, 1);
  static final primaryButtonColor = Color.fromRGBO(17, 121, 248, 1);
  static final primaryHomeAction = Color.fromRGBO(237, 113, 46, 1);

  static Text defaultHeaderText(String text) => Text(
    text,
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 26
    ),
  );
}