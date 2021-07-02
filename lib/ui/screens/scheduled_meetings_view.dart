import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ms_engage_proto/model/meeting_event.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';
import 'package:ms_engage_proto/ui/modals/add_meeting_event.dart';
import 'package:ms_engage_proto/ui/widgets/default_button.dart';
import 'package:ms_engage_proto/ui/widgets/meeting_calendar_event.dart';
import 'package:ms_engage_proto/ui/widgets/schedule_viewer.dart';
import 'package:ms_engage_proto/ui/widgets/tab_button_group.dart';

class ScheduledMeetingsView extends StatefulWidget {
  const ScheduledMeetingsView({Key? key}) : super(key: key);

  @override
  _ScheduledMeetingsViewState createState() => _ScheduledMeetingsViewState();
}

class _ScheduledMeetingsViewState extends State<ScheduledMeetingsView>{

  StreamController<int> listController = StreamController<int>.broadcast();
  GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  // StreamController<int> tabController = StreamController<int>.broadcast();

  void _showAddEventDialog(BuildContext context) async {
    Dialog signUp = Dialog(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: AppStyle.primaryColor,
      child: AddMeetingEventDialog(),
    );
    await showDialog<Dialog>(
      context: context,
      builder: (context) => signUp,
    );
  }


  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 50), () async {
      listController.add(0);
      // tabController.add(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final divider = Divider(
      height: height * 0.06,
      color: AppStyle.darkBorderColor,
    );
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(right: BorderSide(
                color: AppStyle.darkBorderColor
              ))
            ),
            padding: EdgeInsets.only(left: 80, right: 80, top: 40, bottom: 20),
            width: width * 0.38,
            // color: Colors.yellow,
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
                    Text(
                      'My Events',
                      style: TextStyle(
                        color: AppStyle.whiteAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Expanded(child: SizedBox()),
                    DefaultButton(
                      onPress: () => _showAddEventDialog(context),
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
                  child: AnimatedList(
                    key: _listKey,
                    itemBuilder: (context, index, animation){
                      return FadeTransition(
                        opacity: animation.drive(Tween<double>(begin: 0, end: 1)),
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: MeetingCalendarEvent(
                            groupController: listController,
                            index: index,
                            event: MeetingEvent.fromMap(_scheduledMeetingEvents[index]),
                          ),
                        ),
                      );
                    },
                    shrinkWrap: true,
                    initialItemCount: _scheduledMeetingEvents.length,
                    scrollDirection: Axis.vertical,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: width * 0.08, right: width * 0.12, top: height * 0.06),
              child: StreamBuilder<int>(
                stream: listController.stream,
                builder: (context, snapshot) {
                  if(snapshot.hasData && snapshot.data != null){
                    return ScheduleViewer(
                      event: MeetingEvent.fromMap(_scheduledMeetingEvents[snapshot.data!]),
                    );
                  }
                  return Center(
                    child: Container(
                      height: 60,
                      width: 60,
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              ),
            ),
          )
        ],
      ),
    );
  }
}

List<Widget> get scheduledMeetingCards {
  List<Widget> res = <Widget>[];
  _scheduledMeetingEvents.forEach((element) {
    res.add(MeetingCalendarEvent(
      event: MeetingEvent.fromMap(element),
    ));
    res.add(SizedBox(width: 40,));
  });
  return res;
}

final List<Map<String,dynamic>> _scheduledMeetingEvents = [
  {
    'hostID': 'XXYZ',
    'title' : 'Daily Sprint Session',
    'start' : DateTime(2021,6,29,19,30).toIso8601String(),
    'end' : DateTime(2021,6,29,21,10).toIso8601String(),
    'details' : 'Daily meeting to discuss about individual progress in the current sprint',
    'participants' : [

    ],
    'allowAnon' : false,
    'roomID' : '25-6-21-aYtaXjcYk',
  },
  {
    'hostID': 'XXYZ',
    'title' : 'Design Revision Session',
    'start' : DateTime(2021,6,30,13,30).toIso8601String(),
    'end' : DateTime(2021,6,30,15,30).toIso8601String(),
    'details' : 'Review and make changes to the current System & UI design',
    'participants' : [
      'uaZTyCa>LJBchUTU',
      'aioJTxTyhOqxYjtz',
      'jugfulDKUTDukyYa',
    ],
    'allowAnon' : false,
    'roomID' : '25-6-21-gJyVxCTkYt',
  },
  {
    'hostID': 'YYYZ',
    'title' : 'Code Review',
    'start' : DateTime(2021,7,1,10,30).toIso8601String(),
    'end' : DateTime(2021,7,1,12,25).toIso8601String(),
    'details' : 'Code Review with Senior',
    'participants' : [
      'uaZTyCa>LJBchUTU',
      'aioJTxTyhOqxYjtz',
    ],
    'allowAnon' : false,
    'roomID' : '25-6-21-tdRJesTTxU',
  }
];
