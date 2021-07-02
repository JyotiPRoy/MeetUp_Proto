import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ms_engage_proto/call_screen.dart';
import 'package:ms_engage_proto/provider/RTCProvider.dart';
import 'package:ms_engage_proto/provider/core_services_provider.dart';
import 'package:ms_engage_proto/core/rtc_core.dart';
import 'package:ms_engage_proto/model/user.dart';
import 'package:ms_engage_proto/services/auth.dart';
import 'package:ms_engage_proto/store/session_data.dart';
import 'package:ms_engage_proto/ui/screens/dashboard.dart';
import 'package:ms_engage_proto/ui/screens/landing_screen.dart';
import 'package:ms_engage_proto/ui/screens/splash_screen.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        //TODO: ADD NAMED ROUTES HERE
      },
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Montserrat',
      ),
      home: false
      ? Dashboard()
      :FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot){
                Auth auth = Auth();
                print('${snapshot.data == null} + ${snapshot.hasData} + ${snapshot.connectionState == ConnectionState.active}');
                if(snapshot.connectionState == ConnectionState.active){
                  if(snapshot.hasData && (snapshot.data != null)){
                    return FutureBuilder<UserProfile?>(
                      future: auth.getProfileFromFirebase(snapshot.data!.uid),
                      builder: (context, snapshot) {
                        if(snapshot.hasData && snapshot.data != null){
                          SessionData.instance.updateUser(snapshot.data!);
                          return MultiProvider(
                            providers: [
                              StreamProvider<User?>.value(
                                value: FirebaseAuth.instance.authStateChanges(),
                                initialData: null,
                              ),
                            ],
                            child: CoreServicesProvider(
                              auth: auth,
                              child: Dashboard(),
                            ),
                          );
                        }
                        return SplashScreen();
                      }
                    );
                  }else if((snapshot.data == null)){
                    return LandingPage();
                  }
                }
                return SplashScreen();
              },
            );
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
    // final rtcCore = RTCProvider.of(context).core;
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
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => CallScreenWeb()));
                },
                child: Text('Connect'),
              ),
            ],
          ),
          SizedBox(
            height: height * 0.05,
          ),
        ],
      ),
    );
  }
}
