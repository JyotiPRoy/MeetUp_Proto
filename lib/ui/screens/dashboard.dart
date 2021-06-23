import 'package:flutter/material.dart';
import 'package:ms_engage_proto/core/user.dart';
import 'package:ms_engage_proto/services/auth.dart';
import 'package:ms_engage_proto/store/global_store.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    UserProfile? user = GlobalStore.instance.currentUser;
    return Scaffold(
      backgroundColor: AppStyle.primaryColor,
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          child: GestureDetector(
            onTap: (){
              Auth auth = Auth();
              auth.signOut();
            },
            child: Text(
              user != null
                  ? 'Welcome ${user.userName}'
                  : 'SignUp/In unsuccessful',
              style: TextStyle(
                color: AppStyle.whiteAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ),
      ),
    );
  }
}
