import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool _isSubmitting = false;
  bool _isLoading = false;
  bool _optOutOfSearch = false;
  bool _shareEmail = false;

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  FilePickerResult? _pfp;

  int _currentPage = 0;

  final flowController = StreamController<int>.broadcast();
  final pageController = PageController();
  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages = [
      _DetailsPage(
        userController: _usernameController,
        emailController: _emailController,
        passwordController: _passwordController,
      ),
      _ProfilePicPage(
        pfp: _pfp,
        onDone: (pfp) => _pfp = pfp,
      ),
      _PrivacyOptionsPage(
        optOut: _optOutOfSearch,
        shareEmail: _shareEmail,
        onDone: (optOut, shareEmail){
          _optOutOfSearch = optOut;
          _shareEmail = shareEmail;
        },
      )
    ];
    Future.delayed(
      const Duration(milliseconds: 50),
      () => flowController.add(0),
    );
    flowController.stream.listen((page) {
      pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 200),
        curve: Curves.ease,
      );
    });
  }

  Future<void> _buttonHandler() async {
    switch(_currentPage){
      case 0:{
        setState(() {
          _isLoading = true;
        });
        if(await (_pages[0] as _DetailsPage).validateAndSave()){
          _currentPage += 1;
          flowController.add(_currentPage);
        }
        setState(() {
          _isLoading = false;
        });
        break;
      }
      case 1: {
        _currentPage += 1;
        flowController.add(_currentPage);
        break;
      }
      case 2: {
        setState(() {
          _isSubmitting = true;
        });
        // TODO: ADD SUBMIT
        _submit();
        break;
      }
      default:{
        _currentPage = 0;
        flowController.add(_currentPage);
      }
    }
  }

  Future<void> _submit() async {
    // try{
    //
    // }catch(e){
    //   print('EXCP @SignUp dialog: ${e.toString()}');
    //   return;
    // }
    Auth auth = Auth();
    UserProfile dummyProfile = UserProfile(
      userID:
      'dummy', // dummy ID since we don't have an ID yet, which will be provided with signup
      userName: _usernameController.text,
      email: _emailController.text,
      optOutOfSearch: _optOutOfSearch,
      shareEmail: _shareEmail,
    );
    // setState(() {_isLoading = true;});
    UserProfile? response = await auth.signUpWithEmail(
      _emailController.text,
      _passwordController.text,
      dummyProfile,
      _pfp != null ? _pfp!.files.first : null,
    );
    if (response != null) {
      // setState(() {_isLoading = false;});
      SessionData.instance.updateUser(response);
      Navigator.of(context).push(MaterialPageRoute(builder: (builder) => Dashboard()));
    } else
      print('Null User returned! @DialogBox');
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
      padding: const EdgeInsets.only(bottom: 20, right: 20, top: 10, left: 10),
      decoration:
          BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
      width: width * 0.25,
      height: height * 0.5,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isSubmitting == true
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
            : Scaffold(
          backgroundColor: AppStyle.primaryColor,
          appBar: AppBar(
            backgroundColor: AppStyle.primaryColor,
            title: StreamBuilder<int>(
              stream: flowController.stream,
              builder: (context, snapshot) {
                var headerTextStyle = TextStyle(
                    color: AppStyle.whiteAccent,
                    fontWeight: FontWeight.bold
                );
                var titles = <String>[
                  'Enter Details',
                  'Add Profile Picture',
                  'Privacy Options'
                ];

                if(snapshot.hasData && snapshot.data != null){
                  return Text(
                    titles[snapshot.data!],
                    style: headerTextStyle,
                  );
                }
                return Text(
                  'Loading...',
                  style: headerTextStyle,
                );
              }
            ),
            titleSpacing: 0,
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: DefaultButton(
                  borderRadius: 10,
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  onPress: () async => _buttonHandler(),
                  child: _isLoading
                      ? CircularProgressIndicator(
                    color: AppStyle.whiteAccent,
                  )
                      : Text(
                    'Next',
                    style: TextStyle(
                        color: AppStyle.whiteAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              )
            ],
            leading: IconButton(
              onPressed: () {
                if(_currentPage != 0){
                  _currentPage -= 1;
                  flowController.add(_currentPage);
                }else Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: AppStyle.whiteAccent,
              ),
            ),
          ),
          body: PageView(
            physics: NeverScrollableScrollPhysics(),
            controller: pageController,
            children: _pages,
          ),
        )
      ),
    );
  }
}


class _DetailsPage extends StatelessWidget {
  final TextEditingController userController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  bool _userNameExists = false;
  bool _emailExists = false;
  final _formKey = GlobalKey<FormState>();

  _DetailsPage({
    Key? key,
    required this.userController,
    required this.emailController,
    required this.passwordController,
  }) : super(key: key);

  Future<bool> validateAndSave() async {
    var valid = _formKey.currentState!.validate();
    if(valid){
      return true;
    }else return false;
  }

  Future<void> _userNameValidator(String? value) async {
    var snapshot
      = await FirebaseFirestore.instance
          .collection('users')
          .where('userName', isEqualTo: value)
          .limit(1).get();
    if(snapshot.docs.length == 1){
      _userNameExists = true;
    }
  }

  Future<void> _emailValidator(String? value) async {
    var snapshot
    = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: value)
        .limit(1).get();
    if(snapshot.docs.length == 1){
      _emailExists = true;
    }
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              InputField(
                controller: userController,
                onChanged: (val) async => _userNameValidator(val),
                validator: (val) {
                  if(val != null && val.isNotEmpty){
                    return _userNameExists ? 'Username already exists!' : null;
                  }else return 'Username cannot be empty!';
                },
                fieldName: 'Username',
              ),
              SizedBox(
                height: 16,
              ),
              InputField(
                controller: emailController,
                onChanged: (val) async => _emailValidator(val),
                validator: (val){
                  if(_emailExists){
                    return 'An account with this email already exists';
                  }else {
                    return val != null
                        ? emailRegex.hasMatch(val)
                        ? null
                        : 'PLease enter a valid email address'
                        : 'email cannot be empty';
                  }
                },
                fieldName: 'Email',
              ),
              SizedBox(
                height: 16,
              ),
              InputField(
                obscureText: true,
                controller: passwordController,
                validator: (val){
                  return val != null
                      ? val.length < 8
                      ? 'Password cannot be less than 8 Characters long'
                      : null
                      : 'Password cannot be empty';
                },
                fieldName: 'Password',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfilePicPage extends StatefulWidget {
  final FilePickerResult? pfp;
  final void Function(FilePickerResult?) onDone;

  const _ProfilePicPage({
    Key? key,
    this.pfp,
    required this.onDone,
  }) : super(key: key);

  @override
  __ProfilePicPageState createState() => __ProfilePicPageState();
}

class __ProfilePicPageState extends State<_ProfilePicPage> {

  FilePickerResult? _pfp;

  @override
  initState(){
    super.initState();
    _pfp = widget.pfp;
  }

  Future<void> _getPFP() async {
    var img = await FilePicker.platform.pickFiles(type: FileType.image);
    setState(() {
      _pfp = img;
    });
    widget.onDone.call(_pfp);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: height * 0.06,),
        GestureDetector(
          onTap: () => _getPFP(),
          child: Container(
            clipBehavior: Clip.antiAlias,
            width: 150,
            height: 150,
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
        SizedBox(
          height: height * 0.03,
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: width * 0.17
          ),
          child: Text(
            'Your profile Picture will be visible to your '
            'contacts and anyone who searches for you in Global Search',
            style: TextStyle(
              color: AppStyle.defaultUnselectedColor
            ),
            softWrap: true,
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }
}

class _PrivacyOptionsPage extends StatefulWidget {
  final bool? optOut;
  final bool? shareEmail;
  final void Function(bool,bool) onDone;
  const _PrivacyOptionsPage({
    Key? key,
    this.optOut,
    this.shareEmail,
    required this.onDone,
  }) : super(key: key);

  @override
  __PrivacyOptionsPageState createState() => __PrivacyOptionsPageState();
}

class __PrivacyOptionsPageState extends State<_PrivacyOptionsPage> {
  bool? _optOutOfSearch;
  bool? _shareEmail;

  @override
  initState(){
    super.initState();
    _optOutOfSearch = widget.optOut ?? false;
    _shareEmail = widget.shareEmail ?? false;
  }

  Color _getCheckBoxColor(Set<MaterialState> states) {
    if(states.contains(MaterialState.hovered) && !states.contains(MaterialState.selected)){
      return AppStyle.whiteAccent.withOpacity(0.7);
    }else if(states.contains(MaterialState.selected) && states.contains(MaterialState.hovered))
      return AppStyle.primaryButtonColor;
    if(states.contains(MaterialState.selected))
      return AppStyle.primaryButtonColor;
    else return AppStyle.defaultUnselectedColor;  //Pardon the bad code :(
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                checkColor: AppStyle.whiteAccent,
                fillColor: MaterialStateProperty.resolveWith(_getCheckBoxColor),
                value: _optOutOfSearch,
                onChanged: (val){
                  setState(() {
                    _optOutOfSearch = val!;
                  });
                  widget.onDone.call(_optOutOfSearch!, _shareEmail!);
                },
              ),
              SizedBox(
                width: 16,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: width * 0.15
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Opt out of Global Search',
                        style: TextStyle(
                            color: AppStyle.whiteAccent
                        ),
                      ),
                      SizedBox(height: 4,),
                      Text(
                        'If unselected anyone can search for you with'
                            ' your Username and send you Friend Requests',
                        softWrap: true,
                        style: TextStyle(
                            color: AppStyle.defaultUnselectedColor
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                checkColor: AppStyle.whiteAccent,
                fillColor: MaterialStateProperty.resolveWith(_getCheckBoxColor),
                value: _shareEmail,
                onChanged: (val){
                  setState(() {
                    _shareEmail = val!;
                  });
                  widget.onDone.call(_optOutOfSearch!,_shareEmail!);
                },
              ),
              SizedBox(
                width: 16,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: width * 0.15
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Share Email address with contacts?',
                        style: TextStyle(
                            color: AppStyle.whiteAccent
                        ),
                      ),
                      SizedBox(height: 4,),
                      Text(
                        'If Selected your email address will be visible to your contacts',
                        softWrap: true,
                        style: TextStyle(
                            color: AppStyle.defaultUnselectedColor
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

