import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';
import 'package:ms_engage_proto/ui/widgets/default_button.dart';
import 'package:ms_engage_proto/ui/widgets/header_toggle_buttons.dart';

class WebHeader extends StatelessWidget with PreferredSizeWidget {
  final String title;
  final String roomID;

  WebHeader({
    Key? key,
    required this.title,
    required this.roomID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppStyle.primaryColor,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 100,
          ),
          SizedBox(), // TODO: Determine the space b/w logo and the back button
          DefaultButton(
            onPress: (){},
            child: Padding(
              padding: EdgeInsets.only(left: 6),
              child: Icon(Icons.arrow_back_ios, size: 18,),
            ),
            fixedSize: Size(45, 55),
            buttonColor: AppStyle.primaryColor,
            buttonBorder: BorderSide(
              color: AppStyle.defaultBorderColor,
              width: 2.0
            ),
          ),
          SizedBox(
            width: width * 0.01,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppStyle.defaultHeaderText(title),
              SizedBox(
                height: 4,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SelectableText(
                    'Room ID: $roomID',
                    style: TextStyle(
                        color: AppStyle.defaultTextColor,
                        fontSize: 16
                    ),
                  ),
                ],
              )
            ],
          ),
          SizedBox(
            width: width * 0.53,
          ),
          // DefaultButton(
          //   onPress: (){},
          //   fixedSize: Size(125, 55),
          //   buttonColor: AppStyle.headerActionButtonColor,
          //   child: Row(
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       Icon(
          //         Icons.add,
          //         color: AppStyle.whiteAccent,
          //         size: 20,
          //       ),
          //       SizedBox(
          //         width: 8,
          //       ),
          //       Text(
          //         'Invite',
          //         style: TextStyle(
          //           color: AppStyle.whiteAccent,
          //           fontSize: 18,
          //           letterSpacing: 1.1
          //         ),
          //       )
          //     ],
          //   ),
          // ),
          SizedBox(
            width: width * 0.07,
          ),
          // VerticalDivider(
          //   width: 1,
          //   color: AppStyle.buttonBorderColor,
          //   indent: 22.5,
          //   endIndent: 22.5,
          // ),
          SizedBox(
            width: width * 0.005,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              HeaderToggleButtons(),
            ],
          )
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(100);
}
