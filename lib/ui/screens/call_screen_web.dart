import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ms_engage_proto/core/Session.dart';
import 'package:ms_engage_proto/model/chat.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';
import 'package:ms_engage_proto/ui/modals/error_dialog.dart';
import 'package:ms_engage_proto/ui/modals/room_info.dart';
import 'package:ms_engage_proto/ui/widgets/chat_viewer.dart';
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
  late CallSession _session;
  final chatViewController = StreamController<SessionChat>.broadcast();
  double _chatWindowWidth = 0.0;

  bool _micEnabled = true;
  bool _videoEnabled = true;
  bool _remoteStreamAdded = false;

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

  Future<void> _showErrorDialog(String title, String message) async {
    Dialog signUp = Dialog(

      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: AppStyle.primaryColor,
      child: ErrorDialog(
        title: title,
        content: message,
        okTapped: (){
          Navigator.of(context).pop();
          _session.createStream();
        },
        cancelTapped: (){
          Navigator.of(context).pop();
          Navigator.of(context).pop();
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
    final callDoc = FirebaseFirestore.instance
          .collection('calls').doc(widget.roomID);
    _initRenderers().then((value) async{
      _session = CallSession(
        callDoc: callDoc,
        onError: _onError

      );
      _session.onLocalStream = (stream){
        setState(() {
          _localRenderer.srcObject = stream;
          if(_session.videoEnabled){
            rendererContainer.add(getVideoView(_localRenderer));
          }
        });
      };
      _session.onAddRemoteStream = (stream){
        print('REMOTE STREAM ADDED!');
        _remoteRenderer.srcObject = stream;
        setState(() {
          if(!_remoteStreamAdded){
            rendererContainer.add(getVideoView(_remoteRenderer));
          }
          _remoteStreamAdded = true;
        });
      };

      _session.onTrack = (trackEvent){
        if(_remoteStreamAdded){
          setState(() {
            var oldTrack = _remoteRenderer.srcObject!.getVideoTracks()[0];
            _remoteRenderer.srcObject!.removeTrack(oldTrack);
            _remoteRenderer.srcObject!.addTrack(trackEvent.track);
          });
        }
      };

      _session.onRemoveRemoteStream = (stream){
        _remoteRenderer.srcObject = null;
        setState(() {});
      };
      await _session.initialize(isOffer: widget.host);
    }).then((value) async {
      widget.host ? _session.makeCall() : _session.answerCall();
      _session.sessionChatController.stream.listen((sessionChat) {
        chatViewController.add(sessionChat);
      });
      await _showRoomInfo(context);
    });
  }

  Future<void> _showRoomInfo(BuildContext context) async {
    Dialog roomInfo = Dialog(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: AppStyle.primaryColor,
      child: RoomInfoDialog(roomID: widget.roomID,),
    );
    await showDialog<Dialog>(
      context: context,
      builder: (context) => roomInfo,
    );
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
                      SelectableText(
                        'RoomID: ${widget.roomID}',
                        style: TextStyle(
                            color: AppStyle.defaultUnselectedColor,
                            fontSize: 14),
                      )
                    ],
                  ),
                  Expanded(
                    child: SizedBox(),
                  ),
                  DefaultButton(
                    onPress: (){
                      setState(() {
                        _chatWindowWidth
                          = _chatWindowWidth > 0 ? 0.0 : width * 0.2;
                      });
                    },
                    child: Icon(
                      FontAwesomeIcons.commentAlt,
                      color: AppStyle.whiteAccent,
                      size: 18,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                    buttonBorder: BorderSide(
                      color: AppStyle.defaultBorderColor
                    ),
                    buttonColor: AppStyle.secondaryColor,
                  ),
                  SizedBox(width: 16,),
                  DefaultButton(
                    onPress: () async => _showRoomInfo(context),
                    child: Icon(
                      FontAwesomeIcons.share,
                      color: AppStyle.whiteAccent,
                      size: 18,
                    ),
                    buttonColor: AppStyle.secondaryColor,
                    buttonBorder:
                    BorderSide(color: AppStyle.defaultBorderColor),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                  ),
                ],
              ),
            ),
            Container(
              width: width,
              height: height * 0.77,
              color: Colors.black,
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: rendererContainer,
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _chatWindowWidth,
                    padding: EdgeInsets.symmetric(
                        horizontal: 20, vertical: 22),
                    color: AppStyle.primaryColor,
                    child: ChatViewer(
                      viewController: chatViewController.stream,
                      isSession: true,
                    ),
                  )
                ],
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
                      setState(() {
                        _session.toggleMuteMic();
                        _micEnabled = !_micEnabled;
                      });
                    },
                    child: Icon(
                      _micEnabled
                        ? FontAwesomeIcons.microphone
                        : FontAwesomeIcons.microphoneSlash,
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
                    onPress: () {
                      setState(() {
                        _session.toggleCamera();
                        _videoEnabled = !_videoEnabled;
                      });
                    },
                    child: Icon(
                      _videoEnabled
                          ? FontAwesomeIcons.video
                          : FontAwesomeIcons.videoSlash,
                      color: AppStyle.defaultUnselectedColor,
                    ),
                    buttonColor: AppStyle.secondaryColor,
                    buttonBorder:
                    BorderSide(color: AppStyle.defaultBorderColor),
                    padding: EdgeInsets.all(25),
                  ),
                  space,
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}