import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ms_engage_proto/model/chat.dart';
import 'package:ms_engage_proto/model/user.dart';
import 'package:ms_engage_proto/store/session_data.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';
import 'package:ms_engage_proto/ui/widgets/default_button.dart';

class ContactViewer extends StatefulWidget {
  final StreamController<dynamic> dataController;

  const ContactViewer({
    Key? key,
    required this.dataController
  }) : super(key: key);

  @override
  _ContactViewerState createState() => _ContactViewerState();
}

class _ContactViewerState extends State<ContactViewer> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final divider = Divider(
      height: height * 0.06,
      color: AppStyle.darkBorderColor,
    );

    return Container(
      // decoration: BoxDecoration(
      //   color: AppStyle.secondaryColor,
      //   borderRadius: BorderRadius.all(Radius.circular(20)),
      //   border: Border.all(
      //     color: AppStyle.defaultBorderColor
      //   )
      // ),
      padding: EdgeInsets.all(30),
      child: StreamBuilder<dynamic>(
        stream: widget.dataController.stream,
        builder: (context, snapshot) {
          if(snapshot.hasData && snapshot.data != null){
            UserProfile user = snapshot.data is UserProfile
                ? snapshot.data : (snapshot.data as PendingRequest).participants[0];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        border: Border.all(
                          color: AppStyle.defaultBorderColor
                        ),
                        image: user.pfpUrl != null
                          ? DecorationImage(
                          image: NetworkImage(
                                  user.pfpUrl!
                              )
                            )
                          : null,
                      ),
                      width: 100,
                      height: 100,
                      child: user.pfpUrl != null
                        ? SizedBox()
                        : Center(
                        child: Icon(
                          FontAwesomeIcons.user,
                          color: AppStyle.defaultUnselectedColor,
                          size: 30,
                        ),
                      ),
                    ),
                    SizedBox(width: width * 0.02,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.userName,
                          style: TextStyle(
                            color: AppStyle.whiteAccent,
                            fontSize: 30,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Joined on: 2 July, 2020',
                          style: TextStyle(
                            color: AppStyle.defaultUnselectedColor,
                            fontSize: 18,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                divider,
                snapshot.data is PendingRequest
                    ?  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        DefaultButton(
                          onPress: (){
                            SessionData.instance.acceptRequest(snapshot.data as PendingRequest);
                            widget.dataController.add(null);
                          },
                          child: Text(
                            'Accept',
                            style: TextStyle(
                                color: AppStyle.whiteAccent
                            ),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        DefaultButton(
                          onPress: (){
                            SessionData.instance.declineRequest(snapshot.data as PendingRequest);
                            widget.dataController.add(null);
                          },
                          child: Text(
                            'Decline',
                            style: TextStyle(
                              color: AppStyle.defaultBorderColor,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                          buttonBorder: BorderSide(
                              color: AppStyle.defaultBorderColor
                          ),
                          buttonColor: AppStyle.secondaryColor,
                        )
                      ],
                    ),
                    divider
                  ],
                )
                    : SizedBox(),
                Text(
                  'More Info',
                  style: TextStyle(
                      color: AppStyle.whiteAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.bold
                  ),
                ),
                divider,
                Text(
                  'Email: ${user.email}',
                  style: TextStyle(
                    color: AppStyle.whiteAccent,
                    fontSize: 14
                  ),
                )
              ],
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: height * 0.24,
                  width: width * 0.12,
                  child: Image.asset(
                      'assets/images/ContactsBook_2x.png'
                  ),
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                Text(
                  'Click on a Contact to see more info.',
                  style: TextStyle(
                    color: AppStyle.whiteAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                )
              ],
            ),
          );
        }
      ),
    );
  }
}
