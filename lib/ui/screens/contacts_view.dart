import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ms_engage_proto/model/chat.dart';
import 'package:ms_engage_proto/model/user.dart';
import 'package:ms_engage_proto/store/session_data.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';
import 'package:ms_engage_proto/ui/widgets/contact_viewer.dart';
import 'package:ms_engage_proto/ui/widgets/default_button.dart';
import 'package:ms_engage_proto/ui/widgets/tab_button_group.dart';

class ContactsView extends StatefulWidget {
  const ContactsView({Key? key}) : super(key: key);

  @override
  _ContactsViewState createState() => _ContactsViewState();
}

class _ContactsViewState extends State<ContactsView> {

  StreamController<int> _tabController = StreamController<int>.broadcast();
  PageController _pageController = PageController();
  StreamController<dynamic> _viewerController = StreamController<dynamic>.broadcast();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 50), () async {
      _tabController.add(0);
      _viewerController.add(null);
    });
    _tabController.stream.listen((tab) {
      _pageController.animateToPage(
        tab,
        duration: const Duration(milliseconds: 300),
        curve: Curves.decelerate,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final divider = Divider(
      height: height * 0.06,
      color: AppStyle.darkBorderColor,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(left: width * 0.03, right: width * 0.03, top: 25),
          decoration: BoxDecoration(
              border: Border(
                  right: BorderSide(
                      color: AppStyle.defaultBorderColor
                  )
              )
          ),
          width: width * 0.35,
          height: height * 0.87,
          child: Column(
            children: [
              Row(
                children: [
                  DefaultButton(
                    onPress: (){},
                    child: Icon(
                      Icons.refresh,
                      color: AppStyle.defaultUnselectedColor,
                    ),
                    padding: EdgeInsets.all(25),
                    buttonBorder: BorderSide(
                        color: AppStyle.defaultBorderColor
                    ),
                    buttonColor: AppStyle.secondaryColor,
                  ),
                  Expanded(child: SizedBox()),
                  TabsButtonGroup(
                    key: Key('ContactTabs'),
                    children: [
                      TabButton(
                        selectionController: _tabController,
                        title: 'Contacts',
                        index: 0,
                      ),
                      TabButton(
                        selectionController: _tabController,
                        title: 'Requests',
                        index: 1,
                      ),
                    ],
                  ),
                  Expanded(child: SizedBox()),
                  DefaultButton(
                    onPress: () {
                      // TODO: May show a Search and send request here
                    },
                    child: Icon(
                      Icons.add,
                      color: AppStyle.defaultUnselectedColor,
                    ),
                    padding: EdgeInsets.all(25),
                    buttonBorder: BorderSide(
                        color: AppStyle.defaultBorderColor
                    ),
                    buttonColor: AppStyle.secondaryColor,
                  ),
                ],
              ),
              divider,
              Expanded(
                child: PageView(
                  onPageChanged: (pageIndex) => _tabController.add(pageIndex),
                  controller: _pageController,
                  children: [
                    _ContactsViewer(
                      viewController: _viewerController,
                    ),
                    _PendingRequestsViewer(
                      viewController: _viewerController,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: width * 0.04, right:  width * 0.02, top: height * 0.03, bottom: height * 0.03),
          width: width * 0.57,
          height: height * 0.87,
          child: ContactViewer(
            dataController: _viewerController,
          ),
        )
      ],
    );
  }
}

class _ContactsViewer extends StatelessWidget {
  final StreamController<dynamic> viewController;

  const _ContactsViewer({
    Key? key,
    required this.viewController
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: StreamBuilder<List<UserProfile>>(
          stream: SessionData.instance.contacts,
          builder: (context, snapshot) {
            if(snapshot.hasData && snapshot.data != null){
              return Column(
                children: snapshot.data!.map((user){
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: (){
                        viewController.add(user);
                      },
                      child: Container(
                        height: 75,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
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
                              child: user.pfpUrl != null
                                  ? Image.network(
                                  user.pfpUrl!
                              )
                                  : Container(),
                            ),
                            SizedBox(width: 16,),
                            Text(
                              user.userName,
                              style: TextStyle(
                                  color: AppStyle.whiteAccent,
                                  fontSize: 16
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }
                ).toList(),
              );
            }
            return Center(
              child: Container(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  color: AppStyle.whiteAccent,
                ),
              ),
            );
          }
      ),
    );
  }
}

class _PendingRequestsViewer extends StatelessWidget {
  final StreamController<dynamic> viewController;

  const _PendingRequestsViewer({
    Key? key,
    required this.viewController
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: StreamBuilder<List<PendingRequest>>(
          stream: SessionData.instance.pendingRequests,
          builder: (context, snapshot) {

            if(snapshot.hasData && snapshot.data != null){
              print("SNAPSHOT LENGTH: ${snapshot.data!.length}");
              return Column(
                children: snapshot.data!.map((pendingRequest){
                  UserProfile user = pendingRequest.participants[0];
                  print('USER: ${user.userName}, PFP: ${user.pfpUrl}');
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: (){
                        viewController.add(pendingRequest);
                      },
                      child: Container(
                        height: 75,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
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
                              child: user.pfpUrl != null
                                  ? Image.network(
                                      user.pfpUrl!
                                    )
                                  : Center(
                                      child: Icon(FontAwesomeIcons.user,
                                      color: AppStyle.defaultUnselectedColor,),
                                  ),
                            ),
                            SizedBox(width: 16,),
                            Text(
                              user.userName,
                              style: TextStyle(
                                  color: AppStyle.whiteAccent,
                                  fontSize: 16
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }
                ).toList(),
              );
            }
            return Center(
              child: Container(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  color: AppStyle.whiteAccent,
                ),
              ),
            );
          }
      ),
    );
  }
}


