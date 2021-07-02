import 'package:flutter/material.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';
import 'package:ms_engage_proto/ui/screens/call_screen_web.dart';
import 'package:ms_engage_proto/ui/widgets/default_button.dart';
import 'package:ms_engage_proto/utils/misc_utils.dart';

class StartCallDialog extends StatelessWidget {
  const StartCallDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String roomID = MiscUtils.generateSecureRandomString(12);
    return Container(
      height: 250,
      width: 600,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 45),
              child: Column(
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    'Meeting ID:',
                    style: TextStyle(
                        color: AppStyle.defaultBorderColor,
                        fontSize: 14
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  SelectableText(
                    roomID,
                    style: TextStyle(
                        color:AppStyle.whiteAccent,
                        fontSize: 24,
                        fontWeight: FontWeight.bold
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 75),
              child: Column(
                children: [
                  DefaultButton(
                    onPress: (){
                      Navigator.pop(context);
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => CallScreenWeb(host: true, roomID: roomID))
                      );
                    },
                    child: Text(
                      'Join',
                      style: TextStyle(
                          color: AppStyle.whiteAccent,
                          fontSize: 18
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
