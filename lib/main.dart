import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ms_engage_proto/provider/core_services_provider.dart';
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
      home: FutureBuilder(
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
                          if(SessionData.instance.currentUser == null){
                            SessionData.instance.updateUser(snapshot.data!);
                          }
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
