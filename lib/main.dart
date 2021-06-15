import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ms_engage_proto/call_screen.dart';
import 'package:ms_engage_proto/core/RTCProvider.dart';
import 'package:ms_engage_proto/core/rtc_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    RTCProvider(
      core: RTCCore(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomePage();
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'ERROR INITIALIZING FIREBASE!',
                style: TextStyle(color: Colors.white, fontSize: 32),
              ),
            );
          } else
            return Center(
              child: Container(
                color: Colors.white,
                height: 40,
                width: 40,
                child: CircularProgressIndicator(),
              ),
            );
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController? _textController;
  String roomID = '';

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final rtcCore = RTCProvider.of(context).core;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.share),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => CallScreen(makeCall: true,)));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: Text('WebRTC demo'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: height * 0.05,
          ),
          Row(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: width * 0.4,
                child: TextField(
                  controller: _textController,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CallScreen(
                    makeCall: false,
                    sessionID: _textController!.text,
                  )));
                },
                child: Text('Connect'),
              ),
            ],
          ),
          SizedBox(
            height: height * 0.05,
          ),
          SelectableText('The Call ID is: ${rtcCore.rtcCallID}'),
        ],
      ),
    );
  }
}
