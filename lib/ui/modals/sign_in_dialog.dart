import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ms_engage_proto/model/user.dart';
import 'package:ms_engage_proto/services/auth.dart';
import 'package:ms_engage_proto/store/session_data.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';
import 'package:ms_engage_proto/ui/screens/dashboard.dart';
import 'package:ms_engage_proto/ui/widgets/default_button.dart';
import 'package:ms_engage_proto/ui/widgets/input_field.dart';

final RegExp emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

class SignInDialog extends StatefulWidget {
  const SignInDialog({Key? key}) : super(key: key);

  @override
  _SignInDialogState createState() => _SignInDialogState();
}

class _SignInDialogState extends State<SignInDialog> {

  bool _isLoading = false;

  bool _signInFailed = false;
  String authErrorMessage = '';

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _handleAuthErrors(FirebaseAuthException e){
    setState(() {
      _signInFailed = true;
      _isLoading = false;
    });
    switch (e.code) {
      case "ERROR_EMAIL_ALREADY_IN_USE":
      case "account-exists-with-different-credential":
      case "email-already-in-use":
        return "Email already used. Go to login page.";
      case "ERROR_WRONG_PASSWORD":
      case "wrong-password":
        return "Wrong email/password combination.";
      case "ERROR_USER_NOT_FOUND":
      case "user-not-found":
        return "No user found with this email.";
      case "ERROR_USER_DISABLED":
      case "user-disabled":
        return "User disabled.";
      case "ERROR_TOO_MANY_REQUESTS":
      case "operation-not-allowed":
        return "Too many requests to log into this account.";
      case "ERROR_OPERATION_NOT_ALLOWED":
      case "operation-not-allowed":
        return "Server error, please try again later.";
      case "ERROR_INVALID_EMAIL":
      case "invalid-email":
        return "Email address is invalid.";
      default:
        return "Login failed. Please try again.";
    }
  }

  void _submit() async {
    try{
      if(_formKey.currentState!.validate()){
        Auth auth = Auth();
        setState(() {_isLoading = true;});
        UserProfile? user = await auth.signInWithEmail(
            _emailController.text,
            _passwordController.text
        );
        if(user != null){
          setState(() {_isLoading = false;});
          SessionData.instance.updateUser(user);
          Navigator.of(context).push(MaterialPageRoute(builder: (builder) => Dashboard()));
        }else print('Null User Returned @Sign In');
      }
    }catch(e){
      authErrorMessage = _handleAuthErrors(e as FirebaseAuthException);
      _formKey.currentState!.validate();
      _signInFailed = false;
      print(authErrorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.all(20),
      width: width * 0.22,
      height: height * 0.35,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InputField(
                      controller: _emailController,
                      validator: (val){
                        if(_signInFailed){
                          return authErrorMessage;
                        }else{
                          return val != null
                              ? emailRegex.hasMatch(val)
                              ? null
                              : 'PLease enter a valid email address'
                              : 'email cannot be empty';
                        }
                      },
                      fieldName: 'Email'
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    InputField(
                      obscureText: true,
                      controller: _passwordController,
                      validator: (val){
                        if(_signInFailed){
                          return authErrorMessage;
                        }else {
                          return val != null
                              ? val.length < 8
                              ? 'Password cannot be less than 8 Characters long'
                              : null
                              : 'Password cannot be empty';
                        }
                      },
                      fieldName: 'Password',
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    DefaultButton(
                      fixedSize: Size(width * 0.2, 60),
                      onPress: () => _submit(),
                      child: _isLoading
                        ? CircularProgressIndicator(
                            color: AppStyle.primaryColor,
                          )
                        : Text(
                            'Continue',
                            style: TextStyle(
                              color: AppStyle.whiteAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                    )
                  ],
                ),
              ),
          ),
      ),
    );
  }
}
