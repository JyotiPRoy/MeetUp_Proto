
import 'package:flutter/material.dart';

class AppStyle{
  static final primaryColor = Color.fromRGBO(29, 31, 46, 1);
  static final secondaryColor = Color.fromRGBO(33, 37, 52, 1);
  static final whiteAccent = Colors.white;
  static final defaultBorderColor = Color.fromRGBO(48, 52, 66, 1);
  static final buttonBorderColor = Colors.white24;
  static final defaultSplash = Colors.black12;
  static final defaultTextColor = Color.fromRGBO(199, 198, 201, 1);
  static final primaryButtonColor = Color.fromRGBO(96, 183, 103, 1);

  static Text defaultHeaderText(String text) => Text(
    text,
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 26
    ),
  );
}