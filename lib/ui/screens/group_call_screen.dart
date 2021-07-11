import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ms_engage_proto/core/group_session.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';
import 'package:ms_engage_proto/ui/modals/error_dialog.dart';
import 'package:ms_engage_proto/ui/widgets/default_button.dart';

class GroupCallScreen extends StatefulWidget {
  final String roomID;
  final String title;
  const GroupCallScreen({
    Key? key,
    required this.roomID,
    this.title = 'Group Meeting',
  }) : super(key: key);

  @override
  _GroupCallScreenState createState() => _GroupCallScreenState();
}

class _GroupCallScreenState extends State<GroupCallScreen> {
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  bool _localRendererSet = false;
  Map<String,RTCVideoRenderer> _remoteRenderers = {};
  late GroupSession _groupSession;

  Widget getVideoView(RTCVideoRenderer renderer) => Expanded(
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

  void _onAddRemoteStream(MediaStream stream, String id) {
    var remoteRenderer = RTCVideoRenderer();
    remoteRenderer.initialize().whenComplete(() {
      remoteRenderer.srcObject = stream;
      _remoteRenderers[id] = remoteRenderer;
    });
    setState(() {
      rendererContainer.add(getVideoView(remoteRenderer));
    });
  }
  void _onAddLocalStream(MediaStream stream, String id){
    if(!_localRendererSet){
      _localRenderer.initialize().whenComplete((){
        _localRenderer.srcObject = stream;
      });
      setState(() {
        rendererContainer.add(getVideoView(_localRenderer));
      });
      _localRendererSet = true;
    }
  }

  Future<void> _showErrorDialog(String title, String message) async {
    Dialog signUp = Dialog(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: AppStyle.primaryColor,
      child: ErrorDialog(
        title: title,
        content: message,
        okTapped: () async {

        },
        cancelTapped: (){

        },
      ),
    );
    await showDialog<Dialog>(
      context: context,
      builder: (context) => signUp,
      barrierDismissible: false
    );
  }

  void _onError(String title, String message) {
    _showErrorDialog(title, message);
  }

  @override
  void initState() {
    super.initState();
    _groupSession = GroupSession(
      groupSessionID: widget.roomID,
      onAddRemote: _onAddRemoteStream,
      onAddLocal: _onAddLocalStream,
      onRemoveRemote: (stream,id){},
      onError: _onError
    );
    _groupSession.joinCall();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderers.values.forEach((renderer) {
      renderer.dispose();
    });
    super.dispose();
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
