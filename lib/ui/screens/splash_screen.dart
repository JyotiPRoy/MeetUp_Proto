import 'package:flutter/material.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.primaryColor,
      body: Center(
        child: Container(
          height: 100,
          width: 100,
          child: CircularProgressIndicator(
            color: AppStyle.whiteAccent,
            strokeWidth: 6,
          ),
        ),
      ),
    );
  }
}
