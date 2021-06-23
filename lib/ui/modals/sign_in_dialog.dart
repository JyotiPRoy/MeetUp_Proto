import 'package:flutter/material.dart';
import 'package:ms_engage_proto/core/user.dart';
import 'package:ms_engage_proto/services/auth.dart';
import 'package:ms_engage_proto/store/global_store.dart';
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

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
          GlobalStore.instance.updateUser(user);
          Navigator.of(context).push(MaterialPageRoute(builder: (builder) => Dashboard()));
        }else print('Null User Returned @Sign In');
      }
    }catch(e){
      print('EXCP @SignIn: ${e.toString()}');
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
        child: _isLoading == true
          ? Center(
              child: Container(
                width: width * 0.22,
                height: height * 0.35,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      child: CircularProgressIndicator(
                        color: AppStyle.whiteAccent,
                      ),
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    Text(
                      'Signing In',
                      style: TextStyle(
                          color: AppStyle.whiteAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                      ),
                    )
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InputField(
                      controller: _emailController,
                      validator: (val){
                        return val != null
                            ? emailRegex.hasMatch(val)
                              ? null
                              : 'PLease enter a valid email address'
                            : 'email cannot be empty';
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
                        return val != null
                            ? val.length < 8
                              ? 'Password cannot be less than 8 Characters long'
                              : null
                            : 'Password cannot be empty';
                      },
                      fieldName: 'Password',
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    DefaultButton(
                      fixedSize: Size(width * 0.2, 60),
                      onPress: () => _submit(),
                      child: Text(
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
