import 'package:flutter/material.dart';

const kButtonBorderRadius = 15.0;

class DefaultButton extends StatelessWidget {
  final VoidCallback onPress;
  final VoidCallback? onLongPress;
  final Widget child;
  final Color? buttonColor;
  final Color? overlayColor;
  final ButtonStyle? style;
  final BorderSide? buttonBorder;
  final Size? fixedSize;
  final double? elevation;

  DefaultButton({
    Key? key,
    required this.onPress,
    this.onLongPress,
    required this.child,
    this.buttonColor,
    this.overlayColor,
    this.style,
    this.buttonBorder,
    this.fixedSize,
    this.elevation
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPress,
      child: child,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(buttonColor),
        fixedSize: fixedSize != null ? MaterialStateProperty.all(fixedSize) : null,
        elevation: MaterialStateProperty.all(elevation),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kButtonBorderRadius),
            side: buttonBorder ?? BorderSide.none
          )
        )
      ),
    );
  }
}
