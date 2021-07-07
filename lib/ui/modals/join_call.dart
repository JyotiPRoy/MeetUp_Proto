import 'package:flutter/material.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';
import 'package:ms_engage_proto/ui/screens/call_screen_web.dart';
import 'package:ms_engage_proto/ui/screens/group_call_screen.dart';
import 'package:ms_engage_proto/ui/widgets/default_button.dart';
import 'package:ms_engage_proto/ui/widgets/input_field.dart';

class JoinCallDialog extends StatefulWidget {
  final bool isGroupCall;

  const JoinCallDialog({
    Key? key,
    required this.isGroupCall
  }) : super(key: key);

  @override
  _JoinCallDialogState createState() => _JoinCallDialogState();
}

class _JoinCallDialogState extends State<JoinCallDialog> {

  TextEditingController _idController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 35),
      height: 250,
      width: 450,
      child: Column(
        children: [
          InputField(
            controller: _idController,
            validator: (val){return null;},
            fieldName: 'RoomID',
          ),
          Expanded(
            child: SizedBox(),
          ),
          DefaultButton(
            fixedSize: Size(400, 60),
            onPress: (){
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_)
                  => widget.isGroupCall
                      ? GroupCallScreen(roomID: _idController.text)
                      : CallScreenWeb(host: false, roomID: _idController.text))
              );
            },
            child: Text(
              'Join Call',
              style: TextStyle(
                color: AppStyle.whiteAccent,
                fontSize: 18
              ),
            ),
          )
        ],
      ),
    );
  }
}
