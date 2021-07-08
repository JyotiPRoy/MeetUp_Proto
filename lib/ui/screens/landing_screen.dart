
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';
import 'package:ms_engage_proto/ui/modals/sign_in_dialog.dart';
import 'package:ms_engage_proto/ui/modals/sign_up_dialog.dart';
import 'package:ms_engage_proto/ui/widgets/default_button.dart';

class LandingPage extends StatefulWidget {

  LandingPage({
    Key? key,
  }) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {

  void _showSignUpDialog(BuildContext context) async {
    Dialog signUp = Dialog(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: AppStyle.primaryColor,
      child: SignUpDialog(),
    );
    await showDialog<Dialog>(
      context: context,
      builder: (context) => signUp,
    );
  }

  void _showSignInDialog() async {
    Dialog signIn = Dialog(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: AppStyle.primaryColor,
      child: SignInDialog(),
    );
    await showDialog<Dialog>(
      context: context,
      builder: (context) => signIn,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final buttonTextStyle = TextStyle(
        color: AppStyle.whiteAccent, fontSize: 20, fontWeight: FontWeight.bold);
    return Scaffold(
      backgroundColor: AppStyle.primaryColor,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            margin: EdgeInsets.only(left: width * 0.08),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connect with your Team,',
                  style: TextStyle(
                    color: AppStyle.whiteAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 56,
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  'anytime, anywhere',
                  style: TextStyle(
                    color: AppStyle.primaryButtonColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 56,
                  ),
                ),
                SizedBox(
                  height: 48,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DefaultButton(
                      fixedSize: Size(150,55),
                      onPress: () => _showSignUpDialog(context),
                      child: Text(
                        'SignUp',
                        style: buttonTextStyle,
                      ),
                      buttonColor: AppStyle.primaryButtonColor,
                    ),
                    SizedBox(
                      width: 25,
                    ),
                    DefaultButton(
                      fixedSize: Size(150,55),
                      onPress: () => _showSignInDialog(),
                      child: Text(
                        'Sign In',
                        style: buttonTextStyle,
                      ),
                      buttonColor: AppStyle.primaryColor,
                      buttonBorder:
                      BorderSide(color: AppStyle.defaultBorderColor, width: 1.5),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Image.asset(
                'assets/images/landing_screen_pic@2x.png'
              ),
            ),
          )
        ],
      ),
    );
  }
}
