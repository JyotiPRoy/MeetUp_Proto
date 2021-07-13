import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ms_engage_proto/model/meeting_event.dart';
import 'package:ms_engage_proto/store/session_data.dart';
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
  final viewerController = StreamController<MeetingEvent?>.broadcast();

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
                  child: StreamBuilder<Map<String,MeetingEvent>>(
                    stream: SessionData.instance.calendarEvents,
                    builder: (context, snapshot) {
                      if(snapshot.hasData){
                        if(snapshot.data!.length > 0){
                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index){
                              return MeetingCalendarEvent(
                                groupController: listController,
                                index: index,
                                event: snapshot.data!.values.elementAt(index),
                                viewController: viewerController,
                              );
                            },
                          );
                        }else{
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/calendar_event.png',
                                ),
                                SizedBox(
                                  height: 14,
                                ),
                                Text(
                                  "You don't have any events yet.",
                                  style: TextStyle(
                                    color: AppStyle.whiteAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                  ),
                                )
                              ],
                            ),
                          );
                        }
                      }
                      return Center(
                        child: Container(

                        ),
                      );
                    }
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: width * 0.08, right: width * 0.12, top: height * 0.06),
              child: StreamBuilder<MeetingEvent?>(
                stream: viewerController.stream,
                builder: (context, snapshot) {
                  if(snapshot.hasData && snapshot.data != null){
                    return ScheduleViewer(
                      event: snapshot.data!,
                      viewController: viewerController,
                    );
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/calendar_event_2x.png',
                      ),
                      SizedBox(
                        height: 14,
                      ),
                      Text(
                        "Click on an event to see more details",
                        style: TextStyle(
                            color: AppStyle.whiteAccent,
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        ),
                      )
                    ],
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
