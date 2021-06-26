import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ms_engage_proto/model/meeting_event.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';
import 'package:ms_engage_proto/ui/widgets/dashboard_action_btn.dart';
import 'package:ms_engage_proto/ui/widgets/date_time_widget.dart';
import 'package:ms_engage_proto/ui/widgets/meeting_calendar_event.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Container(
          width: width * 0.38,
          height: height * 0.9,
          decoration: BoxDecoration(
              border: Border(
                  right: BorderSide(
                      color: AppStyle.darkBorderColor
                  )
              )
          ),
          padding: EdgeInsets.symmetric(vertical: height * 0.06, horizontal: width * 0.045),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: width * 0.17,
            ),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: height * 0.04,
                runSpacing: height * 0.04,
                children: [
                  DashboardActionButton(
                    title: 'New Meeting',
                    subtext: 'Setup a New Meeting',
                    icon: FontAwesomeIcons.video,
                    color: AppStyle.primaryHomeAction,
                  ),
                  DashboardActionButton(
                    title: 'Join Meeting',
                    subtext: 'Join via Link or Anon',
                    icon: FontAwesomeIcons.solidPlusSquare,
                  ),
                  DashboardActionButton(
                    title: 'Schedule Meeting',
                    subtext: 'Plan your Meetings',
                    icon: FontAwesomeIcons.solidClock,
                  ),
                  DashboardActionButton(
                    title: 'Share Screen',
                    subtext: 'Present your Work',
                    icon: FontAwesomeIcons.share,
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: height * 0.03, left: width * 0.042, right: width * 0.03),
          child: Container(
            height: height * 0.8,
            width:  width * 0.48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DateTimeDisplay(),
                SizedBox(
                  height: 50,
                ),
                Text(
                  "Today's Meetings",
                  style: TextStyle(
                      color: AppStyle.whiteAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: scheduledMeetingCards,
                  ),
                )
              ],
            ),
          ),
        )
      ],
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
    'title' : 'Daily Sprint Session',
    'start' : DateTime(2021,6,26,18,30).toIso8601String(),
    'end' : DateTime(2021,6,26,21,10).toIso8601String(),
    'details' : 'Daily meeting to discuss about individual progress in the current sprint',
    'participants' : [

    ],
    'allowAnon' : false,
    'roomID' : '25-6-21-aYtaXjcYk',
  },
  {
    'title' : 'Design Revision Session',
    'start' : DateTime(2021,6,26,13,30).toIso8601String(),
    'end' : DateTime(2021,6,26,15,30).toIso8601String(),
    'details' : 'Review and make changes to the current System & UI design',
    'participants' : [
      'uaZTyCa>LJBchUTU',
      'aioJTxTyhOqxYjtz',
      'jugfulDKUTDukyYa',
    ],
    'allowAnon' : false,
    'roomID' : '25-6-21-aYtaXjcYk',
  },
  {
    'title' : 'Code Review',
    'start' : DateTime(2021,6,27,10,30).toIso8601String(),
    'end' : DateTime(2021,6,27,12,25).toIso8601String(),
    'details' : 'Code Review with Senior',
    'participants' : [
      'uaZTyCa>LJBchUTU',
      'aioJTxTyhOqxYjtz',
    ],
    'allowAnon' : false,
    'roomID' : '25-6-21-aYtaXjcYk',
  }
];
