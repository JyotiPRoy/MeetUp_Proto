
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';
import 'package:ms_engage_proto/ui/widgets/default_button.dart';

class HeaderToggleButtons extends StatefulWidget {
  HeaderToggleButtons({Key? key}) : super(key: key);

  @override
  _HeaderToggleButtonsState createState() => _HeaderToggleButtonsState();
}

class _HeaderToggleButtonsState extends State<HeaderToggleButtons> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        DefaultButton(
          onPress: (){},
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.commentDots,
                color: AppStyle.whiteAccent,
                size: 20,
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                'Chat',
                style: TextStyle(
                    color: AppStyle.whiteAccent,
                    fontSize: 18
                ),
              )
            ],
          ),
          buttonColor: _selectedIndex == 0
              ? AppStyle.primaryButtonColor
              : AppStyle.primaryColor,
          fixedSize: Size(160,55),
          buttonBorder: _selectedIndex != 0
              ? BorderSide(
                  color: AppStyle.buttonBorderColor,
                  width: 2.0
                )
              : BorderSide.none,
        ),
        SizedBox(
          width: 10,
        ),
        DefaultButton(
          onPress: (){},
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.group,
                color: AppStyle.whiteAccent,
                size: 20,
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                'Participants',
                style: TextStyle(
                  color: AppStyle.whiteAccent,
                  fontSize: 18
                ),
              )
            ],
          ),
          buttonColor: _selectedIndex == 1
              ? AppStyle.primaryButtonColor
              : AppStyle.primaryColor,
          fixedSize: Size(160,55),
          buttonBorder: _selectedIndex != 1
              ? BorderSide(
              color: AppStyle.buttonBorderColor,
              width: 2.0
          )
              : BorderSide.none,
        )
      ],
    );
  }
}
