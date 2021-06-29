import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ms_engage_proto/model/user.dart';
import 'package:ms_engage_proto/store/session_data.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';
import 'package:ms_engage_proto/ui/screens/home_view.dart';
import 'package:ms_engage_proto/ui/screens/scheduled_meetings_view.dart';
import 'package:ms_engage_proto/ui/widgets/default_button.dart';
import 'package:ms_engage_proto/ui/widgets/nav_toggle_button.dart';



class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // ignore: close_sinks
  StreamController<int> toggleGroupController = StreamController<int>.broadcast();
  set currentButton(int i) => toggleGroupController.sink.add(i);
  TextEditingController _searchController = TextEditingController();

  String _currentPageTitle = 'Home';
  List<Widget> pages = <Widget>[];
  List<String> pageTitles = [
    'Home',
    'Chat',
    'Contacts',
    'Scheduled Meetings'
  ];

  Widget? _switcherChild;

  set switcherChild(int index) => setState((){
    _switcherChild = pages[index];
    _currentPageTitle = pageTitles[index];
  });

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100), () async {
      toggleGroupController.add(0);
    });
    pages.addAll([
      HomeView(),
      Container(),
      Container(),
      ScheduledMeetingsView(),
    ]);
    _switcherChild = pages[0];
  }

  @override
  void dispose() {
    _searchController.dispose();
    // toggleGroupController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    // UserProfile? user = GlobalStore.instance.currentUser;
    return Scaffold(
      backgroundColor: AppStyle.primaryColor,
      body: Container(
        width: width,
        height: height,
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: AppStyle.darkBorderColor))
              ),
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 55,
                    width: 55,
                    decoration: BoxDecoration(
                      color: AppStyle.primaryButtonColor,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Icon(FontAwesomeIcons.video, color: AppStyle.whiteAccent,),
                  ),
                  SizedBox(
                    height: height * 0.08,
                  ),
                  NavToggleButton(
                    onTap: (){
                      currentButton = 0;
                      switcherChild = 0;
                    },
                    child: Icon(
                      Icons.home,
                      size: 30,
                    ),
                    index: 0,
                    toggleController: toggleGroupController.stream,
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  NavToggleButton(
                    onTap: (){
                      currentButton = 1;
                      switcherChild = 1;
                    },
                    child: Icon(
                      FontAwesomeIcons.commentAlt,
                    ),
                    index: 1,
                    toggleController: toggleGroupController.stream,
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  NavToggleButton(
                    onTap: (){
                      currentButton = 2;
                      switcherChild = 2;
                    },
                    child: Icon(
                      FontAwesomeIcons.userFriends,
                      size: 19,
                    ),
                    index: 2,
                    toggleController: toggleGroupController.stream,
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  NavToggleButton(
                    onTap: (){
                      currentButton = 3;
                      switcherChild = 3;
                    },
                    child: Icon(
                      FontAwesomeIcons.clock,
                    ),
                    index: 3,
                    toggleController: toggleGroupController.stream,
                  ),
                  Expanded(child: SizedBox()),
                  DefaultButton(
                    onPress: (){},
                    fixedSize: Size(60, 60),
                    child: Icon(
                      FontAwesomeIcons.cog,
                      color: AppStyle.whiteAccent,
                    ),
                    buttonColor: AppStyle.secondaryColor,
                    buttonBorder: BorderSide(
                      color: AppStyle.defaultBorderColor
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                child: Column(
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: 75,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                  color: AppStyle.darkBorderColor,
                                )
                            )
                        ),
                        padding: EdgeInsets.only(left: width * 0.045, right: 40),
                        width: double.infinity,
                        height: height * 0.1,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AppStyle.defaultHeaderText(_currentPageTitle),
                            Expanded(
                              child: SizedBox(),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              width: width * 0.15,
                              decoration: BoxDecoration(
                                color: AppStyle.secondaryColor,
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                border: Border.all(
                                  color: AppStyle.defaultBorderColor
                                )
                              ),
                              child: TextField(
                                maxLines: 1,
                                controller: _searchController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: AppStyle.defaultUnselectedColor,
                                    // size: 18,
                                  ),
                                  hintText: 'Search...',
                                  hintStyle: TextStyle(
                                    color: AppStyle.defaultUnselectedColor,
                                    fontSize: 18
                                  ),
                                  border: InputBorder.none
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            StreamBuilder<UserProfile?>(
                              stream: SessionData.instance.currentUserStream,
                              builder: (context, snapshot){
                                UserProfile? user = snapshot.data;
                                return Container(
                                  clipBehavior: Clip.antiAlias,
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(15)),
                                    border: Border.all(
                                      color: AppStyle.defaultBorderColor,
                                    ),
                                    color: AppStyle.secondaryColor,
                                  ),
                                  child: snapshot.hasData
                                        ? (user!.pfpUrl != null || user.pfpUrl != '')
                                            ? Image.network(
                                                user.pfpUrl!,
                                                fit: BoxFit.contain,
                                                filterQuality: FilterQuality.medium,
                                                height: 58,
                                                width: 58,
                                              )
                                            : Center(
                                                child: CircularProgressIndicator(
                                                  color: AppStyle.defaultUnselectedColor,
                                                ),
                                              )
                                        : Center(
                                            child: Icon(
                                              FontAwesomeIcons.user,
                                              color: AppStyle.defaultUnselectedColor,
                                            ),
                                          )
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _switcherChild,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}