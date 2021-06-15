import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:ms_engage_proto/core/Session.dart';
import 'package:ms_engage_proto/core/rtc_core.dart';

class CallScreen extends StatefulWidget {
  final bool makeCall;
  final String? sessionID;

  CallScreen({required this.makeCall, this.sessionID});

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  late Session _session;
  String? _sessionID;

  @override
  void initState() {
    super.initState();
    _initRenderers().then((value) async{
      _session = Session(
        sessionID: widget.sessionID
      );
      setState(() {
        _sessionID = _session.sessionID; //To update room header
      });
      _session.onLocalStream = (stream){
        _localRenderer.srcObject = stream;
        setState(() {});
      };
      _session.onAddRemoteStream = (stream){
        print('REMOTE STREAM ADDED!');
        _remoteRenderer.srcObject = stream;
        setState(() {});
      };
      _session.onRemoveRemoteStream = (stream){
        _remoteRenderer.srcObject = null;
        setState(() {});
      };
      await _session.initialize(isOffer: widget.makeCall);
    }).then((value) {
      widget.makeCall ? _session.makeCall() : _session.answerCall();
    });

    Timer.periodic(Duration(seconds: 10), (timer){
      setState(() {
        print('SET STATE!');
      });
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

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Icon(Icons.call_end),
      ),
      appBar: AppBar(
        title: SelectableText('RoomID: ${_sessionID ?? '...'}'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(
              horizontal: 10),
          child: Stack(
            children: [
              Positioned.fill(
                child: RTCVideoView(_remoteRenderer),
              ),
              Positioned(
                top: 10,
                left: 5,
                child: Container(
                  height: height * 0.19,
                  width: width * 0.3,
                  child: RTCVideoView(_localRenderer),
                ),
              ),
            ],
          ),




          // child: Column(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   crossAxisAlignment: CrossAxisAlignment.center,
          //   children: [
          //     Container(
          //       height: kIsWeb ? 400 : 200,
          //       width: 480,
          //       decoration: BoxDecoration(
          //         border: Border.all(color: Colors.black, width: 1.5),
          //       ),
          //       child: RTCVideoView(_localRenderer),
          //     ),
          //     SizedBox(
          //       height: height * 0.005,
          //     ),
          //     Container(
          //       height: kIsWeb ? 400 : 200,
          //       width: 480,
          //       decoration: BoxDecoration(
          //         border: Border.all(color: Colors.black, width: 1.5)
          //       ),
          //       child: RTCVideoView(_remoteRenderer),
          //     ),
          //   ],
          // ),
        ),
      ),
    );
  }
}
