import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';
import 'package:ms_engage_proto/ui/screens/call_screen_web.dart';
import 'package:ms_engage_proto/ui/screens/group_call_screen.dart';
import 'package:ms_engage_proto/ui/widgets/default_button.dart';
import 'package:ms_engage_proto/utils/misc_utils.dart';

class RoomInfoDialog extends StatelessWidget {
  final String roomID;

  const RoomInfoDialog({
    Key? key,
    required this.roomID
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: 400,
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Share Meeting Details',
            style: TextStyle(
                color: AppStyle.whiteAccent,
                fontSize: 20,
                fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(
            height: 40,
          ),
          Text(
            'Meeting ID:',
            style: TextStyle(
                color: AppStyle.defaultBorderColor,
                fontSize: 14
            ),
          ),
          SizedBox(
            height: 10,
          ),
          SelectableText(
            roomID,
            style: TextStyle(
                color:AppStyle.whiteAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(
            height: 45,
          ),
          Row(
            children: [
              Expanded(
                child: DefaultButton(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  onPress: (){
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                        color: AppStyle.whiteAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  buttonColor: AppStyle.secondaryColor,
                  buttonBorder: BorderSide(
                    color: AppStyle.defaultBorderColor
                  ),
                ),
              ),
              SizedBox(width: 16,),
              Expanded(
                child: DefaultButton(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  onPress: (){
                    Clipboard.setData(ClipboardData(text: roomID));
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Text(
                    'Copy ID',
                    style: TextStyle(
                        color: AppStyle.whiteAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
