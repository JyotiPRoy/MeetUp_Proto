import 'package:file_picker/file_picker.dart';
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

class SignUpDialog extends StatefulWidget {
  const SignUpDialog({Key? key}) : super(key: key);

  @override
  _SignUpDialogState createState() => _SignUpDialogState();
}

class _SignUpDialogState extends State<SignUpDialog> {
  bool _isLoading = false;

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  FilePickerResult? _pfp;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _getPFP() async {
    var img = await FilePicker.platform.pickFiles(type: FileType.image);
    setState(() {
      _pfp = img;
    });
  }

  Future<void> _submit() async {
    // try{
    //
    // }catch(e){
    //   print('EXCP @SignUp dialog: ${e.toString()}');
    //   return;
    // }
    if (_formKey.currentState!.validate()) {
      Auth auth = Auth();
      UserProfile dummyProfile = UserProfile(
        userID:
        'dummy', // dummy ID since we don't have an ID yet, which will be provided with signup
        userName: _usernameController.text,
        email: _emailController.text,
      );
      setState(() {_isLoading = true;});
      UserProfile? response = await auth.signUpWithEmail(
        _emailController.text,
        _passwordController.text,
        dummyProfile,
        _pfp != null ? _pfp!.files.first : null,
      );
      if (response != null) {
        setState(() {_isLoading = false;});
        SessionData.instance.updateUser(response);
        Navigator.of(context).push(MaterialPageRoute(builder: (builder) => Dashboard()));
      } else
        print('Null User returned! @DialogBox');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration:
          BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
      width: width * 0.22,
      height: height * 0.65,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isLoading == true
            ? Center(
                child: Container(
                  width: width * 0.22,
                  height: height * 0.65,
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
                        'Creating a new Account',
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
                      GestureDetector(
                        onTap: () => _getPFP(),
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                              color: AppStyle.secondaryColor,
                              border:
                                  Border.all(color: AppStyle.defaultBorderColor),
                              shape: BoxShape.circle,
                              image: _pfp != null
                                  ? DecorationImage(
                                      image:
                                          MemoryImage(_pfp!.files.first.bytes!),
                                      fit: BoxFit.fill)
                                  : null),
                          child: _pfp == null
                              ? Center(
                                  child: Icon(
                                    Icons.add_photo_alternate_rounded,
                                    size: 40,
                                    color: AppStyle.whiteAccent,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Profile Picture',
                        style: TextStyle(
                            color: AppStyle.whiteAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      InputField(
                        controller: _usernameController,
                        validator: (val) {
                          return val != null
                              ? val.length < 6
                                  ? 'Username cannot be less than 6 Characters long'
                                  : null
                              : 'Username cannot be empty';
                        },
                        fieldName: 'Username',
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      InputField(
                        controller: _emailController,
                        validator: (val) {
                          return val != null
                              ? emailRegex.hasMatch(val)
                                  ? null
                                  : 'PLease enter a valid email address'
                              : 'email cannot be empty';
                        },
                        fieldName: 'Email',
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      InputField(
                        obscureText: true,
                        controller: _passwordController,
                        validator: (val) {
                          return val != null
                              ? val.length < 8
                                  ? 'Password cannot be less than 8 Characters long'
                                  : null
                              : 'Password cannot be empty';
                        },
                        fieldName: 'Password',
                      ),
                      SizedBox(
                        height: 46,
                      ),
                      DefaultButton(
                        fixedSize: Size(width * 0.2, 60),
                        onPress: () => _submit(),
                        child: Text(
                          'Create Account',
                          style: TextStyle(
                              color: AppStyle.whiteAccent,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
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
