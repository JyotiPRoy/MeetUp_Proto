
import 'package:flutter/material.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';
import 'package:ms_engage_proto/ui/widgets/web_header.dart';

class CallScreenWeb extends StatefulWidget {
  const CallScreenWeb({Key? key}) : super(key: key);

  @override
  _CallScreenWebState createState() => _CallScreenWebState();
}

class _CallScreenWebState extends State<CallScreenWeb> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.primaryColor,
      appBar: WebHeader(
        title: 'Design Discussion',
        roomID: 'bKLy89tts869IyHKj',
      ),
    );
  }
}
