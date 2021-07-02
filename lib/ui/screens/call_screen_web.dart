import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ms_engage_proto/core/Session.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';
import 'package:ms_engage_proto/ui/widgets/default_button.dart';

class CallScreenWeb extends StatefulWidget {
  final bool host;
  final String roomID;
  final String title;

  CallScreenWeb({
    Key? key,
    required this.host,
    required this.roomID,
    this.title = 'Room Title',
  }) : super(key: key);

  @override
  _CallScreenWebState createState() => _CallScreenWebState();
}

class _CallScreenWebState extends State<CallScreenWeb> {
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  late Session _session;

  Widget getRenderer(RTCVideoRenderer renderer) => Expanded(
        child: Container(
          child: RTCVideoView(renderer),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(25)),
              border: Border.all(
                  color: AppStyle.defaultBorderColor,
                  width: 2),
          ),
        ),
      );

  List<Widget> rendererContainer = [];

  @override
  void initState() {
    super.initState();

    _initRenderers().then((value) async{
      _session = Session(
          sessionID: widget.roomID
      );
      _session.onLocalStream = (stream){
        _localRenderer.srcObject = stream;
        setState(() {
          rendererContainer.add(getRenderer(_localRenderer));
        });
      };
      _session.onAddRemoteStream = (stream){
        print('REMOTE STREAM ADDED!');
        _remoteRenderer.srcObject = stream;
        setState(() {
          rendererContainer.add(getRenderer(_remoteRenderer));
        });
      };
      _session.onRemoveRemoteStream = (stream){
        _remoteRenderer.srcObject = null;
        setState(() {});
      };
      await _session.initialize(isOffer: widget.host);
    }).then((value) {
      widget.host ? _session.makeCall() : _session.answerCall();
    });
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  @override
  void dispose() {
    super.dispose();
    _remoteRenderer.dispose();
    _localRenderer.dispose();
    _session.endCall();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final space = SizedBox(
      width: 25,
    );

    return Scaffold(
      backgroundColor: AppStyle.primaryColor,
      body: Container(
        width: width,
        height: height,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    height: 55,
                    width: 55,
                    decoration: BoxDecoration(
                      color: AppStyle.primaryButtonColor,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Icon(
                      FontAwesomeIcons.video,
                      color: AppStyle.whiteAccent,
                    ),
                  ),
                  SizedBox(
                    width: width * 0.04,
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).maybePop();
                    },
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: AppStyle.whiteAccent,
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppStyle.defaultHeaderText(widget.title),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        'RoomID: ${widget.roomID}',
                        style: TextStyle(
                            color: AppStyle.defaultUnselectedColor,
                            fontSize: 14),
                      )
                    ],
                  )
                ],
              ),
            ),
            Container(
              width: width,
              height: height * 0.77,
              color: Colors.black,
              child: Row(
                children: rendererContainer,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  DefaultButton(
                    onPress: () {

                    },
                    child: Icon(
                      FontAwesomeIcons.microphone,
                      color: AppStyle.defaultUnselectedColor,
                    ),
                    buttonColor: AppStyle.secondaryColor,
                    buttonBorder:
                        BorderSide(color: AppStyle.defaultBorderColor),
                    padding: EdgeInsets.all(25),
                  ),
                  space,
                  DefaultButton(
                    onPress: () {},
                    child: Icon(
                      FontAwesomeIcons.video,
                      color: AppStyle.defaultUnselectedColor,
                    ),
                    buttonColor: AppStyle.secondaryColor,
                    buttonBorder:
                        BorderSide(color: AppStyle.defaultBorderColor),
                    padding: EdgeInsets.all(25),
                  ),
                  space,
                  DefaultButton(
                    onPress: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'End Call',
                      style:
                          TextStyle(color: AppStyle.whiteAccent, fontSize: 18),
                    ),
                    buttonColor: AppStyle.defaultErrorColor,
                    padding: EdgeInsets.symmetric(horizontal: 35, vertical: 25),
                  ),
                  space,
                  DefaultButton(
                    onPress: () {},
                    child: Icon(
                      FontAwesomeIcons.syncAlt,
                      color: AppStyle.defaultUnselectedColor,
                    ),
                    buttonColor: AppStyle.secondaryColor,
                    buttonBorder:
                        BorderSide(color: AppStyle.defaultBorderColor),
                    padding: EdgeInsets.all(25),
                  ),
                  space,
                  DefaultButton(
                    onPress: () {},
                    child: Icon(
                      FontAwesomeIcons.share,
                      color: AppStyle.defaultUnselectedColor,
                    ),
                    buttonColor: AppStyle.secondaryColor,
                    buttonBorder:
                        BorderSide(color: AppStyle.defaultBorderColor),
                    padding: EdgeInsets.all(25),
                  ),
                  space
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
